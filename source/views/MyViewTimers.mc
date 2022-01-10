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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewTimers extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Resources (cache)
  // ... fields (units)
  private var oRezUnitRight;
  private var oRezUnitBottomRight;
  // ... strings
  private var sUnitElapsed;
  private var sUnitDistance_fmt;
  private var sUnitAscent_fmt;

  // Internals
  // ... fields
  private var iFieldIndex;
  private var iFieldEpoch;


  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();

    // Internals
    // ... fields
    self.iFieldIndex = 0;
    self.iFieldEpoch = Time.now().value();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGlobal.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitRight = View.findDrawableById("unitRight");
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight");
    // ... strings
    self.sUnitElapsed = Ui.loadResource(Rez.Strings.labelElapsed).toLower();
    self.sUnitDistance_fmt = Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.labelDistance).toLower(), $.oMySettings.sUnitDistance]);
    self.sUnitAscent_fmt = Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.labelAscent).toLower(), $.oMySettings.sUnitElevation]);

    // Set colors (value-independent), labels and units
    // ... activity: start
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelActivity));
    View.findDrawableById("unitTopLeft").setText(Ui.loadResource(Rez.Strings.labelStart).toLower());
    // ... activity: elapsed
    View.findDrawableById("unitTopRight").setText(self.sUnitElapsed);
    // ... lap: start
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelLap));
    View.findDrawableById("unitLeft").setText(Ui.loadResource(Rez.Strings.labelStart).toLower());
    // ... lap: count
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelCount).toLower());
    // ... lap: elapsed/distance/ascent (dynamic)
    self.oRezUnitRight.setText(self.sUnitElapsed);
    // ... recording: start
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelRecording));
    View.findDrawableById("unitBottomLeft").setText(Ui.loadResource(Rez.Strings.labelStart).toLower());
    // ... recording: elapsed/distance/ascent (dynamic)
    self.oRezUnitBottomRight.setText(self.sUnitElapsed);

    // Unmute tones
    App.getApp().unmuteTones(MyApp.TONES_SAFETY);
  }

  function updateLayout() {
    //Sys.println("DEBUG: MyViewGlobal.updateLayout()");
    MyViewGlobal.updateLayout(true);

    // Fields
    var iEpochNow = Time.now().value();
    if(iEpochNow - self.iFieldEpoch >= 2) {
      self.iFieldIndex = (self.iFieldIndex + 1) % 3;
      self.iFieldEpoch = iEpochNow;
    }

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or $.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values
    var oTimeNow = Time.now();
    var bRecording = ($.oMyActivity != null);
    var fValue;
    var sValue;

    // ... activity: start
    self.oRezValueTopLeft.setColor(self.iColorText);
    if($.oMyTimeStart != null) {
      sValue = LangUtils.formatTime($.oMyTimeStart, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... activity: elapsed
    self.oRezValueTopRight.setColor(self.iColorText);
    if($.oMyTimeStart != null) {
      sValue = LangUtils.formatElapsedTime($.oMyTimeStart, oTimeNow, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... lap: start
    self.oRezValueLeft.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      sValue = LangUtils.formatTime($.oMyActivity.oTimeLap, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... lap: count
    self.oRezValueCenter.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null and $.oMyActivity.iCountLaps) {
      sValue = $.oMyActivity.iCountLaps.format("%d");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... lap: elapsed
    self.oRezValueRight.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      if(self.iFieldIndex == 0) {  // ... elapsed
        self.oRezUnitRight.setText(self.sUnitElapsed);
        if(bRecording) {
          sValue = LangUtils.formatElapsedTime($.oMyActivity.oTimeLap, oTimeNow, false);
        }
        else {
          sValue = LangUtils.formatElapsedTime($.oMyActivity.oTimeLap, $.oMyActivity.oTimeStop, false);
        }
      }
      else if(self.iFieldIndex == 1) {  // ... distance
        self.oRezUnitRight.setText(self.sUnitDistance_fmt);
        fValue = $.oMyActivity.fDistance * $.oMySettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {  // ... ascent
        self.oRezUnitRight.setText(self.sUnitAscent_fmt);
        fValue = $.oMyActivity.fAscent * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
    }
    else {
      self.oRezUnitBottomRight.setText(self.sUnitElapsed);
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... recording: start
    self.oRezValueBottomLeft.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      sValue = LangUtils.formatTime($.oMyActivity.oTimeStart, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... recording: elapsed
    self.oRezValueBottomRight.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      if(self.iFieldIndex == 0) {  // ... elapsed
        self.oRezUnitBottomRight.setText(self.sUnitElapsed);
        if(bRecording) {
          sValue = LangUtils.formatElapsedTime($.oMyActivity.oTimeStart, oTimeNow, false);
        }
        else {
          sValue = LangUtils.formatElapsedTime($.oMyActivity.oTimeStart, $.oMyActivity.oTimeStop, false);
        }
      }
      else if(self.iFieldIndex == 1) {  // ... distance
        self.oRezUnitBottomRight.setText(self.sUnitDistance_fmt);
        fValue = $.oMyActivity.fGlobalDistance * $.oMySettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {  // ... ascent
        self.oRezUnitBottomRight.setText(self.sUnitAscent_fmt);
        fValue = $.oMyActivity.fGlobalAscent * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
    }
    else {
      self.oRezUnitBottomRight.setText(self.sUnitElapsed);
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGlobal.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    App.getApp().muteTones();
  }

}

class MyViewTimersDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewTimersDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewLog(),
                    new MyViewLogDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewTimersDelegate.onNextPage()");
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
