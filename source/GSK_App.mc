// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2019 Cedric Dufour <http://cedric.dufour.name>
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

using Toybox.Activity;
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.Communications as Comm;
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
var GSK_oSettings = null;

// (Last) position location/altitude
var GSK_oPositionLocation = null;
var GSK_oPositionAltitude = null;

// Sensors filter
var GSK_oFilter = null;

// Internal altimeter
var GSK_oAltimeter = null;

// Processing logic
var GSK_oProcessing = null;
var GSK_oTimeStart = null;

// Log
var GSK_iLogIndex = null;

// Activity session (recording)
var GSK_oActivity = null;

// Current view
var GSK_oCurrentView = null;


//
// CONSTANTS
//

// Storage slots
const GSK_STORAGE_SLOTS = 100;

// No-value strings
// NOTE: Those ought to be defined in the GSK_App class like other constants but code then fails with an "Invalid Value" error when called upon; BUG?
const GSK_NOVALUE_BLANK = "";
const GSK_NOVALUE_LEN2 = "--";
const GSK_NOVALUE_LEN3 = "---";
const GSK_NOVALUE_LEN4 = "----";


//
// CLASS
//

class GSK_App extends App.AppBase {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_RATEOFTURN = 1;
  public const FITFIELD_ACCELERATION = 2;
  public const FITFIELD_BAROMETRICALTITUDE = 3;

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
    $.GSK_oSettings = new GSK_Settings();

    // Sensors filter
    $.GSK_oFilter = new GSK_Filter();

    // Internal altimeter
    $.GSK_oAltimeter = new GSK_Altimeter();

    // Processing logic
    $.GSK_oProcessing = new GSK_Processing();

    // Log
    var iLogEpoch = 0;
    for(var n=0; n<$.GSK_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      var dictLog = App.Storage.getValue(Lang.format("storLog$1$", [s]));
      if(dictLog == null) {
        break;
      }
      var i = dictLog.get("timeStart");
      if(i != null and i > iLogEpoch) {
        $.GSK_iLogIndex = n;
        iLogEpoch = i;
      }
    }

