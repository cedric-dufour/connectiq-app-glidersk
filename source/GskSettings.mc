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

  function load() {
    // Units
    self.setUnitDistance(App.Properties.getValue("userUnitDistance"));
    self.setUnitElevation(App.Properties.getValue("userUnitElevation"));
    self.setUnitRateOfTurn(App.Properties.getValue("userUnitRateOfTurn"));
    self.setTimeUTC(App.Properties.getValue("userTimeUTC"));

    // Other settings
    self.setTimeConstant(App.Properties.getValue("userTimeConstant"));
    self.setVariometerRange(App.Properties.getValue("userVariometerRange"));
    self.setVariometerMode(App.Properties.getValue("userVariometerMode"));
    self.setEnergyEfficiency(App.Properties.getValue("userEnergyEfficiency"));
    self.setPlotRange(App.Properties.getValue("userPlotRange"));
    self.setPlotZoom(App.Properties.getValue("userPlotZoom"));
    self.setFinesseReference(App.Properties.getValue("userFinesseReference"));
    self.setHeightDecision(App.Properties.getValue("userHeightDecision"));
    self.setHeightWarning(App.Properties.getValue("userHeightWarning"));
    self.setHeightCritical(App.Properties.getValue("userHeightCritical"));
    self.setBackgroundColor(App.Properties.getValue("userBackgroundColor"));
    self.setVariometerTones(App.Properties.getValue("userVariometerTones"));
    self.setSafetyTones(App.Properties.getValue("userSafetyTones"));
    self.setMuteDistance(App.Properties.getValue("userMuteDistance"));
    self.setLapKey(App.Properties.getValue("userLapKey"));
  }

  function setUnitDistance(_iUnitDistance) {
    if(_iUnitDistance == null or _iUnitDistance < 0 or _iUnitDistance > 2) {
      _iUnitDistance = -1;
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
      self.sUnitDistance = "nm";
      self.fUnitDistanceConstant = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = "kt";
      self.fUnitHorizontalSpeedConstant = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iUnitDistance == Sys.UNIT_STATUTE) {  // ... statute
      // ... [sm]
      self.sUnitDistance = "sm";
      self.fUnitDistanceConstant = 0.000621504039776f;  // ... m -> sm
      // ... [mph]
      self.sUnitHorizontalSpeed = "mph";
      self.fUnitHorizontalSpeedConstant = 2.23741454319f;  // ... m/s -> mph
    }
    else {  // ... metric
      // ... [km]
      self.sUnitDistance = "km";
      self.fUnitDistanceConstant = 0.001f;  // ... m -> km
      // ... [km/h]
      self.sUnitHorizontalSpeed = "km/h";
      self.fUnitHorizontalSpeedConstant = 3.6f;  // ... m/s -> km/h
    }
  }

  function setUnitElevation(_iUnitElevation) {
    if(_iUnitElevation == null or _iUnitElevation < 0 or _iUnitElevation > 1) {
      _iUnitElevation = -1;
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
      self.sUnitElevation = "ft";
      self.fUnitElevationConstant = 3.280839895f;  // ... m -> ft
      // ... [ft/min]
      self.sUnitVerticalSpeed = "ft/m";
      self.fUnitVerticalSpeedConstant = 196.8503937f;  // ... m/s -> ft/min
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = "m";
      self.fUnitElevationConstant = 1.0f;  // ... m -> m
      // ... [m/s]
      self.sUnitVerticalSpeed = "m/s";
      self.fUnitVerticalSpeedConstant = 1.0f;  // ... m/s -> m/s
    }
  }

  function setUnitRateOfTurn(_iUnitRateOfTurn) {
    if(_iUnitRateOfTurn == null or _iUnitRateOfTurn < 0 or _iUnitRateOfTurn > 1) {
      _iUnitRateOfTurn = 0;
    }
    self.iUnitRateOfTurn = _iUnitRateOfTurn;
    if(_iUnitRateOfTurn == 1) {  // ... revolution-per-minute
      // ... [rpm]
      self.sUnitRateOfTurn = "rpm";
      self.fUnitRateOfTurnConstant = 9.54929658551f;  // ... rad/s -> rpm
    }
    else {  // ... degree-per-second
      // ... [deg/s]
      self.sUnitRateOfTurn = "°/s";
      self.fUnitRateOfTurnConstant = 57.2957795131f;  // ... rad/s -> deg/s
    }
  }

  function setTimeUTC(_bTimeUTC) {
    if(_bTimeUTC == null) {
      _bTimeUTC = false;
    }
    if(_bTimeUTC) {
      self.bTimeUTC = true;
      self.sUnitTime = "Z";
    }
    else {
      self.bTimeUTC = false;
      self.sUnitTime = "LT";
    }
  }

  function setTimeConstant(_iTimeConstant) {
    if(_iTimeConstant == null) {
      _iTimeConstant = 3;
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
      _iVariometerRange = 0;
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
      _iVariometerMode = 0;
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
      _iEnergyEfficiency = 75;
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
      _iPlotRange = 1;
    }
    else if(_iPlotRange > 5) {
      _iPlotRange = 5;
    }
    else if(_iPlotRange < 1) {
      _iPlotRange = 1;
    }
    self.iPlotRange = _iPlotRange;
  }

  function setPlotZoom(_iPlotZoom) {
    if(_iPlotZoom == null) {
      _iPlotZoom = 6;
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
      _iFinesseReference = 20;
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
      _fHeightDecision = 500.0f;
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
      _fHeightWarning = 400.0f;
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
      _fHeightCritical = 300.0f;
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
      _iBackgroundColor = Gfx.COLOR_WHITE;
    }
    self.iBackgroundColor = _iBackgroundColor;
  }

  function setVariometerTones(_bVariometerTones) {
    if(_bVariometerTones == null) {
      _bVariometerTones = true;
    }
    self.bVariometerTones = _bVariometerTones;
  }

  function setSafetyTones(_bSafetyTones) {
    if(_bSafetyTones == null) {
      _bSafetyTones = true;
    }
    self.bSafetyTones = _bSafetyTones;
  }

  function setMuteDistance(_fMuteDistance) {
    if(_fMuteDistance == null) {
      _fMuteDistance = 2000.0f;
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
      _bLapKey = true;
    }
    self.bLapKey = _bLapKey;
  }

}
