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
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var GSK_ViewSafety_ShowSettings = false;
var GSK_ViewSafety_SelectFields = false;
var GSK_ViewSafety_ShowElevationAtDestination = false;
var GSK_ViewSafety_ShowSpeedToDestination = false;

class ViewSafety extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;
  private var bShowSettings;
  private var bShowElevationAtDestination;
  private var bShowSpeedToDestination;

  // Resources
  // ... drawable
  private var oRezDrawableHeader;
  private var oRezDrawableGlobal;
  // ... header
  private var oRezLabelAppName;
  private var oRezValueBatteryLevel;
  private var oRezValueActivityStatus;
  // ... fields
  private var oRezValueTopLeft;
  private var oRezValueTopRight;
  private var oRezValueLeft;
  private var oRezValueCenter;
  private var oRezValueRight;
  private var oRezValueBottomLeft;
  private var oRezValueBottomRight;
  // ... footer
  private var oRezValueTime;
  // ... buttons
  private var oRezButtonKeyUp;
  private var oRezButtonKeyDown;
  // ... strings
  private var sValueActivityStandby;
  private var sValueActivityRecording;
  private var sValueActivityPaused;
  private var sValueHeightGround;

  // Settings (cache)
  // ... beautified units
  private var sUnitDistance_layout;
  private var sUnitHorizontalSpeed_layout;
  private var sUnitElevation_layout;
  private var sUnitVerticalSpeed_layout;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode
    // ... internal
    self.bShow = false;
    self.bShowSettings = false;
    self.bShowElevationAtDestination = false;
    self.bShowSpeedToDestination = false;
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.LayoutGlobal(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("DrawableHeader");
    self.oRezDrawableGlobal = View.findDrawableById("DrawableGlobal");
    // ... header
    self.oRezLabelAppName = View.findDrawableById("labelAppName");
    self.oRezValueBatteryLevel = View.findDrawableById("valueBatteryLevel");
    self.oRezValueActivityStatus = View.findDrawableById("valueActivityStatus");
    // ... fields
    self.oRezValueTopLeft = View.findDrawableById("valueTopLeft");
    self.oRezValueTopRight = View.findDrawableById("valueTopRight");
    self.oRezValueLeft = View.findDrawableById("valueLeft");
    self.oRezValueCenter = View.findDrawableById("valueCenter");
    self.oRezValueRight = View.findDrawableById("valueRight");
    self.oRezValueBottomLeft = View.findDrawableById("valueBottomLeft");
    self.oRezValueBottomRight = View.findDrawableById("valueBottomRight");
    // ... footer
    self.oRezValueTime = View.findDrawableById("valueTime");

    // Done
    return true;
  }

  function onShow() {
    //Sys.println("DEBUG: ViewSafety.onShow()");

    // Load resources
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);
    self.sValueHeightGround = Ui.loadResource(Rez.Strings.valueHeightGround);

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors
    var iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableHeader.setColorBackground($.GSK_Settings.iBackgroundColor);
    // ... battery level
    self.oRezValueBatteryLevel.setColor(iColorText);
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Unmute tones
    App.getApp().unmuteTones(GskApp.TONES_SAFETY);

    // Done
    self.bShow = true;
    self.bShowSettings = !$.GSK_ViewSafety_ShowSettings;  // ... force adaptLayout()
    $.GSK_CurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: ViewSafety.onUpdate()");

    // Update layout
    if(!$.GSK_ViewSafety_ShowSettings) {
      self.updateLayoutSafety();
    }
    else {
      self.updateLayoutSettings();
    }
    View.onUpdate(_oDC);

    // Draw buttons
    if($.GSK_ViewSafety_SelectFields) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null) {
        self.oRezButtonKeyUp = new Rez.Drawables.drawButtonTopLeft();
        self.oRezButtonKeyDown = new Rez.Drawables.drawButtonBottomRight();
      }
      self.oRezButtonKeyUp.draw(_oDC);
      self.oRezButtonKeyDown.draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: ViewSafety.onHide()");
    $.GSK_CurrentView = null;
    self.bShow = false;
    $.GSK_ViewSafety_ShowSettings = false;
    $.GSK_ViewSafety_SelectFields = false;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
    // ... strings
    self.sValueActivityStandby = null;
    self.sValueActivityRecording = null;
    self.sValueActivityPaused = null;
    self.sValueHeightGround = null;
  }


  //
  // FUNCTIONS: self
  //

  function reloadSettings() {
    //Sys.println("DEBUG: ViewSafety.reloadSettings()");

    // (Re)load settings
    App.getApp().loadSettings();

    // Units beautifying
    self.sUnitDistance_layout = "["+$.GSK_Settings.sUnitDistance+"]";
    self.sUnitHorizontalSpeed_layout = "["+$.GSK_Settings.sUnitHorizontalSpeed+"]";
    self.sUnitElevation_layout = "["+$.GSK_Settings.sUnitElevation+"]";
    self.sUnitVerticalSpeed_layout = "["+$.GSK_Settings.sUnitVerticalSpeed+"]";
  }

  function updateUi() {
    //Sys.println("DEBUG: ViewSafety.updateUi()");

    // Request UI update
    if(self.bShow and !$.GSK_ViewSafety_ShowSettings) {
      Ui.requestUpdate();
    }
  }

  function adaptLayoutSafety() {
    //Sys.println("DEBUG: ViewSafety.adaptLayoutSafety()");

    // Set colors (value-independent), labels and units
    // ... background
    var iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... application name
    self.oRezLabelAppName.setColor(Gfx.COLOR_TRANSPARENT);
    // ... destination (name) / elevation at destination
    if(!$.GSK_ViewSafety_ShowElevationAtDestination) {  // ... destination (name)
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
      View.findDrawableById("unitTopLeft").setText("");
    }
    else {  // ... elevation at destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
      View.findDrawableById("unitTopLeft").setText(self.sUnitElevation_layout);
    }
    // ... distance to destination
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelDistanceToDestination));
    View.findDrawableById("unitTopRight").setText(self.sUnitDistance_layout);
    // ... altitude
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelAltitude));
    View.findDrawableById("unitLeft").setText(self.sUnitElevation_layout);
    // ... finesse
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... height at destination
    View.findDrawableById("labelRight").setText(Ui.loadResource(Rez.Strings.labelHeightAtDestination));
    View.findDrawableById("unitRight").setText(self.sUnitElevation_layout);
    // ... vertical speed
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed));
    View.findDrawableById("unitBottomLeft").setText(self.sUnitVerticalSpeed_layout);
    // ... ground speed / speed-to(wards)-destination
    if(!$.GSK_ViewSafety_ShowSpeedToDestination) {  // ... ground speed
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    }
    else {  // ... speed-to(wards)-destination
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelSpeedToDestination));
    }
    View.findDrawableById("unitBottomRight").setText(self.sUnitHorizontalSpeed_layout);
  }

  function updateLayoutSafety() {
    //Sys.println("DEBUG: ViewSafety.updateLayoutSafety()");

    // Adapt the layout
    if(self.bShowSettings != $.GSK_ViewSafety_ShowSettings
       or self.bShowElevationAtDestination != $.GSK_ViewSafety_ShowElevationAtDestination
       or self.bShowSpeedToDestination != $.GSK_ViewSafety_ShowSpeedToDestination
       ) {
      self.adaptLayoutSafety();
      self.bShowSettings = $.GSK_ViewSafety_ShowSettings;
      self.bShowElevationAtDestination = $.GSK_ViewSafety_ShowElevationAtDestination;
      self.bShowSpeedToDestination = $.GSK_ViewSafety_ShowSpeedToDestination;
    }


    // Set header/footer values
    var sValue;

    // ... position accuracy
    self.oRezDrawableHeader.setPositionAccuracy($.GSK_Processing.iAccuracy);

    // ... battery level
    self.oRezValueBatteryLevel.setText(Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]));

    // ... activity status
    if($.GSK_ActivitySession == null) {  // ... stand-by
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_LT_GRAY);
      sValue = self.sValueActivityStandby;
    }
    else if($.GSK_ActivitySession.isRecording()) {  // ... recording
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_RED);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_YELLOW);
      sValue = self.sValueActivityPaused;
    }
    self.oRezValueActivityStatus.setText(sValue);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_Settings.bTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_Settings.sUnitTime]));

    // Set position values (and dependent colors)
    var fValue;
    var iColorText;
    if($.GSK_Processing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_DK_RED);
      self.oRezValueTopLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueTopRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      self.oRezValueLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      self.oRezValueCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setText($.GSK_NOVALUE_LEN2);
      self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GRAY);
      self.oRezValueRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomRight.setText($.GSK_NOVALUE_LEN3);
      return;
    }
    else if($.GSK_Processing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_DK_RED);
      iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_TRANSPARENT);
      iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }

    // ... destination (name) / elevation at destination
    self.oRezValueTopLeft.setColor(Gfx.COLOR_BLUE);
    if(!$.GSK_ViewSafety_ShowElevationAtDestination) {  // ... destination (name)
      if($.GSK_Processing.sDestinationName != null) {
        sValue = $.GSK_Processing.sDestinationName;
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else {  // ... elevation at destination
      if($.GSK_Processing.fDestinationElevation != null) {
        fValue = $.GSK_Processing.fDestinationElevation * $.GSK_Settings.fUnitElevationConstant;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... distance to destination
    self.oRezValueTopRight.setColor(iColorText);
    if($.GSK_Processing.fDistanceToDestination != null) {
      fValue = $.GSK_Processing.fDistanceToDestination * $.GSK_Settings.fUnitDistanceConstant;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezValueLeft.setColor(iColorText);
    if($.GSK_Processing.fAltitude != null) {
      if(!$.GSK_Processing.bSafetyStateful) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      }
      else if($.GSK_Processing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_RED);
      }
      else if($.GSK_Processing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_YELLOW);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_GREEN);
      }
      fValue = $.GSK_Processing.fAltitude * $.GSK_Settings.fUnitElevationConstant;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezValueCenter.setColor(iColorText);
    if($.GSK_Processing.fFinesse != null) {
      if($.GSK_Processing.bAscent) {
        if($.GSK_Processing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          self.oRezValueCenter.setColor(Gfx.COLOR_DK_GRAY);
        }
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_GREEN);

      }
      else if($.GSK_Processing.fFinesse <= $.GSK_Settings.iFinesseReference) {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_RED);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_YELLOW);
      }
      fValue = $.GSK_Processing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... height at destination
    self.oRezValueRight.setColor(iColorText);
    if($.GSK_Processing.fHeightAtDestination != null) {
      if($.GSK_Processing.iAccuracy > Pos.QUALITY_LAST_KNOWN and $.GSK_Processing.bEstimation) {
        self.oRezValueRight.setColor(Gfx.COLOR_DK_GRAY);
      }
      if($.GSK_Processing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_RED);
      }
      else if($.GSK_Processing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_YELLOW);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_GREEN);
      }
      if($.GSK_Processing.fHeightAtDestination <= 0.0f) {
        sValue = self.sValueHeightGround;
      }
      else {
        fValue = $.GSK_Processing.fHeightAtDestination * $.GSK_Settings.fUnitElevationConstant;
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... variometer
    self.oRezValueBottomLeft.setColor(iColorText);
    if($.GSK_Processing.fVariometer != null) {
      if($.GSK_Processing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
        if($.GSK_Processing.fVariometer > 0.0f) {
          self.oRezValueBottomLeft.setColor($.GSK_Settings.iBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
        }
        else if($.GSK_Processing.fVariometer < 0.0f) {
          self.oRezValueBottomLeft.setColor(Gfx.COLOR_RED);
        }
      }
      fValue = $.GSK_Processing.fVariometer * $.GSK_Settings.fUnitVerticalSpeedConstant;
      if($.GSK_Settings.fUnitVerticalSpeedConstant < 100.0f) {
        sValue = fValue.format("%+.1f");
      }
      else {
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... ground speed / speed-to(wards)-destination
    self.oRezValueBottomRight.setColor(iColorText);
    if(!$.GSK_ViewSafety_ShowSpeedToDestination) {  // ... ground speed
      if($.GSK_Processing.fGroundSpeed != null) {
        fValue = $.GSK_Processing.fGroundSpeed * $.GSK_Settings.fUnitHorizontalSpeedConstant;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else {  // ... speed-to(wards)-destination
      if($.GSK_Processing.fSpeedToDestination != null) {
        if($.GSK_Processing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if($.GSK_Processing.fSpeedToDestination > 0.0f) {
            self.oRezValueBottomRight.setColor($.GSK_Settings.iBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
          }
          else if($.GSK_Processing.fSpeedToDestination < 0.0f) {
            self.oRezValueBottomRight.setColor(Gfx.COLOR_RED);
          }
        }
        fValue = $.GSK_Processing.fSpeedToDestination * $.GSK_Settings.fUnitHorizontalSpeedConstant;
        sValue = fValue.format("%+.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function adaptLayoutSettings() {
    //Sys.println("DEBUG: ViewSafety.adaptLayoutSettings()");

    // Set colors (value-independent), labels and units
    // ... background
    var iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... application name
    self.oRezLabelAppName.setColor(Gfx.COLOR_BLUE);
    // ... position accuracy
    self.oRezDrawableHeader.setPositionAccuracy(null);
    // ... fields background
    self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_TRANSPARENT);
    // ... destination (name)
    self.oRezValueTopLeft.setColor(Gfx.COLOR_BLUE);
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
    View.findDrawableById("unitTopLeft").setText("");
    // ... elevation at destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_BLUE);
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
    View.findDrawableById("unitTopRight").setText(self.sUnitElevation_layout);
    // ... critical height
    self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_RED);
    self.oRezValueLeft.setColor(iColorText);
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelHeightCritical));
    View.findDrawableById("unitLeft").setText(self.sUnitElevation_layout);
    // ... reference finesse
    self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_GREEN);
    self.oRezValueCenter.setColor(iColorText);
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... warning height
    self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_YELLOW);
    self.oRezValueRight.setColor(iColorText);
    View.findDrawableById("labelRight").setText(Ui.loadResource(Rez.Strings.labelHeightWarning));
    View.findDrawableById("unitRight").setText(self.sUnitElevation_layout);
    // ... decision height
    self.oRezValueBottomLeft.setColor(iColorText);
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelHeightDecision));
    View.findDrawableById("unitBottomLeft").setText(self.sUnitElevation_layout);
    // ... time constant
    self.oRezValueBottomRight.setColor(iColorText);
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelTimeConstant));
    View.findDrawableById("unitBottomRight").setText("[s]");
  }

  function updateLayoutSettings() {
    //Sys.println("DEBUG: ViewSafety.updateLayoutSettings()");

    // Adapt the layout
    if(self.bShowSettings != $.GSK_ViewSafety_ShowSettings) {
      self.adaptLayoutSettings();
      self.bShowSettings = $.GSK_ViewSafety_ShowSettings;
    }

    // Set the values
    var fValue;
    // ... battery level
    self.oRezValueBatteryLevel.setText("");
    // ... activity status
    self.oRezValueActivityStatus.setText("");
    // ... destination (name)
    if($.GSK_Processing.sDestinationName != null) {
      self.oRezValueTopLeft.setText($.GSK_Processing.sDestinationName);
    }
    else {
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN4);
    }
    // ... elevation at destination
    if($.GSK_Processing.fDestinationElevation != null) {
      fValue = $.GSK_Processing.fDestinationElevation * $.GSK_Settings.fUnitElevationConstant;
      self.oRezValueTopRight.setText(fValue.format("%.0f"));
    }
    else {
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
    }
    // ... critical height
    fValue = $.GSK_Settings.fHeightCritical * $.GSK_Settings.fUnitElevationConstant;
    self.oRezValueLeft.setText(fValue.format("%.0f"));
    // ... reference finesse
    oRezValueCenter.setText($.GSK_Settings.iFinesseReference.format("%d"));
    // ... warning height
    fValue = $.GSK_Settings.fHeightWarning * $.GSK_Settings.fUnitElevationConstant;
    self.oRezValueRight.setText(fValue.format("%.0f"));
    // ... decision height
    fValue = $.GSK_Settings.fHeightDecision * $.GSK_Settings.fUnitElevationConstant;
    self.oRezValueBottomLeft.setText(fValue.format("%.0f"));
    // ... time constant
    self.oRezValueBottomRight.setText($.GSK_Settings.iTimeConstant.format("%d"));
    // ... current time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_Settings.bTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_Settings.sUnitTime]));
  }

}

