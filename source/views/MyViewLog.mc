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

//
// GLOBALS
//

// Current view/log index
var iMyViewLogIndex = null;


//
// CLASS
//

class MyViewLog extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Resources (cache)
  // ... fields (units)
  private var oRezUnitLeft;
  private var oRezUnitRight;
  private var oRezUnitBottomRight;
  // ... strings
  private var sTitle;
  private var sUnitElevation_fmt;

  // Internals
  // ... fields
  private var bTitleShow;
  private var iFieldIndex;
  private var iFieldEpoch;
  // ... log
  private var iLogIndex = null;
  private var dictLog;


  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();

    // Current view/log index
    $.iMyViewLogIndex = $.iMyLogIndex;

    // Internals
    // ... fields
    self.bTitleShow = true;
    self.iFieldIndex = 0;
    self.iFieldEpoch = Time.now().value();
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyViewLog.onUpdate()");

    // Load log
    if(self.iLogIndex != $.iMyViewLogIndex) {
      self.loadLog();
    }

    // Done
    return MyViewGlobal.onUpdate(_oDC);
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewLog.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitLeft = View.findDrawableById("unitLeft");
    self.oRezUnitRight = View.findDrawableById("unitRight");
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight");
    // ... strings
    self.sTitle = Ui.loadResource(Rez.Strings.titleViewLog);
    self.sUnitElevation_fmt = Lang.format("[$1$]", [$.oMySettings.sUnitElevation]);

    // Set labels, units and colors
    // ... start time
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelStart));
    View.findDrawableById("unitTopLeft").setText($.MY_NOVALUE_BLANK);
    self.oRezValueTopLeft.setColor(self.iColorText);
    // ... stop time
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelStop));
    View.findDrawableById("unitTopRight").setText($.MY_NOVALUE_BLANK);
    self.oRezValueTopRight.setColor(self.iColorText);
    // ... minimum altitude / time (dynamic label)
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelAltitudeMin));
    self.oRezValueLeft.setColor(self.iColorText);
    // ... distance
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelDistance));
    self.oRezValueCenter.setColor(self.iColorText);
    // ... maximum altitude / time (dynamic label)
    View.findDrawableById("labelRight").setText(Ui.loadResource(Rez.Strings.labelAltitudeMax));
    self.oRezValueRight.setColor(self.iColorText);
    // ... elapsed time
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelElapsed));
    View.findDrawableById("unitBottomLeft").setText($.MY_NOVALUE_BLANK);
    self.oRezValueBottomLeft.setColor(self.iColorText);
    // ... ascent / elapsed (dynamic label)
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelAscent));
    self.oRezValueBottomRight.setColor(self.iColorText);
    // ... title
    self.bTitleShow = true;
    self.oRezValueFooter.setColor(Gfx.COLOR_DK_GRAY);
    self.oRezValueFooter.setText(Ui.loadResource(Rez.Strings.titleViewLog));

    // Done
    return true;
  }

  function updateLayout() {
    //Sys.println("DEBUG: MyViewLog.updateLayout()");
    MyViewGlobal.updateLayout(false);

    // Fields
    var iEpochNow = Time.now().value();
    if(iEpochNow - self.iFieldEpoch >= 2) {
      self.bTitleShow = false;
      self.iFieldIndex = (self.iFieldIndex + 1) % 2;
      self.iFieldEpoch = iEpochNow;
    }

    // No log ?
    if(self.dictLog == null) {
      self.oRezValueTopLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueTopRight.setText($.MY_NOVALUE_LEN3);
      self.oRezValueLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueCenter.setText($.MY_NOVALUE_LEN2);
      self.oRezValueRight.setText($.MY_NOVALUE_LEN3);
      self.oRezValueBottomLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueBottomRight.setText($.MY_NOVALUE_LEN3);
      self.oRezValueFooter.setColor(Gfx.COLOR_DK_GRAY);
      self.oRezValueFooter.setText(self.sTitle);
      return;
    }

    // Set values
    // ... time: start
    self.oRezValueTopLeft.setText(self.dictLog["timeStart"]);
    // ... time: stop
    self.oRezValueTopRight.setText(self.dictLog["timeStop"]);
    // ... altitude: mininum
    if(self.iFieldIndex == 0) {  // ... altitude
      self.oRezUnitLeft.setText(self.sUnitElevation_fmt);
      self.oRezValueLeft.setText(self.dictLog["altitudeMin"]);
    }
    else {  // ... time
      self.oRezUnitLeft.setText($.MY_NOVALUE_BLANK);
      self.oRezValueLeft.setText(self.dictLog["timeAltitudeMin"]);
    }
    // ... distance
    self.oRezValueCenter.setText(self.dictLog["distance"]);
    // ... altitude: maxinum
    if(self.iFieldIndex == 0) {  // ... altitude
      self.oRezUnitRight.setText(self.sUnitElevation_fmt);
      self.oRezValueRight.setText(self.dictLog["altitudeMax"]);
    }
    else {  // ... time
      self.oRezUnitRight.setText($.MY_NOVALUE_BLANK);
      self.oRezValueRight.setText(self.dictLog["timeAltitudeMax"]);
    }
    // ... elapsed
    self.oRezValueBottomLeft.setText(self.dictLog["elapsed"]);
    // ... ascent
    if(self.iFieldIndex == 0) {  // ... altitude
      self.oRezUnitBottomRight.setText(self.sUnitElevation_fmt);
      self.oRezValueBottomRight.setText(self.dictLog["ascent"]);
    }
    else {  // ... elapsed
      self.oRezUnitBottomRight.setText($.MY_NOVALUE_BLANK);
      self.oRezValueBottomRight.setText(self.dictLog["elapsedAscent"]);
    }
    // ... footer
    if(!self.bTitleShow) {
      self.oRezValueFooter.setColor(self.iColorText);
      self.oRezValueFooter.setText(self.dictLog["date"]);
    }
  }


  //
  // FUNCTIONS: self
  //

  function loadLog() {
    //Sys.println("DEBUG: MyViewLog.loadLog()");

    // Check index
    if($.iMyViewLogIndex == null) {
      self.iLogIndex = null;
      self.dictLog = null;
      return;
    }

    // Load log entry
    self.iLogIndex = $.iMyViewLogIndex;
    var s = self.iLogIndex.format("%02d");
    var d = App.Storage.getValue(Lang.format("storLog$1$", [s]));
    if(d == null) {
      self.dictLog = null;
      return;
    }

    // Validate/textualize log entry
    var oTimeStart = null;
    var oTimeStop = null;
    var fValue;
    // ... time: start (and date)
    if(d.get("timeStart") != null) {
      oTimeStart = new Time.Moment(d["timeStart"]);
      var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeStart, Time.FORMAT_MEDIUM) : Gregorian.info(oTimeStart, Time.FORMAT_MEDIUM);
      d["timeStart"] = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
      d["date"] = Lang.format("$1$ $2$", [oTimeInfo.month, oTimeInfo.day.format("%01d")]);
    } else {
      d["timeStart"] = $.MY_NOVALUE_LEN3;
      d["date"] = $.MY_NOVALUE_LEN4;
    }
    // ... time: stop
    if(d.get("timeStop") != null) {
      oTimeStop = new Time.Moment(d["timeStop"]);
      d["timeStop"] = LangUtils.formatTime(oTimeStop, $.oMySettings.bUnitTimeUTC, false);
    } else {
      d["timeStop"] = $.MY_NOVALUE_LEN3;
    }
    // ... elapsed
    if(oTimeStart != null and oTimeStop != null) {
      d["elapsed"] = LangUtils.formatElapsedTime(oTimeStart, oTimeStop, false);
    }
    else {
      d["elapsed"] = $.MY_NOVALUE_LEN3;
    }
    // ... distance
    if(d.get("distance") != null) {
      fValue = d["distance"] * $.oMySettings.fUnitDistanceCoefficient;
      d["distance"] = fValue.format("%.0f");
    } else {
      d["distance"] = $.MY_NOVALUE_LEN2;
    }
    // ... ascent (and elasped)
    if(d.get("ascent") != null) {
      fValue = d["ascent"] * $.oMySettings.fUnitElevationCoefficient;
      d["ascent"] = d["ascent"].format("%.0f");
    } else {
      d["ascent"] = $.MY_NOVALUE_LEN3;
    }
    if(d.get("elapsedAscent") != null) {
      d["elapsedAscent"] = LangUtils.formatElapsed(d["elapsedAscent"], false);
    } else {
      d["elapsedAscent"] = $.MY_NOVALUE_LEN3;
    }
    // ... altitude: minimum (and time)
    if(d.get("altitudeMin") != null) {
      fValue = d["altitudeMin"] * $.oMySettings.fUnitElevationCoefficient;
      d["altitudeMin"] = fValue.format("%.0f");
    } else {
      d["altitudeMin"] = $.MY_NOVALUE_LEN3;
    }
    if(d.get("timeAltitudeMin") != null) {
      d["timeAltitudeMin"] = LangUtils.formatTime(new Time.Moment(d["timeAltitudeMin"]), $.oMySettings.bUnitTimeUTC, false);
    } else {
      d["timeAltitudeMin"] = $.MY_NOVALUE_LEN3;
    }
    // ... altitude: maximum (and time)
    if(d.get("altitudeMax") != null) {
      fValue = d["altitudeMax"] * $.oMySettings.fUnitElevationCoefficient;
      d["altitudeMax"] = fValue.format("%.0f");
    } else {
      d["altitudeMax"] = $.MY_NOVALUE_LEN3;
    }
    if(d.get("timeAltitudeMax") != null) {
      d["timeAltitudeMax"] = LangUtils.formatTime(new Time.Moment(d["timeAltitudeMax"]), $.oMySettings.bUnitTimeUTC, false);
    } else {
      d["timeAltitudeMax"] = $.MY_NOVALUE_LEN3;
    }

    // Done
    self.dictLog = d;
  }

}

class MyViewLogDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewLogDelegate.onSelect()");
    if($.iMyViewLogIndex == null) {
      $.iMyViewLogIndex = $.iMyLogIndex;
    }
    else {
      $.iMyViewLogIndex = ($.iMyViewLogIndex + 1) % $.MY_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewLogDelegate.onBack()");
    if($.iMyViewLogIndex == null) {
      $.iMyViewLogIndex = $.iMyLogIndex;
    }
    else {
      $.iMyViewLogIndex = ($.iMyViewLogIndex - 1 + $.MY_STORAGE_SLOTS) % $.MY_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewLogDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewVarioplot(),
                    new MyViewVarioplotDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewLogDelegate.onNextPage()");
    Ui.switchToView(new MyViewTimers(),
                    new MyViewTimersDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
