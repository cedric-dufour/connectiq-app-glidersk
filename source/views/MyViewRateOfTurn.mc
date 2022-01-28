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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewRateOfTurn extends MyView {

  //
  // VARIABLES
  //

  // Resources
  // ... fonts
  private var oRezFontMeter as Ui.FontResource?;
  private var oRezFontStatus as Ui.FontResource?;

  // Layout-specific
  private var iLayoutCenter as Number = 120;
  private var iLayoutValueR as Number = 60;
  private var iLayoutCacheY as Number = 100;
  private var iLayoutCacheR as Number = 90;
  private var iLayoutBatteryY as Number = 128;
  private var iLayoutActivityY as Number = 55;
  private var iLayoutTimeY as Number = 142;
  private var iLayoutHeadingY as Number = 22;
  private var iLayoutValueY as Number = 63;
  private var iLayoutUnitY as Number = 200;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() as Void {
    self.iLayoutCenter = 120;
    self.iLayoutValueR = 60;
    self.iLayoutCacheY = 100;
    self.iLayoutCacheR = 90;
    self.iLayoutBatteryY = 128;
    self.iLayoutActivityY = 55;
    self.iLayoutTimeY = 142;
    self.iLayoutHeadingY = 22;
    self.iLayoutValueY = 63;
    self.iLayoutUnitY = 200;
  }

  (:layout_260x260)
  function initLayout() as Void {
    self.iLayoutCenter = 130;
    self.iLayoutValueR = 65;
    self.iLayoutCacheY = 108;
    self.iLayoutCacheR = 98;
    self.iLayoutBatteryY = 139;
    self.iLayoutActivityY = 60;
    self.iLayoutTimeY = 154;
    self.iLayoutHeadingY = 24;
    self.iLayoutValueY = 68;
    self.iLayoutUnitY = 217;
  }

  (:layout_280x280)
  function initLayout() as Void {
    self.iLayoutCenter = 140;
    self.iLayoutValueR = 70;
    self.iLayoutCacheY = 120;
    self.iLayoutCacheR = 105;
    self.iLayoutBatteryY = 149;
    self.iLayoutActivityY = 64;
    self.iLayoutTimeY = 166;
    self.iLayoutHeadingY = 26;
    self.iLayoutValueY = 74;
    self.iLayoutUnitY = 233;
  }


  //
  // FUNCTIONS: MyView (override/implement)
  //

  function initialize() {
    MyView.initialize();

    // Layout-specific initialization
    self.initLayout();
  }

  function onLayout(_oDC) {
    //Sys.println("DEBUG: MyViewRateOfTurn.onLayout()");
    // No layout; see drawLayout() below

    // Load resources
    // ... fonts
    self.oRezFontMeter = Ui.loadResource(Rez.Fonts.fontMeter) as Ui.FontResource;
    self.oRezFontStatus = Ui.loadResource(Rez.Fonts.fontStatus) as Ui.FontResource;
  }

  function onShow() {
    //Sys.println("DEBUG: MyViewRateOfTurn.onShow()");
    MyView.onShow();

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones(MyApp.TONES_SAFETY);
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyViewRateOfTurn.onUpdate()");
    MyView.onUpdate(_oDC);

    // Draw layout
    self.drawLayout(_oDC);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewRateOfTurn.onHide()");
    MyView.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }


  //
  // FUNCTIONS: self (cont'd)
  //

  function drawLayout(_oDC) {
    // Draw background
    _oDC.setPenWidth(self.iLayoutCenter);

    // ... background
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    // ... rate of turn
    var fValue;
    var iColor = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    _oDC.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 285, 255);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, $.oMySettings.iGeneralBackgroundColor);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_CLOCKWISE, 285, 255);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 1 ? $.oMyProcessing.fRateOfTurn_filtered : $.oMyProcessing.fRateOfTurn;
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      if(fValue > 0.0f) {
        iColor = Gfx.COLOR_DK_GREEN;
        //var iAngle = (fValue * 900.0f/Math.PI).toNumber();  // ... range 6 rpm <-> 36 °/s
        var iAngle = (fValue * 286.4788975654f).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(iColor, iColor);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_CLOCKWISE, 90, 90-iAngle);
        }
      }
      else if(fValue < 0.0f) {
        iColor = Gfx.COLOR_RED;
        //var iAngle = -(fValue * 900.0f/Math.PI).toNumber();  // ... range 6 rpm <-> 36 °/s
        var iAngle = -(fValue * 286.4788975654f).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(iColor, iColor);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 90, 90+iAngle);
        }
      }
    }

    // ... cache
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, $.oMySettings.iGeneralBackgroundColor);
    _oDC.fillCircle(self.iLayoutCenter, self.iLayoutCacheY, self.iLayoutCacheR);

    // Draw non-position values
    var sValue;

    // ... battery
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    sValue = format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutBatteryY, self.oRezFontStatus as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.oMyActivity == null) {  // ... stand-by
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityStandby;
    }
    else if(($.oMyActivity as MyActivity).isRecording()) {  // ... recording
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityPaused;
    }
    _oDC.drawText(self.iLayoutCenter, self.iLayoutActivityY, self.oRezFontStatus as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutTimeY, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values

    // ... heading
    fValue = $.oMySettings.iGeneralDisplayFilter >= 2 ? $.oMyProcessing.fHeading_filtered : $.oMyProcessing.fHeading;
    if(LangUtils.notNaN(fValue) and $.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      //fValue = ((fValue * 180.0f/Math.PI).toNumber()) % 360;
      fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCenter, self.iLayoutHeadingY, Gfx.FONT_MEDIUM, format("$1$°", [sValue]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... rate of turn
    fValue = $.oMySettings.iGeneralDisplayFilter >= 1 ? $.oMyProcessing.fRateOfTurn_filtered : $.oMyProcessing.fRateOfTurn;
    if(LangUtils.notNaN(fValue) and $.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      fValue *= $.oMySettings.fUnitRateOfTurnCoefficient;
      if($.oMySettings.iUnitRateOfTurn == 1) {
        sValue = fValue.format("%+.1f");
        if(fValue <= -0.05f or fValue >= 0.05f) {
          _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if(fValue <= -0.05f or fValue >= 0.5f) {
          _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
        }
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCenter, self.iLayoutValueY, self.oRezFontMeter as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCenter, self.iLayoutUnitY, Gfx.FONT_TINY, $.oMySettings.sUnitRateOfTurn, Gfx.TEXT_JUSTIFY_CENTER);
  }
}

class MyViewRateOfTurnDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewRateOfTurnDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewSafety(),
                    new MyViewSafetyDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewRateOfTurnDelegate.onNextPage()");
    Ui.switchToView(new MyViewVariometer(),
                    new MyViewVariometerDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
