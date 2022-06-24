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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MySettings {

  //
  // VARIABLES
  //

  // Settings
  // ... altimeter
  public var fAltimeterCalibrationQNH as Float = 101325.0f;
  public var fAltimeterCorrectionAbsolute as Float = 0.0f;
  public var fAltimeterCorrectionRelative as Float = 1.0f;
  // ... variometer
  public var iVariometerRange as Number = 0;
  public var iVariometerMode as Number = 0;
  public var iVariometerEnergyEfficiency as Number = 75;
  public var iVariometerPlotRange as Number = 1;
  public var iVariometerPlotZoom as Number = 6;
  // ... safety
  public var iSafetyFinesse as Number = 20;
  public var fSafetyHeightDecision as Float = 500.0f;
  public var fSafetyHeightWarning as Float = 400.0f;
  public var fSafetyHeightCritical as Float = 300.0f;
  public var fSafetyHeightReference as Float = 300.0f;
  public var iSafetyHeadingBug as Number = 2;
  public var iSafetyGraceDuration as Number = 0;
  // ... sounds
  public var bSoundsVariometerTones as Boolean = true;
  public var bSoundsSafetyTones as Boolean = true;
  public var fSoundsMuteDistance as Float = 2000.0f;
  // ... activity
  public var bActivityAuto as Boolean = false;
  public var fActivityAutoSpeedStart as Float = 9.0f;
  public var fActivityAutoSpeedStop as Float = 3.0f;
  // ... general
  public var iGeneralTimeConstant as Number = 5;
  public var iGeneralDisplayFilter as Number = 1;
  public var iGeneralBackgroundColor as Number = Gfx.COLOR_WHITE;
  public var bGeneralLapKey as Boolean = true;
  // ... units
  public var iUnitDistance as Number = -1;
  public var iUnitElevation as Number = -1;
  public var iUnitPressure as Number = -1;
  public var iUnitRateOfTurn as Number = 0;
  public var bUnitTimeUTC as Boolean = false;

  // Units
  // ... symbols
  public var sUnitDistance as String = "km";
  public var sUnitHorizontalSpeed as String = "km/h";
  public var sUnitElevation as String = "m";
  public var sUnitVerticalSpeed as String = "m/s";
  public var sUnitPressure as String = "mb";
  public var sUnitRateOfTurn as String = "°/s";
  public var sUnitTime as String = "LT";
  // ... conversion coefficients
  public var fUnitDistanceCoefficient as Float = 0.001f;
  public var fUnitHorizontalSpeedCoefficient as Float = 3.6f;
  public var fUnitElevationCoefficient as Float = 1.0f;
  public var fUnitVerticalSpeedCoefficient as Float = 1.0f;
  public var fUnitPressureCoefficient as Float = 0.01f;
  public var fUnitRateOfTurnCoefficient as Float = 57.2957795131f;

  // Other
  public var fVariometerRange as Float = 3.0f;
  public var fVariometerEnergyEfficiency as Float = 0.75f;
  public var fVariometerPlotZoom as Float = 0.0030866666667f;


  //
  // FUNCTIONS: self
  //

  function load() as Void {
    // Settings
    // ... altimeter
    self.setAltimeterCalibrationQNH(self.loadAltimeterCalibrationQNH());
    self.setAltimeterCorrectionAbsolute(self.loadAltimeterCorrectionAbsolute());
    self.setAltimeterCorrectionRelative(self.loadAltimeterCorrectionRelative());
    // ... variometer
    self.setVariometerRange(self.loadVariometerRange());
    self.setVariometerMode(self.loadVariometerMode());
    self.setVariometerEnergyEfficiency(self.loadVariometerEnergyEfficiency());
    self.setVariometerPlotRange(self.loadVariometerPlotRange());
    self.setVariometerPlotZoom(self.loadVariometerPlotZoom());
    // ... safety
    self.setSafetyFinesse(self.loadSafetyFinesse());
    self.setSafetyHeightDecision(self.loadSafetyHeightDecision());
    self.setSafetyHeightWarning(self.loadSafetyHeightWarning());
    self.setSafetyHeightCritical(self.loadSafetyHeightCritical());
    self.setSafetyHeightReference(self.loadSafetyHeightReference());
    self.setSafetyHeadingBug(self.loadSafetyHeadingBug());
    self.setSafetyGraceDuration(self.loadSafetyGraceDuration());
    // ... sounds
    self.setSoundsVariometerTones(self.loadSoundsVariometerTones());
    self.setSoundsSafetyTones(self.loadSoundsSafetyTones());
    self.setSoundsMuteDistance(self.loadSoundsMuteDistance());
    // ... activity
    self.setActivityAuto(self.loadActivityAuto());
    self.setActivityAutoSpeedStart(self.loadActivityAutoSpeedStart());
    self.setActivityAutoSpeedStop(self.loadActivityAutoSpeedStop());
    // ... general
    self.setGeneralTimeConstant(self.loadGeneralTimeConstant());
    self.setGeneralDisplayFilter(self.loadGeneralDisplayFilter());
    self.setGeneralBackgroundColor(self.loadGeneralBackgroundColor());
    self.setGeneralLapKey(self.loadGeneralLapKey());
    // ... units
    self.setUnitDistance(self.loadUnitDistance());
    self.setUnitElevation(self.loadUnitElevation());
    self.setUnitPressure(self.loadUnitPressure());
    self.setUnitRateOfTurn(self.loadUnitRateOfTurn());
    self.setUnitTimeUTC(self.loadUnitTimeUTC());
  }

  // WARNING: Make sure to cast the properties values to the expected type!
  // REF: https://forums.garmin.com/developer/connect-iq/w/wiki/4/new-developer-faq#settings-crash
  // ACKNOWLEDGMENT: Yannick Dutertre for the heads up and pointer

  function loadAltimeterCalibrationQNH() as Float {  // [Pa]
    return LangUtils.asFloat(App.Properties.getValue("userAltimeterCalibrationQNH"), 101325.0f);
  }
  function saveAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    App.Properties.setValue("userAltimeterCalibrationQNH", _fValue as App.PropertyValueType);
  }
  function setAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    // REF: https://en.wikipedia.org/wiki/Atmospheric_pressure#Records
    if(_fValue > 110000.0f) {
      _fValue = 110000.0f;
    }
    else if(_fValue < 85000.0f) {
      _fValue = 85000.0f;
    }
    self.fAltimeterCalibrationQNH = _fValue;
  }

  function loadAltimeterCorrectionAbsolute() as Float {  // [Pa]
    return LangUtils.asFloat(App.Properties.getValue("userAltimeterCorrectionAbsolute"), 0.0f);
  }
  function saveAltimeterCorrectionAbsolute(_fValue as Float) as Void {  // [Pa]
    App.Properties.setValue("userAltimeterCorrectionAbsolute", _fValue as App.PropertyValueType);
  }
  function setAltimeterCorrectionAbsolute(_fValue as Float) as Void {  // [Pa]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < -9999.0f) {
      _fValue = -9999.0f;
    }
    self.fAltimeterCorrectionAbsolute = _fValue;
  }

  function loadAltimeterCorrectionRelative() as Float {
    return LangUtils.asFloat(App.Properties.getValue("userAltimeterCorrectionRelative"), 1.0f);
  }
  function saveAltimeterCorrectionRelative(_fValue as Float) as Void {
    App.Properties.setValue("userAltimeterCorrectionRelative", _fValue as App.PropertyValueType);
  }
  function setAltimeterCorrectionRelative(_fValue as Float) as Void {
    if(_fValue > 1.9999f) {
      _fValue = 1.9999f;
    }
    else if(_fValue < 0.0001f) {
      _fValue = 0.0001f;
    }
    self.fAltimeterCorrectionRelative = _fValue;
  }

  function loadVariometerRange() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userVariometerRange"), 0);
  }
  function saveVariometerRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerRange", _iValue as App.PropertyValueType);
  }
  function setVariometerRange(_iValue as Number) as Void {
    if(_iValue > 2) {
      _iValue = 2;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerRange = _iValue;
    switch(self.iVariometerRange) {
    case 0: self.fVariometerRange = 3.0f; break;
    case 1: self.fVariometerRange = 6.0f; break;
    case 2: self.fVariometerRange = 9.0f; break;
    }
  }

  function loadVariometerMode() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userVariometerMode"), 0);
  }
  function saveVariometerMode(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerMode", _iValue as App.PropertyValueType);
  }
  function setVariometerMode(_iValue as Number) as Void {
    if(_iValue > 1) {
      _iValue = 1;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerMode = _iValue;
  }

  function loadVariometerEnergyEfficiency() as Number {  // [%]
    return LangUtils.asNumber(App.Properties.getValue("userVariometerEnergyEfficiency"), 75);
  }
  function saveVariometerEnergyEfficiency(_iValue as Number) as Void {  // [%]
    App.Properties.setValue("userVariometerEnergyEfficiency", _iValue as App.PropertyValueType);
  }
  function setVariometerEnergyEfficiency(_iValue as Number) as Void {  // [%]
    if(_iValue > 100) {
      _iValue = 100;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerEnergyEfficiency = _iValue;
    self.fVariometerEnergyEfficiency = self.iVariometerEnergyEfficiency / 100.0f;
  }

  function loadVariometerPlotRange() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userVariometerPlotRange"), 1);
  }
  function saveVariometerPlotRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotRange", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotRange(_iValue as Number) as Void {
    if(_iValue > 5) {
      _iValue = 5;
    }
    else if(_iValue < 1) {
      _iValue = 1;
    }
    self.iVariometerPlotRange = _iValue;
  }

  function loadVariometerPlotZoom() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userVariometerPlotZoom"), 6);
  }
  function saveVariometerPlotZoom(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotZoom", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotZoom(_iValue as Number) as Void {
    if(_iValue > 9) {
      _iValue = 9;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerPlotZoom = _iValue;
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

  function loadSafetyFinesse() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userSafetyFinesse"), 20);
  }
  function saveSafetyFinesse(_iValue as Number) as Void {
    App.Properties.setValue("userSafetyFinesse", _iValue as App.PropertyValueType);
  }
  function setSafetyFinesse(_iValue as Number) as Void {
    if(_iValue > 99) {
      _iValue = 99;
    }
    else if(_iValue < 1) {
      _iValue = 1;
    }
    self.iSafetyFinesse = _iValue;
  }

  function loadSafetyHeightDecision() as Float {  // [m]
    return LangUtils.asFloat(App.Properties.getValue("userSafetyHeightDecision"), 500.0f);
  }
  function saveSafetyHeightDecision(_fValue as Float) as Void {  // [m]
    App.Properties.setValue("userSafetyHeightDecision", _fValue as App.PropertyValueType);
  }
  function setSafetyHeightDecision(_fValue as Float) as Void {  // [m]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fSafetyHeightDecision = _fValue;
  }

  function loadSafetyHeightWarning() as Float {  // [m]
    return LangUtils.asFloat(App.Properties.getValue("userSafetyHeightWarning"), 400.0f);
  }
  function saveSafetyHeightWarning(_fValue as Float) as Void {  // [m]
    App.Properties.setValue("userSafetyHeightWarning", _fValue as App.PropertyValueType);
  }
  function setSafetyHeightWarning(_fValue as Float) as Void {  // [m]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fSafetyHeightWarning = _fValue;
  }

  function loadSafetyHeightCritical() as Float {  // [m]
    return LangUtils.asFloat(App.Properties.getValue("userSafetyHeightCritical"), 300.0f);
  }
  function saveSafetyHeightCritical(_fValue as Float) as Void {  // [m]
    App.Properties.setValue("userSafetyHeightCritical", _fValue as App.PropertyValueType);
  }
  function setSafetyHeightCritical(_fValue as Float) as Void {  // [m]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fSafetyHeightCritical = _fValue;
  }

  function loadSafetyHeightReference() as Float {  // [m]
    return LangUtils.asFloat(App.Properties.getValue("userSafetyHeightReference"), 300.0f);
  }
  function saveSafetyHeightReference(_fValue as Float) as Void {  // [m]
    App.Properties.setValue("userSafetyHeightReference", _fValue as App.PropertyValueType);
  }
  function setSafetyHeightReference(_fValue as Float) as Void {  // [m]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fSafetyHeightReference = _fValue;
  }

  function loadSafetyHeadingBug() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userSafetyHeadingBug"), 2);
  }
  function saveSafetyHeadingBug(_iValue as Number) as Void {
    App.Properties.setValue("userSafetyHeadingBug", _iValue as App.PropertyValueType);
  }
  function setSafetyHeadingBug(_iValue as Number) as Void {
    if(_iValue > 2) {
      _iValue = 2;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iSafetyHeadingBug = _iValue;
  }

  function loadSafetyGraceDuration() as Number {  // [s]
    return LangUtils.asNumber(App.Properties.getValue("userSafetyGraceDuration"), 0);
  }
  function saveSafetyGraceDuration(_iValue as Number) as Void {  // [s]
    App.Properties.setValue("userSafetyGraceDuration", _iValue as App.PropertyValueType);
  }
  function setSafetyGraceDuration(_iValue as Number) as Void {  // [s]
    if(_iValue > 3600) {
      _iValue = 3600;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iSafetyGraceDuration = _iValue;
  }

  function loadSoundsVariometerTones() as Boolean {
    return LangUtils.asBoolean(App.Properties.getValue("userSoundsVariometerTones"), true);
  }
  function saveSoundsVariometerTones(_bValue as Boolean) as Void {
    App.Properties.setValue("userSoundsVariometerTones", _bValue as App.PropertyValueType);
  }
  function setSoundsVariometerTones(_bValue as Boolean) as Void {
    self.bSoundsVariometerTones = _bValue;
  }

  function loadSoundsSafetyTones() as Boolean {
    return LangUtils.asBoolean(App.Properties.getValue("userSoundsSafetyTones"), true);
  }
  function saveSoundsSafetyTones(_bValue as Boolean) as Void {
    App.Properties.setValue("userSoundsSafetyTones", _bValue as App.PropertyValueType);
  }
  function setSoundsSafetyTones(_bValue as Boolean) as Void {
    self.bSoundsSafetyTones = _bValue;
  }

  function loadSoundsMuteDistance() as Float {  // [m]
    return LangUtils.asFloat(App.Properties.getValue("userSoundsMuteDistance"), 2000.0f);
  }
  function saveSoundsMuteDistance(_fValue as Float) as Void {  // [m]
    App.Properties.setValue("userSoundsMuteDistance", _fValue as App.PropertyValueType);
  }
  function setSoundsMuteDistance(_fValue as Float) as Void {  // [m]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fSoundsMuteDistance = _fValue;
  }

  function loadActivityAuto() as Boolean {
    return LangUtils.asBoolean(App.Properties.getValue("userActivityAuto"), false);
  }
  function saveActivityAuto(_bValue as Boolean) as Void {
    App.Properties.setValue("userActivityAuto", _bValue as App.PropertyValueType);
  }
  function setActivityAuto(_bValue as Boolean) as Void {
    self.bActivityAuto = _bValue;
  }

  function loadActivityAutoSpeedStart() as Float {  // [m/s]
    return LangUtils.asFloat(App.Properties.getValue("userActivityAutoSpeedStart"), 9.0f);
  }
  function saveActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    App.Properties.setValue("userActivityAutoSpeedStart", _fValue as App.PropertyValueType);
  }
  function setActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    if(_fValue > 99.9f) {
      _fValue = 99.9f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fActivityAutoSpeedStart = _fValue;
    if(self.fActivityAutoSpeedStop > self.fActivityAutoSpeedStart) {
      self.fActivityAutoSpeedStop = self.fActivityAutoSpeedStart;
    }
  }

  function loadActivityAutoSpeedStop() as Float {  // [m/s]
    return LangUtils.asFloat(App.Properties.getValue("userActivityAutoSpeedStop"), 3.0f);
  }
  function saveActivityAutoSpeedStop(_fValue as Float) as Void {  // [m/s]
    App.Properties.setValue("userActivityAutoSpeedStop", _fValue as App.PropertyValueType);
  }
  function setActivityAutoSpeedStop(_fValue as Float) as Void {  // [m/s]
    if(_fValue > 99.9f) {
      _fValue = 99.9f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fActivityAutoSpeedStop = _fValue;
    if(self.fActivityAutoSpeedStart < self.fActivityAutoSpeedStop) {
      self.fActivityAutoSpeedStart = self.fActivityAutoSpeedStop;
    }
  }

  function loadGeneralTimeConstant() as Number {  // [s]
    return LangUtils.asNumber(App.Properties.getValue("userGeneralTimeConstant"), 5);
  }
  function saveGeneralTimeConstant(_iValue as Number) as Void {  // [s]
    App.Properties.setValue("userGeneralTimeConstant", _iValue as App.PropertyValueType);
  }
  function setGeneralTimeConstant(_iValue as Number) as Void {  // [s]
    if(_iValue > 60) {
      _iValue = 60;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iGeneralTimeConstant = _iValue;
  }

  function loadGeneralDisplayFilter() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userGeneralDisplayFilter"), 1);
  }
  function saveGeneralDisplayFilter(_iValue as Number) as Void {
    App.Properties.setValue("userGeneralDisplayFilter", _iValue as App.PropertyValueType);
  }
  function setGeneralDisplayFilter(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 2) {
      _iValue = 1;
    }
    self.iGeneralDisplayFilter = _iValue;
  }

  function loadGeneralBackgroundColor() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userGeneralBackgroundColor"), Gfx.COLOR_WHITE);
  }
  function saveGeneralBackgroundColor(_iValue as Number) as Void {
    App.Properties.setValue("userGeneralBackgroundColor", _iValue as App.PropertyValueType);
  }
  function setGeneralBackgroundColor(_iValue as Number) as Void {
    self.iGeneralBackgroundColor = _iValue;
  }

  function loadGeneralLapKey() as Boolean {
    return LangUtils.asBoolean(App.Properties.getValue("userGeneralLapKey"), true);
  }
  function saveGeneralLapKey(_bValue as Boolean) as Void {
    App.Properties.setValue("userGeneralLapKey", _bValue as App.PropertyValueType);
  }
  function setGeneralLapKey(_bValue as Boolean) as Void {
    self.bGeneralLapKey = _bValue;
  }

  function loadUnitDistance() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userUnitDistance"), -1);
  }
  function saveUnitDistance(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDistance", _iValue as App.PropertyValueType);
  }
  function setUnitDistance(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 2) {
      _iValue = -1;
    }
    self.iUnitDistance = _iValue;
    if(self.iUnitDistance < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        _iValue = oDeviceSettings.distanceUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == 2) {  // ... nautical
      // ... [nm]
      self.sUnitDistance = "nm";
      self.fUnitDistanceCoefficient = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = "kt";
      self.fUnitHorizontalSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
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

  function loadUnitElevation() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userUnitElevation"), -1);
  }
  function saveUnitElevation(_iValue as Number) as Void {
    App.Properties.setValue("userUnitElevation", _iValue as App.PropertyValueType);
  }
  function setUnitElevation(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitElevation = _iValue;
    if(self.iUnitElevation < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
        _iValue = oDeviceSettings.elevationUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
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

  function loadUnitPressure() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userUnitPressure"), -1);
  }
  function saveUnitPressure(_iValue as Number) as Void {
    App.Properties.setValue("userUnitPressure", _iValue as App.PropertyValueType);
  }
  function setUnitPressure(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitPressure = _iValue;
    if(self.iUnitPressure < 0) {  // ... auto
      // NOTE: assume weight units are a good indicator of preferred pressure units
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :weightUnits and oDeviceSettings.weightUnits != null) {
        _iValue = oDeviceSettings.weightUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
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

  function loadUnitRateOfTurn() as Number {
    return LangUtils.asNumber(App.Properties.getValue("userUnitRateOfTurn"), 0);
  }
  function saveUnitRateOfTurn(_iValue as Number) as Void {
    App.Properties.setValue("userUnitRateOfTurn", _iValue as App.PropertyValueType);
  }
  function setUnitRateOfTurn(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = 0;
    }
    self.iUnitRateOfTurn = _iValue;
    if(_iValue == 1) {  // ... revolution-per-minute
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

  function loadUnitTimeUTC() as Boolean {
    return LangUtils.asBoolean(App.Properties.getValue("userUnitTimeUTC"), false);
  }
  function saveUnitTimeUTC(_bValue as Boolean) as Void {
    App.Properties.setValue("userUnitTimeUTC", _bValue as App.PropertyValueType);
  }
  function setUnitTimeUTC(_bValue as Boolean) as Void {
    self.bUnitTimeUTC = _bValue;
    if(_bValue) {
      self.sUnitTime = "Z";
    }
    else {
      self.sUnitTime = "LT";
    }
  }

}
