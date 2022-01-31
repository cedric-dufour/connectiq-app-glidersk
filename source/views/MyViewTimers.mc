// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewTimers extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Resources (cache)
  // ... fields (units)
  private var oRezUnitRight as Ui.Text?;
  private var oRezUnitBottomRight as Ui.Text?;
  // ... strings
  private var sUnitElapsed as String = "elapsed";
  private var sUnitDistance_fmt as String = "distance [km]";
  private var sUnitAscent_fmt as String = "ascent [m]";

  // Internals
  // ... fields
  private var iFieldIndex as Number = 0;
  private var iFieldEpoch as Number = -1;


  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();

    // Internals
    // ... fields
    self.iFieldEpoch = Time.now().value();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGlobal.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitRight = View.findDrawableById("unitRight") as Ui.Text;
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight") as Ui.Text;
    // ... strings
    self.sUnitElapsed = (Ui.loadResource(Rez.Strings.labelElapsed) as String).toLower();
    self.sUnitDistance_fmt = Lang.format("$1$ [$2$]", [(Ui.loadResource(Rez.Strings.labelDistance) as String).toLower(), $.oMySettings.sUnitDistance]);
    self.sUnitAscent_fmt = Lang.format("$1$ [$2$]", [(Ui.loadResource(Rez.Strings.labelAscent) as String).toLower(), $.oMySettings.sUnitElevation]);

    // Set colors (value-independent), labels and units
    // ... activity: start
    (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelActivity) as String);
    (View.findDrawableById("unitTopLeft") as Ui.Text).setText((Ui.loadResource(Rez.Strings.labelStart) as String).toLower());
    // ... activity: elapsed
    (View.findDrawableById("unitTopRight") as Ui.Text).setText(self.sUnitElapsed);
    // ... lap: start
    (View.findDrawableById("labelLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelLap) as String);
    (View.findDrawableById("unitLeft") as Ui.Text).setText((Ui.loadResource(Rez.Strings.labelStart) as String).toLower());
    // ... lap: count
    (View.findDrawableById("labelCenter") as Ui.Text).setText((Ui.loadResource(Rez.Strings.labelCount) as String).toLower());
    // ... lap: elapsed/distance/ascent (dynamic)
    (self.oRezUnitRight as Ui.Text).setText(self.sUnitElapsed);
    // ... recording: start
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelRecording) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText((Ui.loadResource(Rez.Strings.labelStart) as String).toLower());
    // ... recording: elapsed/distance/ascent (dynamic)
    (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitElapsed);

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones(MyApp.TONES_SAFETY);
  }

  function updateLayout(_b) {
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
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values
    var oTimeNow = Time.now();
    var bRecording = ($.oMyActivity != null);
    var fValue;
    var sValue;

    // ... activity: start
    (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorText);
    if($.oMyTimeStart != null) {
      sValue = LangUtils.formatTime($.oMyTimeStart, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopLeft as Ui.Text).setText(sValue);

    // ... activity: elapsed
    (self.oRezValueTopRight as Ui.Text).setColor(self.iColorText);
    if($.oMyTimeStart != null) {
      sValue = LangUtils.formatElapsedTime($.oMyTimeStart, oTimeNow, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopRight as Ui.Text).setText(sValue);

    // ... lap: start
    (self.oRezValueLeft as Ui.Text).setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      sValue = LangUtils.formatTime(($.oMyActivity as MyActivity).oTimeLap, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueLeft as Ui.Text).setText(sValue);

    // ... lap: count
    (self.oRezValueCenter as Ui.Text).setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null and ($.oMyActivity as MyActivity).iCountLaps > 0) {
      sValue = ($.oMyActivity as MyActivity).iCountLaps.format("%d");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    (self.oRezValueCenter as Ui.Text).setText(sValue);

    // ... lap: elapsed
    (self.oRezValueRight as Ui.Text).setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      if(self.iFieldIndex == 0) {  // ... elapsed
        (self.oRezUnitRight as Ui.Text).setText(self.sUnitElapsed);
        if(bRecording) {
          sValue = LangUtils.formatElapsedTime(($.oMyActivity as MyActivity).oTimeLap, oTimeNow, false);
        }
        else {
          sValue = LangUtils.formatElapsedTime(($.oMyActivity as MyActivity).oTimeLap, ($.oMyActivity as MyActivity).oTimeStop, false);
        }
      }
      else if(self.iFieldIndex == 1) {  // ... distance
        (self.oRezUnitRight as Ui.Text).setText(self.sUnitDistance_fmt);
        fValue = ($.oMyActivity as MyActivity).fDistance * $.oMySettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {  // ... ascent
        (self.oRezUnitRight as Ui.Text).setText(self.sUnitAscent_fmt);
        fValue = ($.oMyActivity as MyActivity).fAscent * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
    }
    else {
      (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitElapsed);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueRight as Ui.Text).setText(sValue);

    // ... recording: start
    (self.oRezValueBottomLeft as Ui.Text).setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      sValue = LangUtils.formatTime(($.oMyActivity as MyActivity).oTimeStart, $.oMySettings.bUnitTimeUTC, false);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomLeft as Ui.Text).setText(sValue);

    // ... recording: elapsed
    (self.oRezValueBottomRight as Ui.Text).setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    if($.oMyActivity != null) {
      if(self.iFieldIndex == 0) {  // ... elapsed
        (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitElapsed);
        if(bRecording) {
          sValue = LangUtils.formatElapsedTime(($.oMyActivity as MyActivity).oTimeStart, oTimeNow, false);
        }
        else {
          sValue = LangUtils.formatElapsedTime(($.oMyActivity as MyActivity).oTimeStart, ($.oMyActivity as MyActivity).oTimeStop, false);
        }
      }
      else if(self.iFieldIndex == 1) {  // ... distance
        (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitDistance_fmt);
        fValue = ($.oMyActivity as MyActivity).fGlobalDistance * $.oMySettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {  // ... ascent
        (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitAscent_fmt);
        fValue = ($.oMyActivity as MyActivity).fGlobalAscent * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
    }
    else {
      (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitElapsed);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomRight as Ui.Text).setText(sValue);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGlobal.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
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
