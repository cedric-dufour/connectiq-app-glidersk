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
using Toybox.Attention as Attn;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class GSK_ViewVariometer extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;

  // Resources
  // ... fonts
  private var oRezFontMeter;
  private var oRezFontStatus;
  // ... strings
  private var sValueActivityStandby;
  private var sValueActivityRecording;
  private var sValueActivityPaused;


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
    // No layout; see drawLayout() below
  }

  function onShow() {
    //Sys.println("DEBUG: GSK_ViewVariometer.onShow()");

    // Load resources
    // ... fonts
    self.oRezFontMeter = Ui.loadResource(Rez.Fonts.fontMeter);
    self.oRezFontStatus = Ui.loadResource(Rez.Fonts.fontStatus);
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);

    // Reload settings (which may have been changed by user)
    App.getApp().loadSettings();

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY | GSK_App.TONES_VARIOMETER);

    // Done
    self.bShow = true;
    $.GSK_oCurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewVariometer.onUpdate()");

    // Update layout
    View.onUpdate(_oDC);
    self.drawLayout(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewVariometer.onHide()");
    $.GSK_oCurrentView = null;
    self.bShow = false;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... fonts
    self.oRezFontMeter = null;
    self.oRezFontStatus = null;
    // ... strings
    self.sValueActivityStandby = null;
    self.sValueActivityRecording = null;
    self.sValueActivityPaused = null;
  }


  //
  // FUNCTIONS: self
  //

  function updateUi() {
    //Sys.println("DEBUG: GSK_ViewVariometer.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }


  //
  // FUNCTIONS: self (cont'd) - layout-specific
  //

  (:layout_240x240)
  function drawLayout(_oDC) {
    // Draw background
    _oDC.setPenWidth(120);

    // ... background
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    // ... variometer
    _oDC.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
    _oDC.drawArc(120, 120, 60, Gfx.ARC_COUNTER_CLOCKWISE, 15, 345);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor, $.GSK_oSettings.iGeneralBackgroundColor);
    _oDC.drawArc(120, 120, 60, Gfx.ARC_CLOCKWISE, 15, 345);
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_oProcessing.fVariometer != null) {
      if($.GSK_oProcessing.fVariometer > 0.0f) {
        var iAngle = (180.0f*$.GSK_oProcessing.fVariometer/$.GSK_oSettings.fVariometerRange).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
          _oDC.drawArc(120, 120, 60, Gfx.ARC_CLOCKWISE, 180, 180-iAngle);
        }
      }
      else if($.GSK_oProcessing.fVariometer < 0.0f) {
        var iAngle = -(180.0f*$.GSK_oProcessing.fVariometer/$.GSK_oSettings.fVariometerRange).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
          _oDC.drawArc(120, 120, 60, Gfx.ARC_COUNTER_CLOCKWISE, 180, 180+iAngle);
        }
      }
    }

    // ... text
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor, $.GSK_oSettings.iGeneralBackgroundColor);
    _oDC.fillCircle(100, 120, 90);

    // Draw non-position values
    var sValue;

    // ... battery
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    sValue = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(100, 148, self.oRezFontStatus, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.GSK_Activity_oSession == null) {  // ... stand-by
      _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityStandby;
    }
    else if($.GSK_Activity_oSession.isRecording()) {  // ... recording
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityPaused;
    }
    _oDC.drawText(100, 75, self.oRezFontStatus, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_oSettings.sUnitTime]);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(100, 162, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values
    var fValue;

    // ... altitude
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_oProcessing.fAltitude != null) {
      fValue = $.GSK_oProcessing.fAltitude * $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(100, 42, Gfx.FONT_MEDIUM, Lang.format("$1$ $2$", [sValue, $.GSK_oSettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... variometer
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_oProcessing.fVariometer != null) {
      if($.GSK_oProcessing.fVariometer > 0.0f) {
        _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
      }
      else if($.GSK_oProcessing.fVariometer < 0.0f) {
        _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      }
      fValue = $.GSK_oProcessing.fVariometer * $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
      if($.GSK_oSettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.01f");
      }
      else {
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(100, 83, self.oRezFontMeter, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(212, 105, Gfx.FONT_TINY, $.GSK_oSettings.sUnitVerticalSpeed, Gfx.TEXT_JUSTIFY_CENTER);
  }
}

class GSK_ViewVariometerDelegate extends GSK_ViewGlobalDelegate {

  function initialize() {
    GSK_ViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewVariometerDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewRateOfTurn(), new GSK_ViewRateOfTurnDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewVariometerDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewVarioplot(), new GSK_ViewVarioplotDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
