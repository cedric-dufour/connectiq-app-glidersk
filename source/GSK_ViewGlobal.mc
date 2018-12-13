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

class GSK_ViewGlobal extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;

  // Resources
  // ... drawable
  private var oRezDrawableHeader;
  private var oRezDrawableGlobal;
  // ... header
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
  // ... strings
  private var sValueActivityStandby;
  private var sValueActivityRecording;
  private var sValueActivityPaused;

  // Settings (cache)
  // ... beautified units
  private var sUnitHorizontalSpeed_layout;
  private var sUnitElevation_layout;
  private var sUnitVerticalSpeed_layout;
  private var sUnitRateOfTurn_layout;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode
    // ... internal
    self.bShow = false;
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.layoutGlobal(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("GSK_DrawableHeader");
    self.oRezDrawableGlobal = View.findDrawableById("GSK_DrawableGlobal");
    // ... header
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
    //Sys.println("DEBUG: GSK_ViewGlobal.onShow()");

    // Load resources
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors (value-independent), labels and units
    var iColorText = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableHeader.setColorBackground($.GSK_oSettings.iGeneralBackgroundColor);
    // ... battery level
    self.oRezValueBatteryLevel.setColor(iColorText);
    // ... acceleration
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelAcceleration));
    View.findDrawableById("unitTopLeft").setText("[g]");
    // ... rate of turn
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelRateOfTurn));
    View.findDrawableById("unitTopRight").setText(self.sUnitRateOfTurn_layout);
    // ... altitude
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelAltitude));
    View.findDrawableById("unitLeft").setText(self.sUnitElevation_layout);
    // ... finesse
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... heading
    View.findDrawableById("labelRight").setText(Ui.loadResource(Rez.Strings.labelHeading));
    View.findDrawableById("unitRight").setText("[°]");
    // ... vertical speed
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed));
    View.findDrawableById("unitBottomLeft").setText(self.sUnitVerticalSpeed_layout);
    // ... ground speed
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    View.findDrawableById("unitBottomRight").setText(self.sUnitHorizontalSpeed_layout);
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);

    // Done
    self.bShow = true;
    $.GSK_oCurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewGlobal.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewGlobal.onHide()");
    $.GSK_oCurrentView = null;
    self.bShow = false;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... strings
    self.sValueActivityStandby = null;
    self.sValueActivityRecording = null;
    self.sValueActivityPaused = null;
  }


  //
  // FUNCTIONS: self
  //

  function reloadSettings() {
    //Sys.println("DEBUG: GSK_ViewGlobal.reloadSettings()");

    // (Re)load settings
    App.getApp().loadSettings();

    // Units beautifying
    self.sUnitHorizontalSpeed_layout = Lang.format("[$1$]", [$.GSK_oSettings.sUnitHorizontalSpeed]);
    self.sUnitElevation_layout = Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]);
    self.sUnitVerticalSpeed_layout = Lang.format("[$1$]", [$.GSK_oSettings.sUnitVerticalSpeed]);
    self.sUnitRateOfTurn_layout = Lang.format("[$1$]", [$.GSK_oSettings.sUnitRateOfTurn]);
  }

  function updateUi() {
    //Sys.println("DEBUG: GSK_ViewGlobal.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout() {
    //Sys.println("DEBUG: GSK_ViewGlobal.updateLayout()");

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
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.oRezValueTopLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueTopRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setText($.GSK_NOVALUE_LEN2);
      self.oRezValueRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomRight.setText($.GSK_NOVALUE_LEN3);
      return;
    }
    else if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
      iColorText = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }

    // ... acceleration
    self.oRezValueTopLeft.setColor(iColorText);
    if($.GSK_oProcessing.fAcceleration != null) {
      fValue = $.GSK_oProcessing.fAcceleration;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... rate of turn
    self.oRezValueTopRight.setColor(iColorText);
    if($.GSK_oProcessing.fRateOfTurn != null) {
      fValue = $.GSK_oProcessing.fRateOfTurn * $.GSK_oSettings.fUnitRateOfTurnCoefficient;
      if($.GSK_oSettings.iUnitRateOfTurn == 1) {
        sValue = fValue.format("%+.1f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue <= -0.05f) {
            self.oRezValueTopRight.setColor(Gfx.COLOR_RED);
          }
          else if(fValue >= 0.05f) {
            self.oRezValueTopRight.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
          }
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue <= -0.5f) {
            self.oRezValueTopRight.setColor(Gfx.COLOR_RED);
          }
          else if(fValue >= 0.5f) {
            self.oRezValueTopRight.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN);
          }
        }
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezValueLeft.setColor(iColorText);
    if($.GSK_oProcessing.fAltitude != null) {
      fValue = $.GSK_oProcessing.fAltitude * $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezValueCenter.setColor(iColorText);
    if($.GSK_oProcessing.fFinesse != null and !$.GSK_oProcessing.bAscent) {
      fValue = $.GSK_oProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... heading
    self.oRezValueRight.setColor(iColorText);
    if($.GSK_oProcessing.fHeading != null) {
      //fValue = (($.GSK_oProcessing.fHeading * 180.0f/Math.PI).toNumber()) % 360;
      fValue = (($.GSK_oProcessing.fHeading * 57.2957795131f).toNumber()) % 360;
      sValue = fValue.format("%d");
    }
    else {
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

    // ... ground speed
    self.oRezValueBottomRight.setColor(iColorText);
    if($.GSK_oProcessing.fGroundSpeed != null) {
      fValue = $.GSK_oProcessing.fGroundSpeed * $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomRight.setText(sValue);
  }

}

class GSK_ViewGlobalDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: GSK_ViewGlobalDelegate.onMenu()");
    Ui.pushView(new MenuSettings(), new MenuSettingsDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: GSK_ViewGlobalDelegate.onSelect()");
    if($.GSK_Activity_oSession == null) {
      Ui.pushView(new MenuActivityStart(), new MenuActivityStartDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MenuActivity(), new MenuActivityDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: GSK_ViewGlobalDelegate.onBack()");
    if($.GSK_Activity_oSession != null) {
      App.getApp().lapActivity();
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewGlobalDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewTimers(), new GSK_ViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewGlobalDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewSafety(), new GSK_ViewSafetyDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