class ViewDelegateSafety extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: ViewDelegateSafety.onMenu()");
    if($.GSK_ViewSafety_ShowSettings or $.GSK_ViewSafety_SelectFields) {
      $.GSK_ViewSafety_ShowSettings = false;
      $.GSK_ViewSafety_SelectFields = false;
      Ui.pushView(new Rez.Menus.menuSafety(), new MenuDelegateSafety(), Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.GSK_ViewSafety_ShowSettings = false;
      $.GSK_ViewSafety_SelectFields = true;
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: ViewDelegateSafety.onSelect()");
    if($.GSK_ViewSafety_ShowSettings) {
      $.GSK_ViewSafety_ShowSettings = false;
      $.GSK_ViewSafety_SelectFields = true;
      Ui.requestUpdate();
    }
    else if($.GSK_ViewSafety_SelectFields) {
      $.GSK_ViewSafety_ShowSettings = true;
      $.GSK_ViewSafety_SelectFields = false;
      Ui.requestUpdate();
    }
    else if($.GSK_ActivitySession == null) {
      Ui.pushView(new MenuActivityStart(), new MenuDelegateActivityStart(), Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new Rez.Menus.menuActivity(), new MenuDelegateActivity(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: ViewDelegateSafety.onBack()");
    if($.GSK_ViewSafety_ShowSettings or $.GSK_ViewSafety_SelectFields) {
      $.GSK_ViewSafety_ShowSettings = false;
      $.GSK_ViewSafety_SelectFields = false;
      Ui.requestUpdate();
      return true;
    }
    else if($.GSK_ActivitySession != null) {
      App.getApp().lapActivity();
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: ViewDelegateSafety.onPreviousPage()");
    if($.GSK_ViewSafety_SelectFields) {
      $.GSK_ViewSafety_ShowElevationAtDestination = !$.GSK_ViewSafety_ShowElevationAtDestination;
      Ui.requestUpdate();
    }
    else if(!$.GSK_ViewSafety_ShowSettings) {
      Ui.switchToView(new ViewGlobal(), new ViewDelegateGlobal(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: ViewDelegateSafety.onNextPage()");
    if($.GSK_ViewSafety_SelectFields) {
      $.GSK_ViewSafety_ShowSpeedToDestination = !$.GSK_ViewSafety_ShowSpeedToDestination;
      Ui.requestUpdate();
    }
    else if(!$.GSK_ViewSafety_ShowSettings) {
      Ui.switchToView(new ViewRateOfTurn(), new ViewDelegateRateOfTurn(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

}
