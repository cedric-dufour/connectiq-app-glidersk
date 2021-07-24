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

using Toybox.Application as App;
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

  // Layout-specific
  private var iLayoutCenter;
  private var iLayoutValueR;
  private var iLayoutCacheX;
  private var iLayoutCacheR;
  private var iLayoutBatteryY;
  private var iLayoutActivityY;
  private var iLayoutTimeY;
  private var iLayoutAltitudeY;
  private var iLayoutValueY;
  private var iLayoutUnitX;
  private var iLayoutUnitY;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() {
    self.iLayoutCenter = 120;
    self.iLayoutValueR = 60;
    self.iLayoutCacheX = 100;
    self.iLayoutCacheR = 90;
    self.iLayoutBatteryY = 148;
    self.iLayoutActivityY = 75;
    self.iLayoutTimeY = 162;
    self.iLayoutAltitudeY = 42;
    self.iLayoutValueY = 83;
    self.iLayoutUnitX = 212;
    self.iLayoutUnitY = 105;
  }

  (:layout_260x260)
  function initLayout() {
    self.iLayoutCenter = 130;
    self.iLayoutValueR = 65;
    self.iLayoutCacheX = 108;
    self.iLayoutCacheR = 98;
    self.iLayoutBatteryY = 160;
    self.iLayoutActivityY = 81;
    self.iLayoutTimeY = 176;
    self.iLayoutAltitudeY = 46;
    self.iLayoutValueY = 90;
    self.iLayoutUnitX = 230;
    self.iLayoutUnitY = 114;
  }

  (:layout_280x280)
  function initLayout() {
    self.iLayoutCenter = 140;
    self.iLayoutValueR = 70;
    self.iLayoutCacheX = 120;
    self.iLayoutCacheR = 105;
    self.iLayoutBatteryY = 173;
    self.iLayoutActivityY = 88;
    self.iLayoutTimeY = 189;
    self.iLayoutAltitudeY = 49;
    self.iLayoutValueY = 97;
    self.iLayoutUnitX = 247;
    self.iLayoutUnitY = 123;
  }

  (:layout_390x390)
  function initLayout() {
    self.iLayoutCenter = 195;
    self.iLayoutValueR = 98;
    self.iLayoutCacheX = 175;
    self.iLayoutCacheR = 155;
    self.iLayoutBatteryY = 223;
    self.iLayoutActivityY = 138;
    self.iLayoutTimeY = 259;
    self.iLayoutAltitudeY = 79;
    self.iLayoutValueY = 147;
    self.iLayoutUnitX = 347;
    self.iLayoutUnitY = 173;
  }


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Layout-specific initialization
    self.initLayout();

    // Display mode
    // ... internal
    self.bShow = false;
  }

  function onLayout(_oDC) {
    //Sys.println("DEBUG: GSK_ViewVariometer.onLayout()");
    // No layout; see drawLayout() below

    // Load resources
    // ... fonts
    self.oRezFontMeter = Ui.loadResource(Rez.Fonts.fontMeter);
    self.oRezFontStatus = Ui.loadResource(Rez.Fonts.fontStatus);
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);
  }

  function onShow() {
    //Sys.println("DEBUG: GSK_ViewVariometer.onShow()");

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
  }


  //
  // FUNCTIONS: self (cont'd)
  //

  function updateUi() {
    //Sys.println("DEBUG: GSK_ViewVariometer.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function drawLayout(_oDC) {
    // Draw background
    _oDC.setPenWidth(self.iLayoutCenter);

    // ... background
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    // ... variometer
    var fValue;
    var iColor = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    _oDC.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 15, 345);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor, $.GSK_oSettings.iGeneralBackgroundColor);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_CLOCKWISE, 15, 345);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fVariometer_filtered : $.GSK_oProcessing.fVariometer;
    if(fValue != null and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      if(fValue > 0.0f) {
        iColor = Gfx.COLOR_DK_GREEN;
        var iAngle = (180.0f*fValue/$.GSK_oSettings.fVariometerRange).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(iColor, iColor);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_CLOCKWISE, 180, 180-iAngle);
        }
      }
      else if(fValue < 0.0f) {
        iColor = Gfx.COLOR_RED;
        var iAngle = -(180.0f*fValue/$.GSK_oSettings.fVariometerRange).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(iColor, iColor);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 180, 180+iAngle);
        }
      }
    }

    // ... cache
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor, $.GSK_oSettings.iGeneralBackgroundColor);
    _oDC.fillCircle(self.iLayoutCacheX, self.iLayoutCenter, self.iLayoutCacheR);

    // Draw non-position values
    var sValue;

    // ... battery
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    sValue = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutBatteryY, self.oRezFontStatus, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.GSK_oActivity == null) {  // ... stand-by
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityStandby;
    }
    else if($.GSK_oActivity.isRecording()) {  // ... recording
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityPaused;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutActivityY, self.oRezFontStatus, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_oSettings.sUnitTime]);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutTimeY, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values

    // ... altitude
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 2 ? $.GSK_oProcessing.fAltitude_filtered : $.GSK_oProcessing.fAltitude;
    if(fValue != null and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      fValue *= $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutAltitudeY, Gfx.FONT_MEDIUM, Lang.format("$1$ $2$", [sValue, $.GSK_oSettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... variometer
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fVariometer_filtered : $.GSK_oProcessing.fVariometer;
    if(fValue != null and $.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      fValue *= $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
      if($.GSK_oSettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if(fValue <= -0.05f or fValue >= 0.05f) {
          _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if(fValue <= -0.5f or fValue >= 0.5f) {
          _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
        }
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutValueY, self.oRezFontMeter, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutUnitX, self.iLayoutUnitY, Gfx.FONT_TINY, $.GSK_oSettings.sUnitVerticalSpeed, Gfx.TEXT_JUSTIFY_CENTER);
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
