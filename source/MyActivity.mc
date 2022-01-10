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

using Toybox.Activity;
using Toybox.ActivityRecording as AR;
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.FitContributor as FC;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.System as Sys;

//
// CLASS
//

class MyActivity {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  // ... record
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_RATEOFTURN = 1;
  public const FITFIELD_ACCELERATION = 2;
  public const FITFIELD_BAROMETRICALTITUDE = 3;
  // ... lap
  public const FITFIELD_DISTANCE = 10;
  public const FITFIELD_ASCENT = 11;
  public const FITFIELD_ELAPSEDASCENT = 12;
  public const FITFIELD_ALTITUDEMIN = 13;
  public const FITFIELD_TIMEALTITUDEMIN = 14;
  public const FITFIELD_ALTITUDEMAX = 15;
  public const FITFIELD_TIMEALTITUDEMAX = 16;
  // ... session
  public const FITFIELD_GLOBALDISTANCE = 80;
  public const FITFIELD_GLOBALASCENT = 81;
  public const FITFIELD_GLOBALELAPSEDASCENT = 82;
  public const FITFIELD_GLOBALALTITUDEMIN = 83;
  public const FITFIELD_GLOBALTIMEALTITUDEMIN = 84;
  public const FITFIELD_GLOBALALTITUDEMAX = 85;
  public const FITFIELD_GLOBALTIMEALTITUDEMAX = 86;


  //
  // VARIABLES
  //

  // Session
  // ... recording
  private var oSession;
  public var oTimeStart = null;
  public var oTimeLap = null;
  public var iCountLaps = null;
  public var oTimeStop = null;
  // ... lap
  public var fDistance = 0.0f;
  public var fAscent = 0.0f;
  public var iElapsedAscent = 0;
  public var fAltitudeMin = null;
  public var oTimeAltitudeMin = null;
  public var fAltitudeMax = null;
  public var oTimeAltitudeMax = null;
  // ... session
  public var fGlobalDistance = 0.0f;
  public var fGlobalAscent = 0.0f;
  public var iGlobalElapsedAscent = 0;
  public var fGlobalAltitudeMin = null;
  public var oGlobalTimeAltitudeMin = null;
  public var fGlobalAltitudeMax = null;
  public var oGlobalTimeAltitudeMax = null;
  // ... internals
  private var iEpochLast = null;
  private var adPositionRadiansLast = null;
  private var fAltitudeLast = null;

  // FIT fields
  // ... (unit conversion) coefficients
  private var bUnitCoefficient_TimeUTC = false;
  private var fUnitCoefficient_Distance = 1.0f;
  private var fUnitCoefficient_Altitude = 1.0f;
  private var fUnitCoefficient_VerticalSpeed = 1.0f;
  private var fUnitCoefficient_RateOfTurn = 1.0f;
  // ... record
  private var oFitField_BarometricAltitude = null;
  private var oFitField_VerticalSpeed = null;
  private var oFitField_RateOfTurn = null;
  private var oFitField_Acceleration = null;
  // ... lap
  private var oFitField_Distance = null;
  private var oFitField_Ascent = null;
  private var oFitField_ElapsedAscent = null;
  private var oFitField_AltitudeMin = null;
  private var oFitField_TimeAltitudeMin = null;
  private var oFitField_AltitudeMax = null;
  private var oFitField_TimeAltitudeMax = null;
  // ... session
  private var oFitField_GlobalDistance = null;
  private var oFitField_GlobalAscent = null;
  private var oFitField_GlobalElapsedAscent = null;
  private var oFitField_GlobalAltitudeMin = null;
  private var oFitField_GlobalTimeAltitudeMin = null;
  private var oFitField_GlobalAltitudeMax = null;
  private var oFitField_GlobalTimeAltitudeMax = null;

  // Log fields


  //
  // FUNCTIONS: self
  //

