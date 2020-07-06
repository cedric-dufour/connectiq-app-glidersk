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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class GSK_Settings {

  //
  // VARIABLES
  //

  // Settings
  // ... altimeter
  public var fAltimeterCalibrationQNH;
  public var fAltimeterCorrectionAbsolute;
  public var fAltimeterCorrectionRelative;
  // ... variometer
  public var iVariometerRange;
  public var iVariometerMode;
  public var iVariometerEnergyEfficiency;
  public var iVariometerPlotRange;
  public var iVariometerPlotZoom;
  // ... safety
  public var iSafetyFinesse;
  public var fSafetyHeightDecision;
  public var fSafetyHeightWarning;
  public var fSafetyHeightCritical;
  public var fSafetyHeightReference;
  public var iSafetyHeadingBug;
  public var iSafetyGraceDuration;
  // ... sounds
  public var bSoundsVariometerTones;
  public var bSoundsSafetyTones;
  public var fSoundsMuteDistance;
  // ... general
  public var iGeneralTimeConstant;
  public var iGeneralDisplayFilter;
  public var iGeneralBackgroundColor;
  public var bGeneralAutoActivity;
  public var bGeneralLapKey;
  // ... units
  public var iUnitDistance;
  public var iUnitElevation;
  public var iUnitPressure;
  public var iUnitRateOfTurn;
  public var bUnitTimeUTC;

  // Units
  // ... symbols
  public var sUnitDistance;
  public var sUnitHorizontalSpeed;
  public var sUnitElevation;
  public var sUnitVerticalSpeed;
  public var sUnitPressure;
  public var sUnitRateOfTurn;
  public var sUnitTime;
  // ... conversion coefficients
  public var fUnitDistanceCoefficient;
  public var fUnitHorizontalSpeedCoefficient;
  public var fUnitElevationCoefficient;
  public var fUnitVerticalSpeedCoefficient;
  public var fUnitPressureCoefficient;
  public var fUnitRateOfTurnCoefficient;

  // Other
  public var fVariometerRange;
  public var fVariometerEnergyEfficiency;
  public var fVariometerPlotZoom;


  //
  // FUNCTIONS: self
  //

  function load() {
    // Settings
    // ... altimeter
    self.setAltimeterCalibrationQNH(App.Properties.getValue("userAltimeterCalibrationQNH"));
    self.setAltimeterCorrectionAbsolute(App.Properties.getValue("userAltimeterCorrectionAbsolute"));
    self.setAltimeterCorrectionRelative(App.Properties.getValue("userAltimeterCorrectionRelative"));
    // ... variometer
    self.setVariometerRange(App.Properties.getValue("userVariometerRange"));
    self.setVariometerMode(App.Properties.getValue("userVariometerMode"));
    self.setVariometerEnergyEfficiency(App.Properties.getValue("userVariometerEnergyEfficiency"));
    self.setVariometerPlotRange(App.Properties.getValue("userVariometerPlotRange"));
    self.setVariometerPlotZoom(App.Properties.getValue("userVariometerPlotZoom"));
    // ... safety
    self.setSafetyFinesse(App.Properties.getValue("userSafetyFinesse"));
    self.setSafetyHeightDecision(App.Properties.getValue("userSafetyHeightDecision"));
    self.setSafetyHeightWarning(App.Properties.getValue("userSafetyHeightWarning"));
    self.setSafetyHeightCritical(App.Properties.getValue("userSafetyHeightCritical"));
    self.setSafetyHeightReference(App.Properties.getValue("userSafetyHeightReference"));
    self.setSafetyHeadingBug(App.Properties.getValue("userSafetyHeadingBug"));
    self.setSafetyGraceDuration(App.Properties.getValue("userSafetyGraceDuration"));
    // ... sounds
    self.setSoundsVariometerTones(App.Properties.getValue("userSoundsVariometerTones"));
    self.setSoundsSafetyTones(App.Properties.getValue("userSoundsSafetyTones"));
    self.setSoundsMuteDistance(App.Properties.getValue("userSoundsMuteDistance"));
    // ... general
    self.setGeneralTimeConstant(App.Properties.getValue("userGeneralTimeConstant"));
    self.setGeneralDisplayFilter(App.Properties.getValue("userGeneralDisplayFilter"));
    self.setGeneralBackgroundColor(App.Properties.getValue("userGeneralBackgroundColor"));
    self.setGeneralAutoActivity(App.Properties.getValue("userGeneralAutoActivity"));
    self.setGeneralLapKey(App.Properties.getValue("userGeneralLapKey"));
    // ... units
    self.setUnitDistance(App.Properties.getValue("userUnitDistance"));
    self.setUnitElevation(App.Properties.getValue("userUnitElevation"));
    self.setUnitPressure(App.Properties.getValue("userUnitPressure"));
    self.setUnitRateOfTurn(App.Properties.getValue("userUnitRateOfTurn"));
    self.setUnitTimeUTC(App.Properties.getValue("userUnitTimeUTC"));
  }

  function setAltimeterCalibrationQNH(_fAltimeterCalibrationQNH) {  // [Pa]
    // REF: https://en.wikipedia.org/wiki/Atmospheric_pressure#Records
    if(_fAltimeterCalibrationQNH == null) {
      _fAltimeterCalibrationQNH = 101325.0f;
    }
    else if(_fAltimeterCalibrationQNH > 110000.0f) {
      _fAltimeterCalibrationQNH = 110000.0f;
    }
    else if(_fAltimeterCalibrationQNH < 85000.0f) {
      _fAltimeterCalibrationQNH = 85000.0f;
    }
    self.fAltimeterCalibrationQNH = _fAltimeterCalibrationQNH;
  }

  function setAltimeterCorrectionAbsolute(_fAltimeterCorrectionAbsolute) {  // [Pa]
    if(_fAltimeterCorrectionAbsolute == null) {
      _fAltimeterCorrectionAbsolute = 0.0f;
    }
    else if(_fAltimeterCorrectionAbsolute > 9999.0f) {
      _fAltimeterCorrectionAbsolute = 9999.0f;
    }
    else if(_fAltimeterCorrectionAbsolute < -9999.0f) {
      _fAltimeterCorrectionAbsolute = -9999.0f;
    }
    self.fAltimeterCorrectionAbsolute = _fAltimeterCorrectionAbsolute;
  }

  function setAltimeterCorrectionRelative(_fAltimeterCorrectionRelative) {
    if(_fAltimeterCorrectionRelative == null) {
      _fAltimeterCorrectionRelative = 1.0f;
    }
    else if(_fAltimeterCorrectionRelative > 1.9999f) {
      _fAltimeterCorrectionRelative = 1.9999f;
    }
    else if(_fAltimeterCorrectionRelative < 0.0001f) {
      _fAltimeterCorrectionRelative = 0.0001f;
    }
    self.fAltimeterCorrectionRelative = _fAltimeterCorrectionRelative;
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

  function setVariometerEnergyEfficiency(_iVariometerEnergyEfficiency) {  // [%]
    if(_iVariometerEnergyEfficiency == null) {
      _iVariometerEnergyEfficiency = 75;
    }
    else if(_iVariometerEnergyEfficiency > 100) {
      _iVariometerEnergyEfficiency = 100;
    }
    else if(_iVariometerEnergyEfficiency < 0) {
      _iVariometerEnergyEfficiency = 0;
    }
    self.iVariometerEnergyEfficiency = _iVariometerEnergyEfficiency;
    self.fVariometerEnergyEfficiency = self.iVariometerEnergyEfficiency / 100.0f;
  }

  function setVariometerPlotRange(_iVariometerPlotRange) {
    if(_iVariometerPlotRange == null) {
      _iVariometerPlotRange = 1;
    }
    else if(_iVariometerPlotRange > 5) {
      _iVariometerPlotRange = 5;
    }
    else if(_iVariometerPlotRange < 1) {
      _iVariometerPlotRange = 1;
    }
    self.iVariometerPlotRange = _iVariometerPlotRange;
  }

  function setVariometerPlotZoom(_iVariometerPlotZoom) {
    if(_iVariometerPlotZoom == null) {
      _iVariometerPlotZoom = 6;
    }
    else if(_iVariometerPlotZoom > 9) {
      _iVariometerPlotZoom = 9;
    }
    else if(_iVariometerPlotZoom < 0) {
      _iVariometerPlotZoom = 0;
    }
    self.iVariometerPlotZoom = _iVariometerPlotZoom;
    switch(self.iVariometerPlotZoom) {
    case 0: self.fVariometerPlotZoom = 0.0000308666667f; break;  // 1000m/px
    case 1: self.fVariometerPlotZoom = 0.0000617333333f; break;  // 500m/px
    case 2: self.fVariometerPlotZoom = 0.0001543333333f; break;  // 200m/px
    case 3: self.fVariometerPlotZoom = 0.0003086666667f; break;  // 100m/px
    case 4: self.fVariometerPlotZoom = 0.0006173333333f; break;  // 50m/px
    case 5: self.fVariometerPlotZoom = 0.0015433333333f; break;  // 20m/px
    case 6: self.fVariometerPlotZoom = 0.0030866666667f; break;  // 10m/px
    case 7: self.fVariometerPlotZoom = 0.0061733333333f; break;  // 5m/px
    case 8: self.fVariometerPlotZoom = 0.0154333333333f; break;  // 2m/px
    case 9: self.fVariometerPlotZoom = 0.0308666666667f; break;  // 1m/px
    }
  }

  function setSafetyFinesse(_iSafetyFinesse) {
    if(_iSafetyFinesse == null) {
      _iSafetyFinesse = 20;
    }
    else if(_iSafetyFinesse > 99) {
      _iSafetyFinesse = 99;
    }
    else if(_iSafetyFinesse < 1) {
      _iSafetyFinesse = 1;
    }
    self.iSafetyFinesse = _iSafetyFinesse;
  }

  function setSafetyHeightDecision(_fSafetyHeightDecision) {  // [m]
    if(_fSafetyHeightDecision == null) {
      _fSafetyHeightDecision = 500.0f;
    }
    else if(_fSafetyHeightDecision > 9999.0f) {
      _fSafetyHeightDecision = 9999.0f;
    }
    else if(_fSafetyHeightDecision < 0.0f) {
      _fSafetyHeightDecision = 0.0f;
    }
    self.fSafetyHeightDecision = _fSafetyHeightDecision;
  }

  function setSafetyHeightWarning(_fSafetyHeightWarning) {  // [m]
    if(_fSafetyHeightWarning == null) {
      _fSafetyHeightWarning = 400.0f;
    }
    else if(_fSafetyHeightWarning > 9999.0f) {
      _fSafetyHeightWarning = 9999.0f;
    }
    else if(_fSafetyHeightWarning < 0.0f) {
      _fSafetyHeightWarning = 0.0f;
    }
    self.fSafetyHeightWarning = _fSafetyHeightWarning;
  }

  function setSafetyHeightCritical(_fSafetyHeightCritical) {  // [m]
    if(_fSafetyHeightCritical == null) {
      _fSafetyHeightCritical = 300.0f;
    }
    else if(_fSafetyHeightCritical > 9999.0f) {
      _fSafetyHeightCritical = 9999.0f;
    }
    else if(_fSafetyHeightCritical < 0.0f) {
      _fSafetyHeightCritical = 0.0f;
    }
    self.fSafetyHeightCritical = _fSafetyHeightCritical;
  }

  function setSafetyHeightReference(_fSafetyHeightReference) {  // [m]
    if(_fSafetyHeightReference == null) {
      _fSafetyHeightReference = 300.0f;
    }
    else if(_fSafetyHeightReference > 9999.0f) {
      _fSafetyHeightReference = 9999.0f;
    }
    else if(_fSafetyHeightReference < 0.0f) {
      _fSafetyHeightReference = 0.0f;
    }
    self.fSafetyHeightReference = _fSafetyHeightReference;
  }

  function setSafetyHeadingBug(_iSafetyHeadingBug) {
    if(_iSafetyHeadingBug == null) {
      _iSafetyHeadingBug = 2;
    }
    else if(_iSafetyHeadingBug > 2) {
      _iSafetyHeadingBug = 2;
    }
    else if(_iSafetyHeadingBug < 0) {
      _iSafetyHeadingBug = 0;
    }
    self.iSafetyHeadingBug = _iSafetyHeadingBug;
  }

  function setSafetyGraceDuration(_iSafetyGraceDuration) {  // [s]
    if(_iSafetyGraceDuration == null) {
      _iSafetyGraceDuration = 0;
    }
    else if(_iSafetyGraceDuration > 3600) {
      _iSafetyGraceDuration = 3600;
    }
    else if(_iSafetyGraceDuration < 0) {
      _iSafetyGraceDuration = 0;
    }
    self.iSafetyGraceDuration = _iSafetyGraceDuration;
  }

  function setSoundsVariometerTones(_bSoundsVariometerTones) {
    if(_bSoundsVariometerTones == null) {
      _bSoundsVariometerTones = true;
    }
    self.bSoundsVariometerTones = _bSoundsVariometerTones;
  }

  function setSoundsSafetyTones(_bSoundsSafetyTones) {
    if(_bSoundsSafetyTones == null) {
      _bSoundsSafetyTones = true;
    }
    self.bSoundsSafetyTones = _bSoundsSafetyTones;
  }

  function setSoundsMuteDistance(_fSoundsMuteDistance) {  // [m]
    if(_fSoundsMuteDistance == null) {
      _fSoundsMuteDistance = 2000.0f;
    }
    else if(_fSoundsMuteDistance > 9999.0f) {
      _fSoundsMuteDistance = 9999.0f;
    }
    else if(_fSoundsMuteDistance < 0.0f) {
      _fSoundsMuteDistance = 0.0f;
    }
    self.fSoundsMuteDistance = _fSoundsMuteDistance;
  }

  function setGeneralTimeConstant(_iGeneralTimeConstant) {  // [s]
    if(_iGeneralTimeConstant == null) {
      _iGeneralTimeConstant = 5;
    }
    else if(_iGeneralTimeConstant > 60) {
      _iGeneralTimeConstant = 60;
    }
    else if(_iGeneralTimeConstant < 0) {
      _iGeneralTimeConstant = 0;
    }
    self.iGeneralTimeConstant = _iGeneralTimeConstant;
  }

  function setGeneralDisplayFilter(_iGeneralDisplayFilter) {
    if(_iGeneralDisplayFilter == null or _iGeneralDisplayFilter < 0 or _iGeneralDisplayFilter > 2) {
      _iGeneralDisplayFilter = 1;
    }
    self.iGeneralDisplayFilter = _iGeneralDisplayFilter;
  }

  function setGeneralBackgroundColor(_iGeneralBackgroundColor) {
    if(_iGeneralBackgroundColor == null) {
      _iGeneralBackgroundColor = Gfx.COLOR_WHITE;
    }
    self.iGeneralBackgroundColor = _iGeneralBackgroundColor;
  }

  function setGeneralAutoActivity(_bGeneralAutoActivity) {
    if(_bGeneralAutoActivity == null) {
      _bGeneralAutoActivity = false;
    }
    self.bGeneralAutoActivity = _bGeneralAutoActivity;
  }

  function setGeneralLapKey(_bGeneralLapKey) {
    if(_bGeneralLapKey == null) {
      _bGeneralLapKey = true;
    }
    self.bGeneralLapKey = _bGeneralLapKey;
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
      self.fUnitDistanceCoefficient = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = "kt";
      self.fUnitHorizontalSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iUnitDistance == Sys.UNIT_STATUTE) {  // ... statute
      // ... [sm]
      self.sUnitDistance = "sm";
      self.fUnitDistanceCoefficient = 0.000621371192237f;  // ... m -> sm
      // ... [mph]
      self.sUnitHorizontalSpeed = "mph";
      self.fUnitHorizontalSpeedCoefficient = 2.23693629205f;  // ... m/s -> mph
    }
    else {  // ... metric
      // ... [km]
      self.sUnitDistance = "km";
      self.fUnitDistanceCoefficient = 0.001f;  // ... m -> km
      // ... [km/h]
      self.sUnitHorizontalSpeed = "km/h";
      self.fUnitHorizontalSpeedCoefficient = 3.6f;  // ... m/s -> km/h
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
      self.fUnitElevationCoefficient = 3.280839895f;  // ... m -> ft
      // ... [ft/min]
      self.sUnitVerticalSpeed = "ft/m";
      self.fUnitVerticalSpeedCoefficient = 196.8503937f;  // ... m/s -> ft/min
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = "m";
      self.fUnitElevationCoefficient = 1.0f;  // ... m -> m
      // ... [m/s]
      self.sUnitVerticalSpeed = "m/s";
      self.fUnitVerticalSpeedCoefficient = 1.0f;  // ... m/s -> m/s
    }
  }

  function setUnitPressure(_iUnitPressure) {
    if(_iUnitPressure == null or _iUnitPressure < 0 or _iUnitPressure > 1) {
      _iUnitPressure = -1;
    }
    self.iUnitPressure = _iUnitPressure;
    if(self.iUnitPressure < 0) {  // ... auto
      // NOTE: assume weight units are a good indicator of preferred pressure units
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :weightUnits and oDeviceSettings.weightUnits != null) {
        _iUnitPressure = oDeviceSettings.weightUnits;
      }
      else {
        _iUnitPressure = Sys.UNIT_METRIC;
      }
    }
    if(_iUnitPressure == Sys.UNIT_STATUTE) {  // ... statute
      // ... [inHg]
      self.sUnitPressure = "inHg";
      self.fUnitPressureCoefficient = 0.0002953f;  // ... Pa -> inHg
    }
    else {  // ... metric
      // ... [mb/hPa]
      self.sUnitPressure = "mb";
      self.fUnitPressureCoefficient = 0.01f;  // ... Pa -> mb/hPa
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
      self.fUnitRateOfTurnCoefficient = 9.54929658551f;  // ... rad/s -> rpm
    }
    else {  // ... degree-per-second
      // ... [deg/s]
      self.sUnitRateOfTurn = "°/s";
      self.fUnitRateOfTurnCoefficient = 57.2957795131f;  // ... rad/s -> deg/s
    }
  }

  function setUnitTimeUTC(_bUnitTimeUTC) {
    if(_bUnitTimeUTC == null) {
      _bUnitTimeUTC = false;
    }
    if(_bUnitTimeUTC) {
      self.bUnitTimeUTC = true;
      self.sUnitTime = "Z";
    }
    else {
      self.bUnitTimeUTC = false;
      self.sUnitTime = "LT";
    }
  }

}
