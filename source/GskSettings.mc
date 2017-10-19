// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Constants
// ... default values
const GSK_SETTINGS_UNITDISTANCE = -1;
const GSK_SETTINGS_UNITELEVATION = -1;
const GSK_SETTINGS_UNITRATEOFTURN = 0;
const GSK_SETTINGS_TIMEUTC = false;
const GSK_SETTINGS_TIMECONSTANT = 3;
const GSK_SETTINGS_VARIOMETERRANGE = 0;
const GSK_SETTINGS_VARIOMETERMODE = 0;
const GSK_SETTINGS_ENERGYEFFICIENCY = 75;
const GSK_SETTINGS_PLOTRANGE = 1;
const GSK_SETTINGS_PLOTZOOM = 6;
const GSK_SETTINGS_FINESSEREFERENCE = 20;
const GSK_SETTINGS_HEIGHTDECISION = 500.0f;
const GSK_SETTINGS_HEIGHTWARNING = 400.0f;
const GSK_SETTINGS_HEIGHTCRITICAL = 300.0f;
const GSK_SETTINGS_BACKGROUNDCOLOR = Gfx.COLOR_WHITE;
const GSK_SETTINGS_VARIOMETERTONES = true;
const GSK_SETTINGS_SAFETYTONES = true;
const GSK_SETTINGS_MUTEDISTANCE = 2000.0f;
const GSK_SETTINGS_LAPKEY = true;

class GskSettings {

  //
  // VARIABLES
  //

  // Units (internal value)
  public var iUnitDistance;
  public var iUnitElevation;
  public var iUnitRateOfTurn;
  public var iVariometerRange;
  public var iVariometerMode;
  public var iEnergyEfficiency;
  public var iPlotZoom;
  public var bTimeUTC;

  // Units
  public var sUnitDistance;
  public var sUnitHorizontalSpeed;
  public var sUnitElevation;
  public var sUnitVerticalSpeed;
  public var sUnitRateOfTurn;
  public var sUnitTime;

  // Units conversion constants
  public var fUnitDistanceConstant;
  public var fUnitHorizontalSpeedConstant;
  public var fUnitElevationConstant;
  public var fUnitVerticalSpeedConstant;
  public var fUnitRateOfTurnConstant;

  // Other constants
  public var iTimeConstant;
  public var fVariometerRange;
  public var fEnergyEfficiency;
  public var iPlotRange;
  public var fPlotZoom;
  public var iFinesseReference;
  public var fHeightDecision;
  public var fHeightWarning;
  public var fHeightCritical;
  public var iBackgroundColor;
  public var bVariometerTones;
  public var bSafetyTones;
  public var fMuteDistance;
  public var bLapKey;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Units
    self.setUnitDistance($.GSK_SETTINGS_UNITDISTANCE);
    self.setUnitElevation($.GSK_SETTINGS_UNITELEVATION);
    self.setUnitRateOfTurn($.GSK_SETTINGS_UNITRATEOFTURN);
    self.setTimeUTC($.GSK_SETTINGS_TIMEUTC);