  function initialize() {
    //Sys.println("DEBUG: MyActivity.initialize()");

    // Session (recording)
    // NOTE: "Flying" activity number is 20 (cf. https://www.thisisant.com/resources/fit -> Profiles.xlsx)
    self.oSession = AR.createSession({ :name=>"GliderSK", :sport=>20, :subSport=>AR.SUB_SPORT_GENERIC });

    // FIT fields

    // ... (unit conversion) coefficients
    self.bUnitCoefficient_TimeUTC = $.oMySettings.bUnitTimeUTC;
    self.fUnitCoefficient_Distance = $.oMySettings.fUnitDistanceCoefficient;
    self.fUnitCoefficient_Altitude = $.oMySettings.fUnitElevationCoefficient;
    self.fUnitCoefficient_VerticalSpeed = $.oMySettings.fUnitVerticalSpeedCoefficient;
    self.fUnitCoefficient_RateOfTurn = $.oMySettings.fUnitRateOfTurnCoefficient;

    // ... record
    self.oFitField_BarometricAltitude = self.oSession.createField("BarometricAltitude", MyActivity.FITFIELD_BAROMETRICALTITUDE, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_VerticalSpeed = self.oSession.createField("VerticalSpeed", MyActivity.FITFIELD_VERTICALSPEED, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.oMySettings.sUnitVerticalSpeed });
    self.oFitField_RateOfTurn = self.oSession.createField("RateOfTurn", MyApp.FITFIELD_RATEOFTURN, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.oMySettings.sUnitRateOfTurn });
    self.oFitField_Acceleration = self.oSession.createField("Acceleration", MyApp.FITFIELD_ACCELERATION, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>"g" });

    // ... lap
    self.oFitField_Distance = self.oSession.createField("Distance", MyActivity.FITFIELD_DISTANCE, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_LAP, :units=>$.oMySettings.sUnitDistance });
    self.oFitField_Ascent = self.oSession.createField("Ascent", MyActivity.FITFIELD_ASCENT, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_LAP, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_ElapsedAscent = self.oSession.createField("ElapsedAscent", MyActivity.FITFIELD_ELAPSEDASCENT, FC.DATA_TYPE_STRING, { :mesgType=>FC.MESG_TYPE_LAP, :count=>9 });
    self.oFitField_AltitudeMin = self.oSession.createField("AltitudeMin", MyActivity.FITFIELD_ALTITUDEMIN, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_LAP, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_TimeAltitudeMin = self.oSession.createField("TimeAltitudeMin", MyActivity.FITFIELD_TIMEALTITUDEMIN, FC.DATA_TYPE_STRING, { :mesgType=>FC.MESG_TYPE_LAP, :count=>9, :units=>$.oMySettings.sUnitTime });
    self.oFitField_AltitudeMax = self.oSession.createField("AltitudeMax", MyActivity.FITFIELD_ALTITUDEMAX, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_LAP, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_TimeAltitudeMax = self.oSession.createField("TimeAltitudeMax", MyActivity.FITFIELD_TIMEALTITUDEMAX, FC.DATA_TYPE_STRING, { :mesgType=>FC.MESG_TYPE_LAP, :count=>9, :units=>$.oMySettings.sUnitTime });
    self.resetLapFields();

    // ... session
    self.oFitField_GlobalDistance = self.oSession.createField("Distance", MyActivity.FITFIELD_GLOBALDISTANCE, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_SESSION, :units=>$.oMySettings.sUnitDistance });
    self.oFitField_GlobalAscent = self.oSession.createField("Ascent", MyActivity.FITFIELD_GLOBALASCENT, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_SESSION, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_GlobalElapsedAscent = self.oSession.createField("ElapsedAscent", MyActivity.FITFIELD_GLOBALELAPSEDASCENT, FC.DATA_TYPE_STRING, { :mesgType=>FC.MESG_TYPE_SESSION, :count=>9 });
    self.oFitField_GlobalAltitudeMin = self.oSession.createField("AltitudeMin", MyActivity.FITFIELD_GLOBALALTITUDEMIN, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_SESSION, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_GlobalTimeAltitudeMin = self.oSession.createField("TimeAltitudeMin", MyActivity.FITFIELD_GLOBALTIMEALTITUDEMIN, FC.DATA_TYPE_STRING, { :mesgType=>FC.MESG_TYPE_SESSION, :count=>9, :units=>$.oMySettings.sUnitTime });
    self.oFitField_GlobalAltitudeMax = self.oSession.createField("AltitudeMax", MyActivity.FITFIELD_GLOBALALTITUDEMAX, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_SESSION, :units=>$.oMySettings.sUnitElevation });
    self.oFitField_GlobalTimeAltitudeMax = self.oSession.createField("TimeAltitudeMax", MyActivity.FITFIELD_GLOBALTIMEALTITUDEMAX, FC.DATA_TYPE_STRING, { :mesgType=>FC.MESG_TYPE_SESSION, :count=>9, :units=>$.oMySettings.sUnitTime });

  }


  //
  // FUNCTIONS: self (session)
  //

  function start() {
    //Sys.println("DEBUG: MyActivity.start()");

    self.resetLog(true);
    self.oSession.start();
    self.oTimeStart = Time.now();
    self.oTimeLap = Time.now();
    self.iCountLaps = 1;
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
  }

  function isRecording() {
    //Sys.println("DEBUG: MyActivity.isRecording()");

    return self.oSession.isRecording();
  }

  function addLap() {
    //Sys.println("DEBUG: MyActivity.lap()");

    self.saveLog(false);
    self.oSession.addLap();
    self.oTimeLap = Time.now();
    self.iCountLaps += 1;
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_LAP);
    }
    self.resetLapFields();
    self.resetLog(false);
  }

  function pause() {
    //Sys.println("DEBUG: MyActivity.pause()");

    if(!self.oSession.isRecording()) {
      return;
    }
    self.oSession.stop();
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_STOP);
    }
  }

  function resume() {
    //Sys.println("DEBUG: MyActivity.resume()");

    if(self.oSession.isRecording()) {
      return;
    }
    self.oSession.start();
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
  }

  function stop(_bSave) {
    //Sys.println(Lang.format("DEBUG: MyActivity.stop($1$)", [_bSave]));

    if(self.oSession.isRecording()) {
      self.oSession.stop();
    }
    if(_bSave) {
      self.oTimeStop = Time.now();
      self.saveLog(true);
      self.oSession.save();
      if(Attn has :playTone) {
        Attn.playTone(Attn.TONE_STOP);
      }
    }
    else {
      self.oSession.discard();
      if(Attn has :playTone) {
        Attn.playTone(Attn.TONE_RESET);
      }
    }
    self.oTimeStart = null;
    self.oTimeLap = null;
    self.iCountLaps = null;
    self.oTimeStop = null;
  }


  //
  // FUNCTIONS: self (log)
  //

  function resetLog(_bSession) {
    self.iEpochLast = null;
    self.adPositionRadiansLast = null;
    self.fAltitudeLast = null;
    // ... lap
    self.fDistance = 0.0f;
    self.fAscent = 0.0f;
    self.iElapsedAscent = 0;
    self.fAltitudeMin = null;
    self.oTimeAltitudeMin = null;
    self.fAltitudeMax = null;
    self.oTimeAltitudeMax = null;
    // ... session
    if(_bSession) {
      self.fGlobalDistance = 0.0f;
      self.fGlobalAscent = 0.0f;
      self.iGlobalElapsedAscent = 0;
      self.fGlobalAltitudeMin = null;
      self.oGlobalTimeAltitudeMin = null;
      self.fGlobalAltitudeMax = null;
      self.oGlobalTimeAltitudeMax = null;
    }
  }

  function processPositionInfo(_oInfo, _iEpoch, _oTimeNow) {
    //Sys.println("DEBUG: MyActivity.processPositionInfo()");

    if(!self.oSession.isRecording()
       or !(_oInfo has :accuracy) or _oInfo.accuracy < Pos.QUALITY_GOOD
       or !(_oInfo has :position) or _oInfo.position == null
       or !(_oInfo has :altitude) or _oInfo.altitude == null
       or (self.iEpochLast != null and (_iEpoch - self.iEpochLast) < $.oMySettings.iGeneralTimeConstant)) {
      return;
    }

    // Distance (non-thermalling)
    var adPositionRadians = _oInfo.position.toRadians();
    if(self.adPositionRadiansLast != null) {
      var fLegLength = LangUtils.distance(self.adPositionRadiansLast, adPositionRadians);
      if(fLegLength > 1000.0f) {  // # 1000m = 1km should be bigger than thermalling diameter
        self.adPositionRadiansLast = adPositionRadians;
        // ... lap
        self.fDistance += fLegLength;
        // ... session
        self.fGlobalDistance += fLegLength;
      }
    }
    else {
      self.adPositionRadiansLast = adPositionRadians;
    }

    // Ascent
    if(self.iEpochLast != null and self.fAltitudeLast != null and _oInfo.altitude > self.fAltitudeLast) {
      // ... lap
      self.fAscent += (_oInfo.altitude - self.fAltitudeLast);
      self.iElapsedAscent += (_iEpoch - self.iEpochLast);
      // ... session
      self.fGlobalAscent += (_oInfo.altitude - self.fAltitudeLast);
      self.iGlobalElapsedAscent += (_iEpoch - self.iEpochLast);
    }
    self.fAltitudeLast = _oInfo.altitude;

    // Altitude
    // ... lap
    if(self.fAltitudeMin == null or _oInfo.altitude < self.fAltitudeMin) {
      self.fAltitudeMin = _oInfo.altitude;
      self.oTimeAltitudeMin = _oTimeNow;
    }
    if(self.fAltitudeMax == null or _oInfo.altitude > self.fAltitudeMax) {
      self.fAltitudeMax = _oInfo.altitude;
      self.oTimeAltitudeMax = _oTimeNow;
    }
    // ... session
    if(self.fGlobalAltitudeMin == null or _oInfo.altitude < self.fGlobalAltitudeMin) {
      self.fGlobalAltitudeMin = _oInfo.altitude;
      self.oGlobalTimeAltitudeMin = _oTimeNow;
    }
    if(self.fGlobalAltitudeMax == null or _oInfo.altitude > self.fGlobalAltitudeMax) {
      self.fGlobalAltitudeMax = _oInfo.altitude;
      self.oGlobalTimeAltitudeMax = _oTimeNow;
    }

    // Epoch
    self.iEpochLast = _iEpoch;
  }

  function saveLog(_bSession) {
    // FIT fields
    // ... lap
    self.setDistance(self.fDistance);
    self.setAscent(self.fAscent);
    self.setElapsedAscent(self.iElapsedAscent);
    self.setAltitudeMin(self.fAltitudeMin);
    self.setTimeAltitudeMin(self.oTimeAltitudeMin);
    self.setAltitudeMax(self.fAltitudeMax);
    self.setTimeAltitudeMax(self.oTimeAltitudeMax);
    // ... session
    if(_bSession) {
      self.setGlobalDistance(self.fGlobalDistance);
      self.setGlobalAscent(self.fGlobalAscent);
      self.setGlobalElapsedAscent(self.iGlobalElapsedAscent);
      self.setGlobalAltitudeMin(self.fGlobalAltitudeMin);
      self.setGlobalTimeAltitudeMin(self.oGlobalTimeAltitudeMin);
      self.setGlobalAltitudeMax(self.fGlobalAltitudeMax);
      self.setGlobalTimeAltitudeMax(self.oGlobalTimeAltitudeMax);
    }

    // Log entry
    if(_bSession) {
      var dictLog = {
        "timeStart" => self.oTimeStart != null ? self.oTimeStart.value() : null,
        "timeStop" => self.oTimeStop != null ? self.oTimeStop.value() : null,
        "distance" => self.fGlobalDistance,
        "ascent" => self.fGlobalAscent,
        "elapsedAscent" => self.iGlobalElapsedAscent,
        "altitudeMin" => self.fGlobalAltitudeMin,
        "timeAltitudeMin" => self.oGlobalTimeAltitudeMin != null ? self.oGlobalTimeAltitudeMin.value() : null,
        "altitudeMax" => self.fGlobalAltitudeMax,
        "timeAltitudeMax" => self.oGlobalTimeAltitudeMax != null ? self.oGlobalTimeAltitudeMax.value() : null,
      };
      if($.iMyLogIndex == null) {
        $.iMyLogIndex = 0;
      }
      else {
        $.iMyLogIndex = ($.iMyLogIndex + 1) % $.MY_STORAGE_SLOTS;
      }
      var s = $.iMyLogIndex.format("%02d");
      App.Storage.setValue(Lang.format("storLog$1$", [s]), dictLog);
    }
  }


  //
  // FUNCTIONS: self (fields)
  //

  // Record

  function setBarometricAltitude(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setBarometricAltitude($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_BarometricAltitude.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setVerticalSpeed(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setVerticalSpeed($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_VerticalSpeed.setData(_fValue * self.fUnitCoefficient_VerticalSpeed);
    }
  }

  function setRateOfTurn(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setRateOfTurn($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_RateOfTurn.setData(_fValue * self.fUnitCoefficient_RateOfTurn);
    }
  }

  function setAcceleration(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAcceleration($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_Acceleration.setData(_fValue);
    }
  }

  // Lap

  function resetLapFields() {
    self.setDistance(null);
    self.setAscent(null);
    self.setElapsedAscent(null);
    self.setAltitudeMin(null);
    self.setTimeAltitudeMin(null);
    self.setAltitudeMax(null);
    self.setTimeAltitudeMax(null);
  }

  function setDistance(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setDistance($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_Distance.setData(_fValue * self.fUnitCoefficient_Distance);
    }
  }

  function setAscent(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAscent($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_Ascent.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setElapsedAscent(_iElapsed) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setElapsedAscent($1$)", [_iElapsed]));
    self.oFitField_ElapsedAscent.setData(LangUtils.formatElapsed(_iElapsed, true));
  }

  function setAltitudeMin(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAltitudeMin($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_AltitudeMin.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setTimeAltitudeMin(_oTime) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setTimeAltitudeMin($1$)", [_oTime.value()]));
    self.oFitField_TimeAltitudeMin.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  function setAltitudeMax(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAltitudeMax($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_AltitudeMax.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setTimeAltitudeMax(_oTime) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setTimeAltitudeMax($1$)", [_oTime.value()]));
    self.oFitField_TimeAltitudeMax.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  // Session

  function setGlobalDistance(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalDistance($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_GlobalDistance.setData(_fValue * self.fUnitCoefficient_Distance);
    }
  }

  function setGlobalAscent(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAscent($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_GlobalAscent.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalElapsedAscent(_iElapsed) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalElapsedAscent($1$)", [_iElapsed]));
    self.oFitField_GlobalElapsedAscent.setData(LangUtils.formatElapsed(_iElapsed, true));
  }

  function setGlobalAltitudeMin(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAltitudeMin($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_GlobalAltitudeMin.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalTimeAltitudeMin(_oTime) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalTimeAltitudeMin($1$)", [_oTime.value()]));
    self.oFitField_GlobalTimeAltitudeMin.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  function setGlobalAltitudeMax(_fValue) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAltitudeMax($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_GlobalAltitudeMax.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalTimeAltitudeMax(_oTime) {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalTimeAltitudeMax($1$)", [_oTime.value()]));
    self.oFitField_GlobalTimeAltitudeMax.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

}
