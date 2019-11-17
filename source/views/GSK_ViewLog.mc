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
var GSK_iViewLogIndex = null;


//
// CLASS
//

class GSK_ViewLog extends GSK_ViewGlobal {

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
  // FUNCTIONS: GSK_ViewGlobal (override/implement)
  //

  function initialize() {
    GSK_ViewGlobal.initialize();

    // Current view/log index
    $.GSK_iViewLogIndex = $.GSK_iLogIndex;

    // Internals
    // ... fields
    self.bTitleShow = true;
    self.iFieldIndex = 0;
    self.iFieldEpoch = Time.now().value();
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewLog.onUpdate()");

    // Load log
    if(self.iLogIndex != $.GSK_iViewLogIndex) {
      self.loadLog();
    }

    // Done
    return GSK_ViewGlobal.onUpdate(_oDC);
  }

  function prepare() {
    //Sys.println("DEBUG: GSK_ViewLog.prepare()");
    GSK_ViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitLeft = View.findDrawableById("unitLeft");
    self.oRezUnitRight = View.findDrawableById("unitRight");
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight");
    // ... strings
    self.sTitle = Ui.loadResource(Rez.Strings.titleViewLog);
    self.sUnitElevation_fmt = Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]);

    // Set labels, units and colors
    // ... start time
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelStart));
    View.findDrawableById("unitTopLeft").setText($.GSK_NOVALUE_BLANK);
    self.oRezValueTopLeft.setColor(self.iColorText);
    // ... stop time
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelStop));
    View.findDrawableById("unitTopRight").setText($.GSK_NOVALUE_BLANK);
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
    View.findDrawableById("unitBottomLeft").setText($.GSK_NOVALUE_BLANK);
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
    //Sys.println("DEBUG: GSK_ViewLog.updateLayout()");
    GSK_ViewGlobal.updateLayout(false);

    // Fields
    var iEpochNow = Time.now().value();
    if(iEpochNow - self.iFieldEpoch >= 2) {
      self.bTitleShow = false;
      self.iFieldIndex = (self.iFieldIndex + 1) % 2;
      self.iFieldEpoch = iEpochNow;
    }

    // No log ?
    if(self.dictLog == null) {
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueCenter.setText($.GSK_NOVALUE_LEN2);
      self.oRezValueRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomRight.setText($.GSK_NOVALUE_LEN3);
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
      self.oRezUnitLeft.setText($.GSK_NOVALUE_BLANK);
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
      self.oRezUnitRight.setText($.GSK_NOVALUE_BLANK);
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
      self.oRezUnitBottomRight.setText($.GSK_NOVALUE_BLANK);
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
    //Sys.println("DEBUG: GSK_ViewLog.loadLog()");

    // Check index
    if($.GSK_iViewLogIndex == null) {
      self.iLogIndex = null;
      self.dictLog = null;
      return;
    }

    // Load log entry
    self.iLogIndex = $.GSK_iViewLogIndex;
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
      var oTimeInfo = $.GSK_oSettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeStart, Time.FORMAT_MEDIUM) : Gregorian.info(oTimeStart, Time.FORMAT_MEDIUM);
      d["timeStart"] = Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
      d["date"] = Lang.format("$1$ $2$", [oTimeInfo.month, oTimeInfo.day.format("%01d")]);
    } else {
      d["timeStart"] = $.GSK_NOVALUE_LEN3;
      d["date"] = $.GSK_NOVALUE_LEN4;
    }
    // ... time: stop
    if(d.get("timeStop") != null) {
      oTimeStop = new Time.Moment(d["timeStop"]);
      d["timeStop"] = LangUtils.formatTime(oTimeStop, $.GSK_oSettings.bUnitTimeUTC, false);
    } else {
      d["timeStop"] = $.GSK_NOVALUE_LEN3;
    }
    // ... elapsed
    if(oTimeStart != null and oTimeStop != null) {
      d["elapsed"] = LangUtils.formatElapsedTime(oTimeStart, oTimeStop, false);
    }
    else {
      d["elapsed"] = $.GSK_NOVALUE_LEN3;
    }
    // ... distance
    if(d.get("distance") != null) {
      fValue = d["distance"] * $.GSK_oSettings.fUnitDistanceCoefficient;
      d["distance"] = fValue.format("%.0f");
    } else {
      d["distance"] = $.GSK_NOVALUE_LEN2;
    }
    // ... ascent (and elasped)
    if(d.get("ascent") != null) {
      fValue = d["ascent"] * $.GSK_oSettings.fUnitElevationCoefficient;
      d["ascent"] = d["ascent"].format("%.0f");
    } else {
      d["ascent"] = $.GSK_NOVALUE_LEN3;
    }
    if(d.get("elapsedAscent") != null) {
      d["elapsedAscent"] = LangUtils.formatElapsed(d["elapsedAscent"], false);
    } else {
      d["elapsedAscent"] = $.GSK_NOVALUE_LEN3;
    }
    // ... altitude: minimum (and time)
    if(d.get("altitudeMin") != null) {
      fValue = d["altitudeMin"] * $.GSK_oSettings.fUnitElevationCoefficient;
      d["altitudeMin"] = fValue.format("%.0f");
    } else {
      d["altitudeMin"] = $.GSK_NOVALUE_LEN3;
    }
    if(d.get("timeAltitudeMin") != null) {
      d["timeAltitudeMin"] = LangUtils.formatTime(new Time.Moment(d["timeAltitudeMin"]), $.GSK_oSettings.bUnitTimeUTC, false);
    } else {
      d["timeAltitudeMin"] = $.GSK_NOVALUE_LEN3;
    }
    // ... altitude: maximum (and time)
    if(d.get("altitudeMax") != null) {
      fValue = d["altitudeMax"] * $.GSK_oSettings.fUnitElevationCoefficient;
      d["altitudeMax"] = fValue.format("%.0f");
    } else {
      d["altitudeMax"] = $.GSK_NOVALUE_LEN3;
    }
    if(d.get("timeAltitudeMax") != null) {
      d["timeAltitudeMax"] = LangUtils.formatTime(new Time.Moment(d["timeAltitudeMax"]), $.GSK_oSettings.bUnitTimeUTC, false);
    } else {
      d["timeAltitudeMax"] = $.GSK_NOVALUE_LEN3;
    }

    // Done
    self.dictLog = d;
  }

}

class GSK_ViewLogDelegate extends GSK_ViewGlobalDelegate {

  function initialize() {
    GSK_ViewGlobalDelegate.initialize();
  }

  function onSelect() {
    //Sys.println("DEBUG: GSK_ViewLogDelegate.onSelect()");
    if($.GSK_iViewLogIndex == null) {
      $.GSK_iViewLogIndex = $.GSK_iLogIndex;
    }
    else {
      $.GSK_iViewLogIndex = ($.GSK_iViewLogIndex + 1) % $.GSK_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: GSK_ViewLogDelegate.onBack()");
    if($.GSK_iViewLogIndex == null) {
      $.GSK_iViewLogIndex = $.GSK_iLogIndex;
    }
    else {
      $.GSK_iViewLogIndex = ($.GSK_iViewLogIndex - 1 + $.GSK_STORAGE_SLOTS) % $.GSK_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewLogDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewVarioplot(), new GSK_ViewVarioplotDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewLogDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewTimers(), new GSK_ViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