    // Timers
    $.GSK_oTimeStart = Time.now();
    // ... UI update
    self.oUpdateTimer = null;
    self.iUpdateLastEpoch = 0;
    // ... tones
    self.oTonesTimer = null;
  }

  function onStart(state) {
    //Sys.println("DEBUG: GSK_App.onStart()");

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
    //Sys.println("DEBUG: GSK_App.onStop()");

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
    //Sys.println("DEBUG: GSK_App.getInitialView()");

    return [new GSK_ViewGeneral(), new GSK_ViewGeneralDelegate()];
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: GSK_App.onSettingsChanged()");
    self.loadSettings();
    self.updateUi(Time.now().value());
  }


  //
  // FUNCTIONS: self
  //

  function loadSettings() {
    //Sys.println("DEBUG: GSK_App.loadSettings()");

    // Load settings
    $.GSK_oSettings.load();

    // Apply settings
    $.GSK_oFilter.importSettings();
    $.GSK_oAltimeter.importSettings();
    $.GSK_oProcessing.importSettings();

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
    $.GSK_oProcessing.setDestination(dictDestination["name"], new Pos.Location({ :latitude => dictDestination["latitude"], :longitude => dictDestination["longitude"], :format => :degrees}), dictDestination["elevation"]);

    // ... tones
    self.muteTones();
  }

  function onSensorEvent(_oInfo) {
    //Sys.println("DEBUG: GSK_App.onSensorEvent());

    // Process altimeter data
    var oActivityInfo = Activity.getActivityInfo();  // ... we need *raw ambient* pressure
    if(oActivityInfo has :rawAmbientPressure and oActivityInfo.rawAmbientPressure != null) {
      $.GSK_oAltimeter.setQFE(oActivityInfo.rawAmbientPressure);
    }

    // Process sensor data
    $.GSK_oProcessing.processSensorInfo(_oInfo, Time.now().value());

    // Save FIT fields
    if($.GSK_oActivity != null) {
      $.GSK_oActivity.setBarometricAltitude($.GSK_oProcessing.fAltitude);
      if($.GSK_oSettings.iVariometerMode == 0) {
        $.GSK_oActivity.setVerticalSpeed($.GSK_oProcessing.fVariometer);
      }
      $.GSK_oActivity.setAcceleration($.GSK_oProcessing.fAcceleration);
    }
  }

  function onLocationEvent(_oInfo) {
    //Sys.println("DEBUG: GSK_App.onLocationEvent()");
    var oTimeNow = Time.now();
    var iEpoch = oTimeNow.value();

    // Save location
    if(_oInfo has :position) {
      $.GSK_oPositionLocation = _oInfo.position;
    }

    // Save altitude
    if(_oInfo has :altitude) {
      $.GSK_oPositionAltitude = _oInfo.altitude;
    }

    // Process position data
    $.GSK_oProcessing.processPositionInfo(_oInfo, iEpoch);
    if($.GSK_oActivity != null) {
      $.GSK_oActivity.processPositionInfo(_oInfo, iEpoch, oTimeNow);
    }

    // Automatic Activity recording
    if($.GSK_oSettings.bGeneralAutoActivity and $.GSK_oProcessing.fGroundSpeed != null) {
      if($.GSK_oActivity == null) {
        if($.GSK_oProcessing.fGroundSpeed > 10.0f) {  // 10 m/s = 36km/h
          $.GSK_oActivity = new GSK_Activity();
          $.GSK_oActivity.start();
        }
      }
      else {
        if($.GSK_oProcessing.fGroundSpeed < 5.0f) {  // 5 m/s = 18km/h
          $.GSK_oActivity.pause();
        }
        else if(!$.GSK_oActivity.isRecording() and $.GSK_oProcessing.fGroundSpeed > 10.0f) {  // 10 m/s = 36km/h
          $.GSK_oActivity.addLap();
          $.GSK_oActivity.resume();
        }
      }
    }

    // UI update
    self.updateUi(iEpoch);

    // Save FIT fields
    if($.GSK_oActivity != null) {
      if($.GSK_oSettings.iVariometerMode == 1) {
        $.GSK_oActivity.setVerticalSpeed($.GSK_oProcessing.fVariometer);
      }
      $.GSK_oActivity.setRateOfTurn($.GSK_oProcessing.fRateOfTurn);
    }
  }

  function onUpdateTimer_init() {
    //Sys.println("DEBUG: GSK_App.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    self.oUpdateTimer.start(method(:onUpdateTimer), 5000, true);
  }

  function onUpdateTimer() {
    //Sys.println("DEBUG: GSK_App.onUpdateTimer()");
    var iEpoch = Time.now().value();
    if(iEpoch-self.iUpdateLastEpoch > 1) {
      self.updateUi(iEpoch);
    }
  }

  function onTonesTimer() {
    //Sys.println("DEBUG: GSK_App.onTonesTimer()");
    self.playTones();
    self.iTonesTick++;
  }

  function updateUi(_iEpoch) {
    //Sys.println("DEBUG: GSK_App.updateUi()");

    // Check sensor data age
    if($.GSK_oProcessing.iSensorEpoch != null and _iEpoch-$.GSK_oProcessing.iSensorEpoch > 10) {
      $.GSK_oProcessing.resetSensorData();
      $.GSK_oAltimeter.reset();
    }

    // Check position data age
    if($.GSK_oProcessing.iPositionEpoch != null and _iEpoch-$.GSK_oProcessing.iPositionEpoch > 10) {
      $.GSK_oProcessing.resetPositionData();
    }

    // Update UI
    if($.GSK_oCurrentView != null) {
      $.GSK_oCurrentView.updateUi();
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
      if(_iTones & self.TONES_SAFETY and $.GSK_oSettings.bSoundsSafetyTones) {
        self.iTones |= self.TONES_SAFETY;
      }
      if(_iTones & self.TONES_VARIOMETER and $.GSK_oSettings.bSoundsVariometerTones) {
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
    //Sys.println(Lang.format("DEBUG: GSK_App.playTones() @ $1$", [self.iTonesTick]));

    // Check mute distance
    if($.GSK_oSettings.fSoundsMuteDistance > 0.0f
       and $.GSK_oProcessing.fDistanceToDestination != null
       and $.GSK_oProcessing.fDistanceToDestination <= $.GSK_oSettings.fSoundsMuteDistance) {
      //Sys.println(Lang.format("DEBUG: playTone: mute! @ $1$ ($2$ <= $3$)", [self.iTonesTick, $.GSK_oProcessing.fDistanceToDestination, $.GSK_oSettings.fSoundsMuteDistance]));
      return;
    }

    // Alert tones (priority over variometer)
    if(self.iTones & self.TONES_SAFETY) {
      if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {  // position accuracy is good enough
        if($.GSK_oProcessing.bDecision and !$.GSK_oProcessing.bGrace) {
          if($.GSK_oProcessing.bAltitudeCritical and self.iTonesTick-self.iTonesLastTick >= (self.iTones & self.TONES_VARIOMETER ? 10 : 1)) {
            //Sys.println(Lang.format("DEBUG: playTone = altitude critical @ $1$", [self.iTonesTick]));
            Attn.playTone(Attn.TONE_LOUD_BEEP);
            self.iTonesLastTick = self.iTonesTick;
            return;
          }
          else if($.GSK_oProcessing.bAltitudeWarning and self.iTonesTick-self.iTonesLastTick >= (self.iTones & self.TONES_VARIOMETER ? 30 : 3)) {
            //Sys.println(Lang.format("DEBUG: playTone: altitude warning @ $1$", [self.iTonesTick]));
            Attn.playTone(Attn.TONE_LOUD_BEEP);
            self.iTonesLastTick = self.iTonesTick;
            return;
          }
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
      var fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fVariometer_filtered : $.GSK_oProcessing.fVariometer;
      if(fValue != null and fValue > 0.05f) {
        if(self.iTonesTick-self.iTonesLastTick >= 20.0f-18.0f*fValue/$.GSK_oSettings.fVariometerRange) {
          //Sys.println(Lang.format("DEBUG: playTone: variometer @ $1$", [self.iTonesTick]));
          Attn.playTone(Attn.TONE_KEY);
          self.iTonesLastTick = self.iTonesTick;
          return;
        }
      }
    }
  }

  function importStorageData(_sFile) {
    //Sys.println(Lang.format("DEBUG: GSK_App.importStorageData($1$)", [_sFile]));

    Comm.makeWebRequest(Lang.format("$1$/$2$.json", [App.Properties.getValue("userStorageRepositoryURL"), _sFile]),
                        null,
                        { :method => Comm.HTTP_REQUEST_METHOD_GET, :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON },
                        method(:onStorageDataReceive));
  }

  function onStorageDataReceive(_iResponseCode, _dictData) {
    //Sys.println(Lang.format("DEBUG: GSK_App.onStorageDataReceive($1$, ...)", [_iResponseCode]));

    // Check response code
    if(_iResponseCode != 200) {
      if(Attn has :playTone) {
        Attn.playTone(Attn.TONE_FAILURE);
      }
      return;
    }

    // Validate (!) and store data

    // .. .destinations
    if(_dictData.hasKey("destinations")) {
      var dictDestinations = _dictData.get("destinations");
      for(var n=0; n<$.GSK_STORAGE_SLOTS; n++) {
        var s = n.format("%02d");
        if(dictDestinations.hasKey(s)) {
          var dictDestination = dictDestinations.get(s);
          if(dictDestination.size() == 4 and
             dictDestination.hasKey("name") and
             dictDestination.hasKey("latitude") and
             dictDestination.hasKey("longitude") and
             dictDestination.hasKey("elevation")) {
            App.Storage.setValue(Lang.format("storDest$1$", [s]), LangUtils.copy(dictDestination));
          }
        }
      }
    }

    // Done
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_SUCCESS);
    }
  }

  function clearStorageData() {
    //Sys.println("DEBUG: GSK_App.clearStorageData()");

    // Delete all storage data

    // .. .destinations
    for(var n=0; n<$.GSK_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      App.Storage.deleteValue(Lang.format("storDest$1$", [s]));
    }
  }

}