    // Other constants
    self.setTimeConstant($.GSK_SETTINGS_TIMECONSTANT);
    self.setVariometerRange($.GSK_SETTINGS_VARIOMETERRANGE);
    self.setVariometerMode($.GSK_SETTINGS_VARIOMETERMODE);
    self.setEnergyEfficiency($.GSK_SETTINGS_ENERGYEFFICIENCY);
    self.setPlotRange($.GSK_SETTINGS_PLOTRANGE);
    self.setPlotZoom($.GSK_SETTINGS_PLOTZOOM);
    self.setFinesseReference($.GSK_SETTINGS_FINESSEREFERENCE);
    self.setHeightDecision($.GSK_SETTINGS_HEIGHTDECISION);
    self.setHeightWarning($.GSK_SETTINGS_HEIGHTWARNING);
    self.setHeightCritical($.GSK_SETTINGS_HEIGHTCRITICAL);
    self.setBackgroundColor($.GSK_SETTINGS_BACKGROUNDCOLOR);
    self.setVariometerTones($.GSK_SETTINGS_VARIOMETERTONES);
    self.setSafetyTones($.GSK_SETTINGS_SAFETYTONES);
    self.setMuteDistance($.GSK_SETTINGS_MUTEDISTANCE);
    self.setLapKey($.GSK_SETTINGS_LAPKEY);
  }

  function load() {
    var oApplication = App.getApp();

    // Units
    self.setUnitDistance(oApplication.getProperty("userUnitDistance"));
    self.setUnitElevation(oApplication.getProperty("userUnitElevation"));
    self.setUnitRateOfTurn(oApplication.getProperty("userUnitRateOfTurn"));
    self.setTimeUTC(oApplication.getProperty("userTimeUTC"));

    // Other settings
    self.setTimeConstant(oApplication.getProperty("userTimeConstant"));
    self.setVariometerRange(oApplication.getProperty("userVariometerRange"));
    self.setVariometerMode(oApplication.getProperty("userVariometerMode"));
    self.setEnergyEfficiency(oApplication.getProperty("userEnergyEfficiency"));
    self.setPlotRange(oApplication.getProperty("userPlotRange"));
    self.setPlotZoom(oApplication.getProperty("userPlotZoom"));
    self.setFinesseReference(oApplication.getProperty("userFinesseReference"));
    self.setHeightDecision(oApplication.getProperty("userHeightDecision"));
    self.setHeightWarning(oApplication.getProperty("userHeightWarning"));
    self.setHeightCritical(oApplication.getProperty("userHeightCritical"));
    self.setBackgroundColor(oApplication.getProperty("userBackgroundColor"));
    self.setVariometerTones(oApplication.getProperty("userVariometerTones"));
    self.setSafetyTones(oApplication.getProperty("userSafetyTones"));
    self.setMuteDistance(oApplication.getProperty("userMuteDistance"));
    self.setLapKey(oApplication.getProperty("userLapKey"));
  }

  function setUnitDistance(_iUnitDistance) {
    if(_iUnitDistance == null or _iUnitDistance < 0 or _iUnitDistance > 2) {
      _iUnitDistance = $.GSK_SETTINGS_UNITDISTANCE;
    }
    self.iUnitDistance = _iUnitDistance;
    if(self.iUnitDistance < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        _iUnitDistance = oDeviceSettings.distanceUnits;
      }
      else {
        _iUnitDistance = Sys.UNIT_METRIC;
      }
    }
    if(_iUnitDistance == 2) {  // ... nautical
      // ... [nm]
      self.sUnitDistance = Ui.loadResource(Rez.Strings.unitDistanceNautical);
      self.fUnitDistanceConstant = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = Ui.loadResource(Rez.Strings.unitHorizontalSpeedNautical);
      self.fUnitHorizontalSpeedConstant = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iUnitDistance == Sys.UNIT_STATUTE) {  // ... statute
      // ... [sm]
      self.sUnitDistance = Ui.loadResource(Rez.Strings.unitDistanceStatute);
      self.fUnitDistanceConstant = 0.000621504039776f;  // ... m -> sm
      // ... [mph]
      self.sUnitHorizontalSpeed = Ui.loadResource(Rez.Strings.unitHorizontalSpeedStatute);
      self.fUnitHorizontalSpeedConstant = 2.23741454319f;  // ... m/s -> mph
    }
    else {  // ... metric
      // ... [km]
      self.sUnitDistance = Ui.loadResource(Rez.Strings.unitDistanceMetric);
      self.fUnitDistanceConstant = 0.001f;  // ... m -> km
      // ... [km/h]
      self.sUnitHorizontalSpeed = Ui.loadResource(Rez.Strings.unitHorizontalSpeedMetric);
      self.fUnitHorizontalSpeedConstant = 3.6f;  // ... m/s -> km/h
    }
  }

  function setUnitElevation(_iUnitElevation) {
    if(_iUnitElevation == null or _iUnitElevation < 0 or _iUnitElevation > 1) {
      _iUnitElevation = $.GSK_SETTINGS_UNITELEVATION;
    }
    self.iUnitElevation = _iUnitElevation;
    if(self.iUnitElevation < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
        _iUnitElevation = oDeviceSettings.elevationUnits;
      }
      else {
        _iUnitElevation = Sys.UNIT_METRIC;
      }
    }
    if(_iUnitElevation == Sys.UNIT_STATUTE) {  // ... statute
      // ... [ft]
      self.sUnitElevation = Ui.loadResource(Rez.Strings.unitElevationStatute);
      self.fUnitElevationConstant = 3.280839895f;  // ... m -> ft
      // ... [ft/min]
      self.sUnitVerticalSpeed = Ui.loadResource(Rez.Strings.unitVerticalSpeedStatute);
      self.fUnitVerticalSpeedConstant = 196.8503937f;  // ... m/s -> ft/min
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = Ui.loadResource(Rez.Strings.unitElevationMetric);
      self.fUnitElevationConstant = 1.0f;  // ... m -> m
      // ... [m/s]
      self.sUnitVerticalSpeed = Ui.loadResource(Rez.Strings.unitVerticalSpeedMetric);
      self.fUnitVerticalSpeedConstant = 1.0f;  // ... m/s -> m/s
    }
  }

  function setUnitRateOfTurn(_iUnitRateOfTurn) {
    if(_iUnitRateOfTurn == null or _iUnitRateOfTurn < 0 or _iUnitRateOfTurn > 1) {
      _iUnitRateOfTurn = $.GSK_SETTINGS_UNITRATEOFTURN;
    }
    self.iUnitRateOfTurn = _iUnitRateOfTurn;
    if(_iUnitRateOfTurn == 1) {  // ... revolution-per-minute
      // ... [rpm]
      self.sUnitRateOfTurn = Ui.loadResource(Rez.Strings.unitRateOfTurnRpm);
      self.fUnitRateOfTurnConstant = 9.54929658551f;  // ... rad/s -> rpm
    }
    else {  // ... degree-per-second
      // ... [deg/s]
      self.sUnitRateOfTurn = Ui.loadResource(Rez.Strings.unitRateOfTurnDegree);
      self.fUnitRateOfTurnConstant = 57.2957795131f;  // ... rad/s -> deg/s
    }
  }

  function setTimeUTC(_bTimeUTC) {
    if(_bTimeUTC == null) {
      _bTimeUTC = $.GSK_SETTINGS_TIMEUTC;
    }
    if(_bTimeUTC) {
      self.bTimeUTC = true;
      self.sUnitTime = Ui.loadResource(Rez.Strings.unitTimeUTC);
    }
    else {
      self.bTimeUTC = false;
      self.sUnitTime = Ui.loadResource(Rez.Strings.unitTimeLT);
    }
  }

  function setTimeConstant(_iTimeConstant) {
    if(_iTimeConstant == null) {
      _iTimeConstant = $.GSK_SETTINGS_TIMECONSTANT;
    }
    else if(_iTimeConstant > 10) {
      _iTimeConstant = 10;
    }
    else if(_iTimeConstant < 0) {
      _iTimeConstant = 0;
    }
    self.iTimeConstant = _iTimeConstant;
  }

  function setVariometerRange(_iVariometerRange) {
    if(_iVariometerRange == null) {
      _iVariometerRange = $.GSK_SETTINGS_VARIOMETERRANGE;
    }
    else if(_iVariometerRange > 2) {
      _iVariometerRange = 2;
    }
    else if(_iVariometerRange < 0) {
      _iVariometerRange = 0;
    }
    self.iVariometerRange = _iVariometerRange;
    switch(self.iVariometerRange) {
    case 0: self.fVariometerRange = 3.0f; break;
    case 1: self.fVariometerRange = 6.0f; break;
    case 2: self.fVariometerRange = 9.0f; break;
    }
  }

  function setVariometerMode(_iVariometerMode) {
    if(_iVariometerMode == null) {
      _iVariometerMode = $.GSK_SETTINGS_VARIOMETERMODE;
    }
    else if(_iVariometerMode > 1) {
      _iVariometerMode = 1;
    }
    else if(_iVariometerMode < 0) {
      _iVariometerMode = 0;
    }
    self.iVariometerMode = _iVariometerMode;
  }

  function setEnergyEfficiency(_iEnergyEfficiency) {
    if(_iEnergyEfficiency == null) {
      _iEnergyEfficiency = $.GSK_SETTINGS_ENERGYEFFICIENCY;
    }
    else if(_iEnergyEfficiency > 100) {
      _iEnergyEfficiency = 100;
    }
    else if(_iEnergyEfficiency < 0) {
      _iEnergyEfficiency = 0;
    }
    self.iEnergyEfficiency = _iEnergyEfficiency;
    self.fEnergyEfficiency = self.iEnergyEfficiency / 100.0f;
  }

  function setPlotRange(_iPlotRange) {
    if(_iPlotRange == null) {
      _iPlotRange = $.GSK_SETTINGS_PLOTRANGE;
    }
    else if(_iPlotRange > 10) {
      _iPlotRange = 10;
    }
    else if(_iPlotRange < 1) {
      _iPlotRange = 1;
    }
    self.iPlotRange = _iPlotRange;
  }

  function setPlotZoom(_iPlotZoom) {
    if(_iPlotZoom == null) {
      _iPlotZoom = $.GSK_SETTINGS_PLOTZOOM;
    }
    else if(_iPlotZoom > 9) {
      _iPlotZoom = 9;
    }
    else if(_iPlotZoom < 0) {
      _iPlotZoom = 0;
    }
    self.iPlotZoom = _iPlotZoom;
    switch(self.iPlotZoom) {
    case 0: self.fPlotZoom = 0.0000308666667f; break;  // 1000m/px
    case 1: self.fPlotZoom = 0.0000617333333f; break;  // 500m/px
    case 2: self.fPlotZoom = 0.0001543333333f; break;  // 200m/px
    case 3: self.fPlotZoom = 0.0003086666667f; break;  // 100m/px
    case 4: self.fPlotZoom = 0.0006173333333f; break;  // 50m/px
    case 5: self.fPlotZoom = 0.0015433333333f; break;  // 20m/px
    case 6: self.fPlotZoom = 0.0030866666667f; break;  // 10m/px
    case 7: self.fPlotZoom = 0.0061733333333f; break;  // 5m/px
    case 8: self.fPlotZoom = 0.0154333333333f; break;  // 2m/px
    case 9: self.fPlotZoom = 0.0308666666667f; break;  // 1m/px
    }
  }

  function setFinesseReference(_iFinesseReference) {
    if(_iFinesseReference == null) {
      _iFinesseReference = $.GSK_SETTINGS_FINESSEREFERENCE;
    }
    else if(_iFinesseReference > 99) {
      _iFinesseReference = 99;
    }
    else if(_iFinesseReference < 1) {
      _iFinesseReference = 1;
    }
    self.iFinesseReference = _iFinesseReference;
  }

  function setHeightDecision(_fHeightDecision) {
    if(_fHeightDecision == null) {
      _fHeightDecision = $.GSK_SETTINGS_HEIGHTDECISION;
    }
    else if(_fHeightDecision > 9999.0f) {
      _fHeightDecision = 9999.0f;
    }
    else if(_fHeightDecision < 0.0f) {
      _fHeightDecision = 0.0f;
    }
    self.fHeightDecision = _fHeightDecision;
  }

  function setHeightWarning(_fHeightWarning) {
    if(_fHeightWarning == null) {
      _fHeightWarning = $.GSK_SETTINGS_HEIGHTWARNING;
    }
    else if(_fHeightWarning > 9999.0f) {
      _fHeightWarning = 9999.0f;
    }
    else if(_fHeightWarning < 0.0f) {
      _fHeightWarning = 0.0f;
    }
    self.fHeightWarning = _fHeightWarning;
  }

  function setHeightCritical(_fHeightCritical) {
    if(_fHeightCritical == null) {
      _fHeightCritical = $.GSK_SETTINGS_HEIGHTCRITICAL;
    }
    else if(_fHeightCritical > 9999.0f) {
      _fHeightCritical = 9999.0f;
    }
    else if(_fHeightCritical < 0.0f) {
      _fHeightCritical = 0.0f;
    }
    self.fHeightCritical = _fHeightCritical;
  }

  function setBackgroundColor(_iBackgroundColor) {
    if(_iBackgroundColor == null) {
      _iBackgroundColor = $.GSK_SETTINGS_BACKGROUNDCOLOR;
    }
    self.iBackgroundColor = _iBackgroundColor;
  }

  function setVariometerTones(_bVariometerTones) {
    if(_bVariometerTones == null) {
      _bVariometerTones = $.GSK_SETTINGS_VARIOMETERTONES;
    }
    self.bVariometerTones = _bVariometerTones;
  }

  function setSafetyTones(_bSafetyTones) {
    if(_bSafetyTones == null) {
      _bSafetyTones = $.GSK_SETTINGS_SAFETYTONES;
    }
    self.bSafetyTones = _bSafetyTones;
  }

  function setMuteDistance(_fMuteDistance) {
    if(_fMuteDistance == null) {
      _fMuteDistance = $.GSK_SETTINGS_MUTEDISTANCE;
    }
    else if(_fMuteDistance > 9999.0f) {
      _fMuteDistance = 9999.0f;
    }
    else if(_fMuteDistance < 0.0f) {
      _fMuteDistance = 0.0f;
    }
    self.fMuteDistance = _fMuteDistance;
  }

  function setLapKey(_bLapKey) {
    if(_bLapKey == null) {
      _bLapKey = $.GSK_SETTINGS_LAPKEY;
    }
    self.bLapKey = _bLapKey;
  }

}
