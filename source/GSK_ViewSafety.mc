// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
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
var GSK_ViewSafety_bShowSettings = false;
var GSK_ViewSafety_bSelectFields = false;
var GSK_ViewSafety_iFieldTopLeft = 0;
var GSK_ViewSafety_iFieldBottomRight = 0;

class GSK_ViewSafety extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;
  private var bShowSettings;
  private var bSelectFields;
  private var iFieldTopLeft;
  private var iFieldBottomRight;
  private var bProcessingEstimation;

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
    self.bSelectFields = false;
    self.iFieldTopLeft = 0;
    self.iFieldBottomRight = 0;
    self.bProcessingEstimation = true;
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.layoutGlobal(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("GSK_DrawableHeader");
    self.oRezDrawableGlobal = View.findDrawableById("GSK_DrawableGlobal");
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
    //Sys.println("DEBUG: GSK_ViewSafety.onShow()");

    // Load resources
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);
    self.sValueHeightGround = Ui.loadResource(Rez.Strings.valueHeightGround);

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors
    var iColorText = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableHeader.setColorBackground($.GSK_oSettings.iGeneralBackgroundColor);
    // ... battery level
    self.oRezValueBatteryLevel.setColor(iColorText);
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);

    // Done
    self.bShow = true;
    self.bShowSettings = !$.GSK_ViewSafety_bShowSettings;  // ... force adaptLayout()
    $.GSK_oCurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewSafety.onUpdate()");

    // Update layout
    if(!$.GSK_ViewSafety_bShowSettings) {
      self.updateLayoutSafety();
    }
    else {
      self.updateLayoutSettings();
    }
    View.onUpdate(_oDC);

    // Draw buttons
    if($.GSK_ViewSafety_bSelectFields) {
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

    // Draw bearing
    if(!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings
       and ($.GSK_oSettings.iSafetyBearingBug == 2 or ($.GSK_oSettings.iSafetyBearingBug == 1 and !$.GSK_oProcessing.bEstimation))
       and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN
       and $.GSK_oProcessing.fBearingToDestination != null
       and $.GSK_oProcessing.fHeading != null) {
      self.drawBearingBug(_oDC);
    }

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewSafety.onHide()");
    $.GSK_oCurrentView = null;
    self.bShow = false;
    $.GSK_ViewSafety_bShowSettings = false;
    $.GSK_ViewSafety_bSelectFields = false;

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
    //Sys.println("DEBUG: GSK_ViewSafety.reloadSettings()");

    // (Re)load settings
    App.getApp().loadSettings();

    // Units beautifying
    self.sUnitDistance_layout = "["+$.GSK_oSettings.sUnitDistance+"]";
    self.sUnitHorizontalSpeed_layout = "["+$.GSK_oSettings.sUnitHorizontalSpeed+"]";
    self.sUnitElevation_layout = "["+$.GSK_oSettings.sUnitElevation+"]";
    self.sUnitVerticalSpeed_layout = "["+$.GSK_oSettings.sUnitVerticalSpeed+"]";
  }

  function updateUi() {
    //Sys.println("DEBUG: GSK_ViewSafety.updateUi()");

    // Request UI update
    if(self.bShow and !$.GSK_ViewSafety_bShowSettings) {
      Ui.requestUpdate();
    }
  }

  function adaptLayoutSafety() {
    //Sys.println("DEBUG: GSK_ViewSafety.adaptLayoutSafety()");

    // Set colors (value-independent), labels and units
    // ... background
    var iColorText = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... application name
    self.oRezLabelAppName.setColor(Gfx.COLOR_TRANSPARENT);
    // ... destination (name) / elevation at destination / bearing to destination
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldTopLeft == 2) {  // ... bearing to destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelBearingToDestination));
      View.findDrawableById("unitTopLeft").setText("[°]");
    }
    else if($.GSK_ViewSafety_iFieldTopLeft == 1) {  // ... elevation at destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
      View.findDrawableById("unitTopLeft").setText(self.sUnitElevation_layout);
    }
    else {  // ... destination (name)
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
      View.findDrawableById("unitTopLeft").setText("");
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
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelSpeedToDestination));
    }
    else {  // ... ground speed
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    }
    View.findDrawableById("unitBottomRight").setText(self.sUnitHorizontalSpeed_layout);
  }

  function updateLayoutSafety() {
    //Sys.println("DEBUG: GSK_ViewSafety.updateLayoutSafety()");

    // Adapt the layout
    if(self.bShowSettings != $.GSK_ViewSafety_bShowSettings
       or self.bSelectFields != $.GSK_ViewSafety_bSelectFields
       or self.iFieldTopLeft != $.GSK_ViewSafety_iFieldTopLeft
       or self.iFieldBottomRight != $.GSK_ViewSafety_iFieldBottomRight
       or self.bProcessingEstimation != $.GSK_oProcessing.bEstimation
       ) {
      self.adaptLayoutSafety();
      self.bShowSettings = $.GSK_ViewSafety_bShowSettings;
      self.bSelectFields = $.GSK_ViewSafety_bSelectFields;
      self.iFieldTopLeft = $.GSK_ViewSafety_iFieldTopLeft;
      self.iFieldBottomRight = $.GSK_ViewSafety_iFieldBottomRight;
      self.bProcessingEstimation = $.GSK_oProcessing.bEstimation;
    }


    // Set header/footer values
    var sValue;

    // ... position accuracy
    self.oRezDrawableHeader.setPositionAccuracy($.GSK_oProcessing.iAccuracy);

    // ... battery level
    self.oRezValueBatteryLevel.setText(Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]));

    // ... activity status
    if($.GSK_Activity_oSession == null) {  // ... stand-by
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_LT_GRAY);
      sValue = self.sValueActivityStandby;
    }
    else if($.GSK_Activity_oSession.isRecording()) {  // ... recording
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
    var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_oSettings.sUnitTime]));

    // Set position values (and dependent colors)
    var fValue;
    var iColorText;
    if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
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
    else if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_DK_RED);
      iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_TRANSPARENT);
      iColorText = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }

    // ... destination (name) / elevation at destination / bearing to destination
    self.oRezValueTopLeft.setColor(Gfx.COLOR_PINK);
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldTopLeft == 2) {  // ... bearing to destination
      if($.GSK_oProcessing.fBearingToDestination != null) {
        //fValue = (($.GSK_oProcessing.fBearingToDestination * 180.0f/Math.PI).toNumber()) % 360;
        fValue = (($.GSK_oProcessing.fBearingToDestination * 57.2957795131f).toNumber()) % 360;
        sValue = fValue.format("%d");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else if($.GSK_ViewSafety_iFieldTopLeft == 1) {  // ... elevation at destination
      if($.GSK_oProcessing.fDestinationElevation != null) {
        fValue = $.GSK_oProcessing.fDestinationElevation * $.GSK_oSettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else {  // ... destination (name)
      if($.GSK_oProcessing.sDestinationName != null) {
        sValue = $.GSK_oProcessing.sDestinationName;
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... distance to destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_PINK);
    if($.GSK_oProcessing.fDistanceToDestination != null) {
      fValue = $.GSK_oProcessing.fDistanceToDestination * $.GSK_oSettings.fUnitDistanceCoefficient;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezValueLeft.setColor(iColorText);
    if($.GSK_oProcessing.fAltitude != null) {
      if(!$.GSK_oProcessing.bSafetyStateful) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      }
      else if($.GSK_oProcessing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_RED);
      }
      else if($.GSK_oProcessing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_YELLOW);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_GREEN);
      }
      fValue = $.GSK_oProcessing.fAltitude * $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezValueCenter.setColor(iColorText);
    if($.GSK_oProcessing.fFinesse != null) {
      if($.GSK_oProcessing.bAscent) {
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          self.oRezValueCenter.setColor(Gfx.COLOR_DK_GRAY);
        }
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_GREEN);

      }
      else if($.GSK_oProcessing.fFinesse <= $.GSK_oSettings.iSafetyFinesse) {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_RED);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_YELLOW);
      }
      fValue = $.GSK_oProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... height at destination
    self.oRezValueRight.setColor(iColorText);
    if($.GSK_oProcessing.fHeightAtDestination != null) {
      if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN and $.GSK_oProcessing.bEstimation) {
        self.oRezValueRight.setColor(Gfx.COLOR_DK_GRAY);
      }
      if($.GSK_oProcessing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_RED);
      }
      else if($.GSK_oProcessing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_YELLOW);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_GREEN);
      }
      if($.GSK_oProcessing.fHeightAtDestination <= 0.0f) {
        sValue = self.sValueHeightGround;
      }
      else {
        fValue = $.GSK_oProcessing.fHeightAtDestination * $.GSK_oSettings.fUnitElevationCoefficient;
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
    if($.GSK_oProcessing.fVariometer != null) {
      fValue = $.GSK_oProcessing.fVariometer * $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
      if($.GSK_oSettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.05f) {
            self.oRezValueBottomLeft.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
          }
          else if(fValue <= -0.05f) {
            self.oRezValueBottomLeft.setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            self.oRezValueBottomLeft.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
          }
          else if(fValue <= -0.5f) {
            self.oRezValueBottomLeft.setColor(Gfx.COLOR_RED);
          }
        }
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... ground speed / speed-to(wards)-destination
    self.oRezValueBottomRight.setColor(iColorText);
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      if($.GSK_oProcessing.fSpeedToDestination != null) {
        fValue = $.GSK_oProcessing.fSpeedToDestination * $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%+.0f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            self.oRezValueBottomRight.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
          }
          else if(fValue <= -0.5f) {
            self.oRezValueBottomRight.setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else {  // ... ground speed
      if($.GSK_oProcessing.fGroundSpeed != null) {
        fValue = $.GSK_oProcessing.fGroundSpeed * $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  (:layout_240x240)
  function drawBearingBug(_oDC) {
    // ... heading bug
    var fBearingRelative = $.GSK_oProcessing.fBearingToDestination - $.GSK_oProcessing.fHeading;
    _oDC.setColor(Gfx.COLOR_PURPLE, Gfx.COLOR_PURPLE);
    var aPoints =
      [[120.0f+119.0f*Math.sin(fBearingRelative), 120.0f-119.0f*Math.cos(fBearingRelative)],
       [120.0f+100.0f*Math.sin(fBearingRelative-0.125f), 120.0f-100.0f*Math.cos(fBearingRelative-0.125f)],
       [120.0f+100.0f*Math.sin(fBearingRelative+0.125f), 120.0f-100.0f*Math.cos(fBearingRelative+0.125f)]];
    _oDC.fillPolygon(aPoints);
  }

  function adaptLayoutSettings() {
    //Sys.println("DEBUG: GSK_ViewSafety.adaptLayoutSettings()");

    // Set colors (value-independent), labels and units
    // ... background
    var iColorText = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... application name
    self.oRezLabelAppName.setColor(Gfx.COLOR_BLUE);
    // ... position accuracy
    self.oRezDrawableHeader.setPositionAccuracy(null);
    // ... fields background
    self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_TRANSPARENT);
    // ... destination (name)
    self.oRezValueTopLeft.setColor(Gfx.COLOR_PINK);
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
    View.findDrawableById("unitTopLeft").setText("");
    // ... elevation at destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_PINK);
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
    //Sys.println("DEBUG: GSK_ViewSafety.updateLayoutSettings()");

    // Adapt the layout
    if(self.bShowSettings != $.GSK_ViewSafety_bShowSettings) {
      self.adaptLayoutSettings();
      self.bShowSettings = $.GSK_ViewSafety_bShowSettings;
    }

    // Set the values
    var fValue;
    // ... battery level
    self.oRezValueBatteryLevel.setText("");
    // ... activity status
    self.oRezValueActivityStatus.setText("");
    // ... destination (name)
    if($.GSK_oProcessing.sDestinationName != null) {
      self.oRezValueTopLeft.setText($.GSK_oProcessing.sDestinationName);
    }
    else {
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN4);
    }
    // ... elevation at destination
    if($.GSK_oProcessing.fDestinationElevation != null) {
      fValue = $.GSK_oProcessing.fDestinationElevation * $.GSK_oSettings.fUnitElevationCoefficient;
      self.oRezValueTopRight.setText(fValue.format("%.0f"));
    }
    else {
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
    }
    // ... critical height
    fValue = $.GSK_oSettings.fSafetyHeightCritical * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueLeft.setText(fValue.format("%.0f"));
    // ... reference finesse
    oRezValueCenter.setText($.GSK_oSettings.iSafetyFinesse.format("%d"));
    // ... warning height
    fValue = $.GSK_oSettings.fSafetyHeightWarning * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueRight.setText(fValue.format("%.0f"));
    // ... decision height
    fValue = $.GSK_oSettings.fSafetyHeightDecision * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueBottomLeft.setText(fValue.format("%.0f"));
    // ... time constant
    self.oRezValueBottomRight.setText($.GSK_oSettings.iGeneralTimeConstant.format("%d"));
    // ... current time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_oSettings.sUnitTime]));
  }

}

class GSK_ViewSafetyDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onMenu()");
    if($.GSK_ViewSafety_bShowSettings or $.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.pushView(new MenuDestination(), new MenuDestinationDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = true;
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onSelect()");
    if($.GSK_ViewSafety_bShowSettings) {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = true;
      Ui.requestUpdate();
    }
    else if($.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_bShowSettings = true;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.requestUpdate();
    }
    else if($.GSK_Activity_oSession == null) {
      Ui.pushView(new MenuActivityStart(), new MenuActivityStartDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MenuActivity(), new MenuActivityDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onBack()");
    if($.GSK_ViewSafety_bShowSettings or $.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.requestUpdate();
      return true;
    }
    else if($.GSK_Activity_oSession != null) {
      App.getApp().lapActivity();
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onPreviousPage()");
    if($.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_iFieldTopLeft = ($.GSK_ViewSafety_iFieldTopLeft + 1) % 3;
      Ui.requestUpdate();
    }
    else if(!$.GSK_ViewSafety_bShowSettings) {
      Ui.switchToView(new GSK_ViewGlobal(), new GSK_ViewGlobalDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onNextPage()");
    if($.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_iFieldBottomRight = ($.GSK_ViewSafety_iFieldBottomRight + 1) % 2;
      Ui.requestUpdate();
    }
    else if(!$.GSK_ViewSafety_bShowSettings) {
      Ui.switchToView(new GSK_ViewRateOfTurn(), new GSK_ViewRateOfTurnDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

}
