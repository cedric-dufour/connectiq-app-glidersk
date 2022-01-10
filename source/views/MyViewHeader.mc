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
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewHeader extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  protected var bHeaderOnly;
  private var bShow;

  // Resources
  // ... drawable
  private var oRezDrawableHeader;
  // ... header
  private var oRezValueBatteryLevel;
  private var oRezValueActivityStatus;
  // ... footer
  protected var oRezValueFooter;
  // ... strings
  private var sValueActivityStandby;
  private var sValueActivityRecording;
  private var sValueActivityPaused;

  // Internals
  protected var iColorText;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode
    // ... internal
    self.bHeaderOnly = true;
    self.bShow = false;
  }

  function onLayout(_oDC) {
    View.setLayout(self.bHeaderOnly ? Rez.Layouts.layoutHeader(_oDC) : Rez.Layouts.layoutGlobal(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("MyDrawableHeader");
    // ... header
    self.oRezValueBatteryLevel = View.findDrawableById("valueBatteryLevel");
    self.oRezValueActivityStatus = View.findDrawableById("valueActivityStatus");
    // ... footer
    self.oRezValueFooter = View.findDrawableById("valueFooter");

    // Done
    return true;
  }

  function onShow() {
    //Sys.println("DEBUG: MyViewHeader.onShow()");

    // Prepare view
    self.prepare();

    // Done
    self.bShow = true;
    $.oMyView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyViewHeader.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);

    // Done
    return true;
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewHeader.onHide()");
    $.oMyView = null;
    self.bShow = false;
  }


  //
  // FUNCTIONS: self
  //

  function prepare() {
    //Sys.println("DEBUG: MyViewHeader.prepare()");

    // Load resources
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);

    // (Re)load settings
    App.getApp().loadSettings();
    // ... colors
    self.iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
  }

  function updateUi() {
    //Sys.println("DEBUG: MyViewHeader.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout(_bUpdateTime) {
    //Sys.println("DEBUG: MyViewHeader.updateLayout()");

    // Set colors
    self.iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableHeader.setColorBackground($.oMySettings.iGeneralBackgroundColor);

    // Set header/footer values
    var sValue;

    // ... position accuracy
    self.oRezDrawableHeader.setPositionAccuracy($.oMyProcessing.iAccuracy);

    // ... battery level
    self.oRezValueBatteryLevel.setColor(self.iColorText);
    self.oRezValueBatteryLevel.setText(Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]));

    // ... activity status
    if($.oMyActivity == null) {  // ... stand-by
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_LT_GRAY);
      sValue = self.sValueActivityStandby;
    }
    else if($.oMyActivity.isRecording()) {  // ... recording
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_RED);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_YELLOW);
      sValue = self.sValueActivityPaused;
    }
    self.oRezValueActivityStatus.setText(sValue);

    // ... time
    if(_bUpdateTime) {
      var oTimeNow = Time.now();
      var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
      self.oRezValueFooter.setColor(self.iColorText);
      self.oRezValueFooter.setText(Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]));
    }
  }

}
