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

class GSK_ViewTimers extends GSK_ViewGlobal {

  //
  // FUNCTIONS: GSK_ViewGlobal (override/implement)
  //

  function initialize() {
    GSK_ViewGlobal.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: GSK_ViewGlobal.prepare()");
    GSK_ViewGlobal.prepare();

    // Set colors (value-independent), labels and units
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

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);
  }

  function updateLayout() {
    //Sys.println("DEBUG: GSK_ViewGlobal.updateLayout()");
    GSK_ViewGlobal.updateLayout(true);

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
    var iDuration;
    var iDuration_h;
    var iDuration_m;
    var sValue;

    // ... activity: start
    self.oRezValueTopLeft.setColor(self.iColorText);
    if($.GSK_oTimeStart != null) {
      var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo($.GSK_oTimeStart, Time.FORMAT_SHORT) : Gregorian.info($.GSK_oTimeStart, Time.FORMAT_SHORT);
      sValue = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... activity: elapsed
    self.oRezValueTopRight.setColor(self.iColorText);
    if($.GSK_oTimeStart != null) {
      iDuration = Math.floor(oTimeNow.subtract($.GSK_oTimeStart).value() / 60.0).toNumber();
      iDuration_m = iDuration % 60;
      iDuration_h = (iDuration-iDuration_m) / 60;
      sValue = Lang.format("$1$:$2$", [iDuration_h.format("%d"), iDuration_m.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... lap: start
    self.oRezValueLeft.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_Activity_oTimeLap != null) {
      var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo($.GSK_Activity_oTimeLap, Time.FORMAT_SHORT) : Gregorian.info($.GSK_Activity_oTimeLap, Time.FORMAT_SHORT);
      sValue = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... lap: count
    self.oRezValueCenter.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_Activity_iCountLaps) {
      sValue = $.GSK_Activity_iCountLaps.format("%d");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... lap: elapsed
    self.oRezValueRight.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_Activity_oTimeLap != null and (bRecording or $.GSK_Activity_oTimeStop != null)) {
      if(bRecording) {
        iDuration = Math.floor(oTimeNow.subtract($.GSK_Activity_oTimeLap).value() / 60.0).toNumber();
      }
      else {
        iDuration = Math.floor($.GSK_Activity_oTimeStop.subtract($.GSK_Activity_oTimeLap).value() / 60.0).toNumber();
      }
      iDuration_m = iDuration % 60;
      iDuration_h = (iDuration-iDuration_m) / 60;
      sValue = Lang.format("$1$:$2$", [iDuration_h.format("%d"), iDuration_m.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... recording: start
    self.oRezValueBottomLeft.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_Activity_oTimeStart != null) {
      var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo($.GSK_Activity_oTimeStart, Time.FORMAT_SHORT) : Gregorian.info($.GSK_Activity_oTimeStart, Time.FORMAT_SHORT);
      sValue = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... recording: elapsed
    self.oRezValueBottomRight.setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.GSK_Activity_oTimeStart != null and (bRecording or $.GSK_Activity_oTimeStop != null)) {
      if(bRecording) {
        iDuration = Math.floor(oTimeNow.subtract($.GSK_Activity_oTimeStart).value() / 60.0).toNumber();
      }
      else {
        iDuration = Math.floor($.GSK_Activity_oTimeStop.subtract($.GSK_Activity_oTimeStart).value() / 60.0).toNumber();
      }
      iDuration_m = iDuration % 60;
      iDuration_h = (iDuration-iDuration_m) / 60;
      sValue = Lang.format("$1$:$2$", [iDuration_h.format("%d"), iDuration_m.format("%02d")]);
    }
    else {
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
    //Sys.println("DEBUG: GSK_ViewRateOfTurnDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewVarioplot(), new GSK_ViewVarioplotDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewRateOfTurnDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewGeneral(), new GSK_ViewGeneralDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
