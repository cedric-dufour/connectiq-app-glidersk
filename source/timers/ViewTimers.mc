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

class ViewTimers extends Ui.View {

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
    View.setLayout(Rez.Layouts.LayoutGlobal(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("DrawableHeader");
    self.oRezDrawableGlobal = View.findDrawableById("DrawableGlobal");
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
    //Sys.println("DEBUG: ViewGlobal.onShow()");

    // Load resources
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);

    // Reload settings (which may have been changed by user)
    self.reloadSettings();

    // Set colors (value-independent), labels and units
    var iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableHeader.setColorBackground($.GSK_Settings.iBackgroundColor);
    // ... battery level
    self.oRezValueBatteryLevel.setColor(iColorText);
    // ... activity: start
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelActivity));
    View.findDrawableById("unitTopLeft").setText(Ui.loadResource(Rez.Strings.unitStart));
    // ... activity: elapsed
    View.findDrawableById("unitTopRight").setText(Ui.loadResource(Rez.Strings.unitElapsed));
    // ... lap: start
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelLap));
    View.findDrawableById("unitLeft").setText(Ui.loadResource(Rez.Strings.unitStart));
    // ... lap: count
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.unitCount));
    // ... lap: elapsed
    View.findDrawableById("unitRight").setText(Ui.loadResource(Rez.Strings.unitElapsed));
    // ... recording: start
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelRecording));
    View.findDrawableById("unitBottomLeft").setText(Ui.loadResource(Rez.Strings.unitStart));
    // ... recording: elapsed
    View.findDrawableById("unitBottomRight").setText(Ui.loadResource(Rez.Strings.unitElapsed));
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Unmute tones
    App.getApp().unmuteTones(GskApp.TONES_SAFETY);

    // Done
    self.bShow = true;
    $.GSK_CurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: ViewGlobal.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: ViewGlobal.onHide()");
    $.GSK_CurrentView = null;
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
    //Sys.println("DEBUG: ViewGlobal.reloadSettings()");

    // (Re)load settings
    App.getApp().loadSettings();
  }

  function updateUi() {
    //Sys.println("DEBUG: ViewGlobal.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout() {
    //Sys.println("DEBUG: ViewGlobal.updateLayout()");

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
    var iDuration;
    var iDuration_h;
    var iDuration_m;
    var iColorText;
    if($.GSK_Processing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or $.GSK_Processing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_DK_RED);
      iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorContentBackground(Gfx.COLOR_TRANSPARENT);
      iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }

    // ... activity: start
    self.oRezValueTopLeft.setColor(iColorText);
    if($.GSK_TimeStart != null) {
      oTimeInfo = $.GSK_Settings.bTimeUTC ? Gregorian.utcInfo($.GSK_TimeStart, Time.FORMAT_SHORT) : Gregorian.info($.GSK_TimeStart, Time.FORMAT_SHORT);
      sValue = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... activity: elapsed
    self.oRezValueTopRight.setColor(iColorText);
    if($.GSK_TimeStart != null) {
      iDuration = Math.floor(oTimeNow.subtract($.GSK_TimeStart).value() / 60.0).toNumber();
      iDuration_m = iDuration % 60;
      iDuration_h = (iDuration-iDuration_m) / 60;
      sValue = Lang.format("$1$:$2$", [iDuration_h.format("%d"), iDuration_m.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... lap: start
    self.oRezValueLeft.setColor(iColorText);
    if($.GSK_ActivitySession_TimeLap != null) {
      oTimeInfo = $.GSK_Settings.bTimeUTC ? Gregorian.utcInfo($.GSK_ActivitySession_TimeLap, Time.FORMAT_SHORT) : Gregorian.info($.GSK_ActivitySession_TimeLap, Time.FORMAT_SHORT);
      sValue = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... lap: count
    self.oRezValueCenter.setColor(iColorText);
    if($.GSK_ActivitySession_CountLaps) {
      sValue = $.GSK_ActivitySession_CountLaps.format("%d");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... lap: elapsed
    self.oRezValueRight.setColor(iColorText);
    if($.GSK_ActivitySession_TimeLap != null) {
      iDuration = Math.floor(oTimeNow.subtract($.GSK_ActivitySession_TimeLap).value() / 60.0).toNumber();
      iDuration_m = iDuration % 60;
      iDuration_h = (iDuration-iDuration_m) / 60;
      sValue = Lang.format("$1$:$2$", [iDuration_h.format("%d"), iDuration_m.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... recording: start
    self.oRezValueBottomLeft.setColor(iColorText);
    if($.GSK_ActivitySession_TimeStart != null) {
      oTimeInfo = $.GSK_Settings.bTimeUTC ? Gregorian.utcInfo($.GSK_ActivitySession_TimeStart, Time.FORMAT_SHORT) : Gregorian.info($.GSK_ActivitySession_TimeStart, Time.FORMAT_SHORT);
      sValue = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... recording: elapsed
    self.oRezValueBottomRight.setColor(iColorText);
    if($.GSK_ActivitySession_TimeStart != null) {
      iDuration = Math.floor(oTimeNow.subtract($.GSK_ActivitySession_TimeStart).value() / 60.0).toNumber();
      iDuration_m = iDuration % 60;
      iDuration_h = (iDuration-iDuration_m) / 60;
      sValue = Lang.format("$1$:$2$", [iDuration_h.format("%d"), iDuration_m.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomRight.setText(sValue);
  }

}

class ViewDelegateTimers extends ViewDelegateGlobal {

  function initialize() {
    ViewDelegateGlobal.initialize();
  }

  function onKey(oEvent) {
    //Sys.println("DEBUG: ViewDelegateRateOfTurn.onKey()");
    var iKey = oEvent.getKey();
    if(iKey == Ui.KEY_UP) {
      Ui.switchToView(new ViewVarioplot(), new ViewDelegateVarioplot(), Ui.SLIDE_IMMEDIATE);
      return true;
    }
    if(iKey == Ui.KEY_DOWN) {
      Ui.switchToView(new ViewGlobal(), new ViewDelegateGlobal(), Ui.SLIDE_IMMEDIATE);
      return true;
    }
    return false;
  }

}
