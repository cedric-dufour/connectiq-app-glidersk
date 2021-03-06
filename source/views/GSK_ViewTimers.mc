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

class GSK_ViewTimers extends GSK_ViewGlobal {

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
  // FUNCTIONS: GSK_ViewGlobal (override/implement)
  //

  function initialize() {
    GSK_ViewGlobal.initialize();

    // Internals
    // ... fields
    self.iFieldIndex = 0;
    self.iFieldEpoch = Time.now().value();
  }

  function prepare() {
    //Sys.println("DEBUG: GSK_ViewGlobal.prepare()");
    GSK_ViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitRight = View.findDrawableById("unitRight");
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight");
    // ... strings
    self.sUnitElapsed = Ui.loadResource(Rez.Strings.labelElapsed).toLower();
    self.sUnitDistance_fmt = Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.labelDistance).toLower(), $.GSK_oSettings.sUnitDistance]);
    self.sUnitAscent_fmt = Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.labelAscent).toLower(), $.GSK_oSettings.sUnitElevation]);

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
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);
  }

  function updateLayout() {
    //Sys.println("DEBUG: GSK_ViewGlobal.updateLayout()");
    GSK_ViewGlobal.updateLayout(true);

    // Fields
    var iEpochNow = Time.now().value();
    if(iEpochNow - self.iFieldEpoch >= 2) {
      self.iFieldIndex = (self.iFieldIndex + 1) % 3;
      self.iFieldEpoch = iEpochNow;
    }

    // Colors
    if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or $.GSK_oProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values
    var oTimeNow = Time.now();
    var bRecording = ($.GSK_oActivity != null);
    var fValue;
    var sValue;

    // ... activity: start
    self.oRezValueTopLeft.setColor(self.iColorText);
    if($.GSK_oTimeStart != null) {
      sValue = LangUtils.formatTime($.GSK_oTimeStart, $.GSK_oSettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... activity: elapsed
    self.oRezValueTopRight.setColor(self.iColorText);
    if($.GSK_oTimeStart != null) {
      sValue = LangUtils.formatElapsedTime($.GSK_oTimeStart, oTimeNow, false);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... lap: start
    self.oRezValueLeft.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_oActivity != null) {
      sValue = LangUtils.formatTime($.GSK_oActivity.oTimeLap, $.GSK_oSettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... lap: count
    self.oRezValueCenter.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_oActivity != null and $.GSK_oActivity.iCountLaps) {
      sValue = $.GSK_oActivity.iCountLaps.format("%d");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... lap: elapsed
    self.oRezValueRight.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_oActivity != null) {
      if(self.iFieldIndex == 0) {  // ... elapsed
        self.oRezUnitRight.setText(self.sUnitElapsed);
        if(bRecording) {
          sValue = LangUtils.formatElapsedTime($.GSK_oActivity.oTimeLap, oTimeNow, false);
        }
        else {
          sValue = LangUtils.formatElapsedTime($.GSK_oActivity.oTimeLap, $.GSK_oActivity.oTimeStop, false);
        }
      }
      else if(self.iFieldIndex == 1) {  // ... distance
        self.oRezUnitRight.setText(self.sUnitDistance_fmt);
        fValue = $.GSK_oActivity.fDistance * $.GSK_oSettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {  // ... ascent
        self.oRezUnitRight.setText(self.sUnitAscent_fmt);
        fValue = $.GSK_oActivity.fAscent * $.GSK_oSettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
    }
    else {
      self.oRezUnitBottomRight.setText(self.sUnitElapsed);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... recording: start
    self.oRezValueBottomLeft.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_oActivity != null) {
      sValue = LangUtils.formatTime($.GSK_oActivity.oTimeStart, $.GSK_oSettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... recording: elapsed
    self.oRezValueBottomRight.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_oActivity != null) {
      if(self.iFieldIndex == 0) {  // ... elapsed
        self.oRezUnitBottomRight.setText(self.sUnitElapsed);
        if(bRecording) {
          sValue = LangUtils.formatElapsedTime($.GSK_oActivity.oTimeStart, oTimeNow, false);
        }
        else {
          sValue = LangUtils.formatElapsedTime($.GSK_oActivity.oTimeStart, $.GSK_oActivity.oTimeStop, false);
        }
      }
      else if(self.iFieldIndex == 1) {  // ... distance
        self.oRezUnitBottomRight.setText(self.sUnitDistance_fmt);
        fValue = $.GSK_oActivity.fGlobalDistance * $.GSK_oSettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {  // ... ascent
        self.oRezUnitBottomRight.setText(self.sUnitAscent_fmt);
        fValue = $.GSK_oActivity.fGlobalAscent * $.GSK_oSettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
    }
    else {
      self.oRezUnitBottomRight.setText(self.sUnitElapsed);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewGlobal.onHide()");
    GSK_ViewGlobal.onHide();

    // Mute tones
    App.getApp().muteTones();
  }

}

class GSK_ViewTimersDelegate extends GSK_ViewGlobalDelegate {

  function initialize() {
    GSK_ViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewTimersDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewLog(), new GSK_ViewLogDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewTimersDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewGeneral(), new GSK_ViewGeneralDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
