// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017 Cedric Dufour <http://cedric.dufour.name>
//
// Glider's Swiss Knife (GliderSK) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Glider's Swiss Knife (GliderSK) is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.Position as Pos;
using Toybox.Sensor;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Application settings
var GSK_Settings = null;

// (Last) position location/altitude
var GSK_PositionLocation = null;
var GSK_PositionAltitude = null;

// Processing logic
var GSK_Processing = null;
var GSK_TimeStart = null;

// Activity session (recording)
var GSK_ActivitySession = null;
var GSK_ActivitySession_TimeStart = null;
var GSK_ActivitySession_TimeLap = null;
var GSK_ActivitySession_CountLaps = null;
var GSK_FitField_VerticalSpeed = null;
var GSK_FitField_VerticalSpeed_UnitConstant = 1.0f;
var GSK_FitField_RateOfTurn = null;
var GSK_FitField_RateOfTurn_UnitConstant = 1.0f;
var GSK_FitField_Acceleration = null;

// Current view
var GSK_CurrentView = null;


//
// CONSTANTS
//

// Storage slots
const GSK_STORAGE_SLOTS = 100;

// No-value strings
// NOTE: Those ought to be defined in the GskApp class like other constants but code then fails with an "Invalid Value" error when called upon; BUG?
const GSK_NOVALUE_LEN2 = "--";
const GSK_NOVALUE_LEN3 = "---";
const GSK_NOVALUE_LEN4 = "----";


//
// CLASS
//

class GskApp extends App.AppBase {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_RATEOFTURN = 1;
  public const FITFIELD_ACCELERATION = 2;

  // Tones control
  public const TONES_SAFETY = 1;
  public const TONES_VARIOMETER = 2;


  //
  // VARIABLES
  //

  // Timers
  // ... UI update
  private var oUpdateTimer;
  private var iUpdateLastEpoch;
  // ... tones
  private var oTonesTimer;
  private var iTonesTick;
  private var iTonesLastTick;

  // Tones
  private var iTones;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

    // Application settings
    $.GSK_Settings = new GskSettings();

    // Processing logic
    $.GSK_Processing = new GskProcessing();

    // Timers
    $.GSK_TimeStart = Time.now();
    // ... UI update
    self.oUpdateTimer = null;
    self.iUpdateLastEpoch = 0;
    // ... tones
    self.oTonesTimer = null;
  }

  function onStart(state) {
    //Sys.println("DEBUG: GskApp.onStart()");

    // Upgrade
    self.upgradeSdk();

    // Load settings
    self.loadSettings();

    // Enable sensor events
    Sensor.setEnabledSensors([]);  // ... we need just the acceleration
    Sensor.enableSensorEvents(method(:onSensorEvent));

    // Enable position events
    Pos.enableLocationEvents(Pos.LOCATION_CONTINUOUS, method(:onLocationEvent));

    // Start UI update timer (every multiple of 5 seconds, to save energy)
    // NOTE: in normal circumstances, UI update will be triggered by position events (every ~1 second)
    self.oUpdateTimer = new Timer.Timer();
    var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%5;
    if(iUpdateTimerDelay > 0) {
      self.oUpdateTimer.start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    }
    else {
      self.oUpdateTimer.start(method(:onUpdateTimer), 5000, true);
    }
  }

  function onStop(state) {
    //Sys.println("DEBUG: GskApp.onStop()");

    // Stop timers
    // ... UI update
    if(self.oUpdateTimer != null) {
      self.oUpdateTimer.stop();
      self.oUpdateTimer = null;
    }
    // ... tones
    if(self.oTonesTimer != null) {
      self.oTonesTimer.stop();
      self.oTonesTimer = null;
    }

    // Disable position events
    Pos.enableLocationEvents(Pos.LOCATION_DISABLE, null);

    // Disable sensor events
    Sensor.enableSensorEvents(null);
  }

  function getInitialView() {
    //Sys.println("DEBUG: GskApp.getInitialView()");

    return [new ViewGlobal(), new ViewDelegateGlobal()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: GskApp.onSettingsChanged()");
    self.loadSettings();
    self.updateUi(Time.now().value());
  }


  //
  // FUNCTIONS: self
  //

  function upgradeSdk() {
    //Sys.println("DEBUG: GskApp.upgradeSdk()");

    // Migrate data from Object Store to Application.Storage (SDK >= 2.4.0)
    // TODO: Delete after December 1st, 2018

    // ... destination
    if(AppBase.getProperty("storDestInUse") != null) {
      // ... in use
      Sys.println("DEBUG[upgrade]: Migrating 'storDestInUse'");
      App.Storage.setValue("storDestInUse", AppBase.getProperty("storDestInUse"));
      AppBase.deleteProperty("storDestInUse");
      // ... memory slots
      for(var n=0; n<$.GSK_STORAGE_SLOTS; n++) {
        var s = n.format("%02d");
        var dictLocation = AppBase.getProperty("storDest"+s);
        if(dictLocation != null) {
          Sys.println("DEBUG[upgrade]: Migrating 'storDest"+s+"'");
          App.Storage.setValue("storDest"+s, dictLocation);
          AppBase.deleteProperty("storDest"+s);
        }
      }
    }
  }

  function loadSettings() {
    //Sys.println("DEBUG: GskApp.loadSettings()");

    // Load settings
    $.GSK_Settings.load();

    // Apply settings
    $.GSK_Processing.importSettings();

    // ... safety destination
    var dictDestination = App.Storage.getValue("storDestInUse");
    if(dictDestination == null) {
      // Hey! Gsk was born at LSGB ;-)
      dictDestination = { "name" => "LSGB", "latitude" => 46.2583333333f, "longitude" => 6.98638888889f, "elevation" => 400.0f };
      // Yet, for debugging in the simulator (which is fond of Kansas City), KOJC or KIXD make more sense
      //dictDestination = { "name" => "KOJC", "latitude" => 38.8476019f, "longitude" => -94.7375858f, "elevation" => 334.1f };
      //dictDestination = { "name" => "KIXD", "latitude" => 38.8309167f, "longitude" => -94.8903056f, "elevation" => 331.4f };
      App.Storage.setValue("storDestInUse", dictDestination);
    }
    $.GSK_Processing.setDestination(dictDestination["name"], new Pos.Location({ :latitude => dictDestination["latitude"], :longitude => dictDestination["longitude"], :format => :degrees}), dictDestination["elevation"]);

    // ... tones
    self.muteTones();
  }

  function onSensorEvent(_oInfo) {
    //Sys.println("DEBUG: GskApp.onSensorEvent());

    // Process sensor data
    $.GSK_Processing.processSensorInfo(_oInfo, Time.now().value());

    // Save FIT fields
    if($.GSK_FitField_Acceleration != null and $.GSK_Processing.fAcceleration != null) {
      $.GSK_FitField_Acceleration.setData($.GSK_Processing.fAcceleration);
    }
  }

  function onLocationEvent(_oInfo) {
    //Sys.println("DEBUG: GskApp.onLocationEvent()");
    var iEpoch = Time.now().value();

    // Save location
    if(_oInfo has :position) {
      $.GSK_PositionLocation = _oInfo.position;
    }

    // Save altitude
    if(_oInfo has :altitude) {
      $.GSK_PositionAltitude = _oInfo.altitude;
    }

    // Process position data
    $.GSK_Processing.processPositionInfo(_oInfo, iEpoch);

    // UI update
    self.updateUi(iEpoch);

    // Save FIT fields
    if($.GSK_FitField_VerticalSpeed != null and $.GSK_Processing.fVariometer != null) {
      $.GSK_FitField_VerticalSpeed.setData($.GSK_Processing.fVariometer * $.GSK_FitField_VerticalSpeed_UnitConstant);
    }
    if($.GSK_FitField_RateOfTurn != null and $.GSK_Processing.fRateOfTurn != null) {
      $.GSK_FitField_RateOfTurn.setData($.GSK_Processing.fRateOfTurn * $.GSK_FitField_RateOfTurn_UnitConstant);
    }
  }

  function onUpdateTimer_init() {
    //Sys.println("DEBUG: GskApp.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 5000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: GskApp.onUpdateTimer()");
    var iEpoch = Time.now().value();
    if(iEpoch-self.iUpdateLastEpoch > 1) {
      self.updateUi(iEpoch);
    }
  }

  function onTonesTimer() {
    //Sys.println("DEBUG: GskApp.onTonesTimer()");
    self.playTones();
    self.iTonesTick++;
  }

  function updateUi(_iEpoch) {
    //Sys.println("DEBUG: GskApp.updateUi()");

    // Check sensor data age
    if($.GSK_Processing.iSensorEpoch != null and _iEpoch-$.GSK_Processing.iSensorEpoch > 10) {
      $.GSK_Processing.resetSensorData();
    }

    // Check position data age
    if($.GSK_Processing.iPositionEpoch != null and _iEpoch-$.GSK_Processing.iPositionEpoch > 10) {
      $.GSK_Processing.resetPositionData();
    }

    // Update UI
    if($.GSK_CurrentView != null) {
      $.GSK_CurrentView.updateUi();
      self.iUpdateLastEpoch = _iEpoch;
    }
  }

  function muteTones() {
    // Stop tones timers
    if(self.oTonesTimer != null) {
      self.oTonesTimer.stop();
      self.oTonesTimer = null;
    }
  }

  function unmuteTones(_iTones) {
    // Enable tones
    self.iTones = 0;
    if(Attn has :playTone) {
      if(_iTones & self.TONES_SAFETY and $.GSK_Settings.bSafetyTones) {
        self.iTones |= self.TONES_SAFETY;
      }
      if(_iTones & self.TONES_VARIOMETER and $.GSK_Settings.bVariometerTones) {
        self.iTones |= self.TONES_VARIOMETER;
      }
    }

    // Start tones timer
    // NOTE: For variometer tones, we need a 10Hz <-> 100ms resolution; otherwise, 1Hz <-> 1000ms is enough
    if(self.iTones) {
      self.iTonesTick = 1000;
      self.iTonesLastTick = 0;
      self.oTonesTimer = new Timer.Timer();
      self.oTonesTimer.start(method(:onTonesTimer), self.iTones & self.TONES_VARIOMETER ? 100 : 1000, true);
    }
  }

  function playTones() {
    //Sys.println(Lang.format("DEBUG: GskApp.playTones() @ $1$", [self.iTonesTick]));

    // Check mute distance
    if($.GSK_Settings.fMuteDistance > 0.0f
       and $.GSK_Processing.fDistanceToDestination != null
       and $.GSK_Processing.fDistanceToDestination <= $.GSK_Settings.fMuteDistance) {
      //Sys.println(Lang.format("DEBUG: playTone: mute! @ $1$ ($2$ <= $3$)", [self.iTonesTick, $.GSK_Processing.fDistanceToDestination, $.GSK_Settings.fMuteDistance]));
      return;
    }

    // Alert tones (priority over variometer)
    if(self.iTones & self.TONES_SAFETY) {
      if($.GSK_Processing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {  // position accuracy is good enough
        if($.GSK_Processing.bAltitudeCritical and self.iTonesTick-self.iTonesLastTick >= (self.iTones & self.TONES_VARIOMETER ? 10 : 1)) {
          //Sys.println(Lang.format("DEBUG: playTone = altitude critical @ $1$", [self.iTonesTick]));
          Attn.playTone(Attn.TONE_LOUD_BEEP);
          self.iTonesLastTick = self.iTonesTick;
          return;
        }
        else if($.GSK_Processing.bAltitudeWarning and self.iTonesTick-self.iTonesLastTick >= (self.iTones & self.TONES_VARIOMETER ? 30 : 3)) {
          //Sys.println(Lang.format("DEBUG: playTone: altitude warning @ $1$", [self.iTonesTick]));
          Attn.playTone(Attn.TONE_LOUD_BEEP);
          self.iTonesLastTick = self.iTonesTick;
          return;
        }
      }
      else if(self.iTonesTick-self.iTonesLastTick >= (self.iTones & self.TONES_VARIOMETER ? 20 : 2)) {
        //Sys.println(Lang.format("DEBUG: playTone: position accuracy @ $1$", [self.iTonesTick]));
        Attn.playTone(Attn.TONE_ALARM);
        self.iTonesLastTick = self.iTonesTick;
          return;
      }
    }

    // Variometer
    // ALGO: Tones "tick" is 100ms; we work between 200ms (2 ticks) and 2000ms (20 ticks) pediod,
    //       depending on the ratio between the ascent speed and the variometer range.
    if(self.iTones & self.TONES_VARIOMETER)
    {
      if($.GSK_Processing.fVariometer != null and $.GSK_Processing.fVariometer > 0.05f) {
        if(self.iTonesTick-self.iTonesLastTick >= 20.0f-18.0f*$.GSK_Processing.fVariometer/$.GSK_Settings.fVariometerRange) {
          //Sys.println(Lang.format("DEBUG: playTone: variometer @ $1$", [self.iTonesTick]));
          Attn.playTone(Attn.TONE_KEY);
          self.iTonesLastTick = self.iTonesTick;
          return;
        }
      }
    }
  }

}
