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
using Toybox.Math;
using Toybox.Position as Pos;
using Toybox.Sensor;
using Toybox.System as Sys;
using Toybox.Time;

//
// CLASS
//

class MyProcessing {

  //
  // CONSTANTS
  //

  // Plot buffer
  public const PLOTBUFFER_SIZE = 300;  // 5 minutes = 300 seconds


  //
  // VARIABLES
  //

  // Internal calculation objects
  private var fEnergyCineticLossFactor as Float = 0.25f;
  // ... we must calculate our own vertical speed
  private var iPreviousAltitudeEpoch as Number = -1;
  private var fPreviousAltitude as Float = 0.0f;
  // ... we must calculate our own potential energy "vertical speed"
  private var iPreviousEnergyGpoch as Number = -1;
  private var fPreviousEnergyTotal as Float = 0.0f;
  private var fPreviousEnergyCinetic as Float = 0.0f;
  // ... we must calculate our own rate of turn
  private var iPreviousHeadingGpoch as Number = -1;
  private var fPreviousHeading as Float = 0.0f;

  // Public objects
  // ... destination values
  public var sDestinationName as String = "";
  public var oDestinationLocation as Pos.Location?;
  public var fDestinationElevation as Float = NaN;
  // ... sensor values (fed by Toybox.Sensor)
  public var iSensorEpoch as Number = -1;
  public var fAcceleration as Float = NaN;
  public var fAcceleration_filtered as Float = NaN;
  // ... altimeter values (fed by Toybox.Activity, on Toybox.Sensor events)
  public var fAltitude as Float = NaN;
  public var fAltitude_filtered as Float = NaN;
  // ... altimeter calculated values
  public var fVariometer as Float = NaN;
  public var fVariometer_filtered as Float = NaN;
  // ... position values (fed by Toybox.Position)
  public var bPositionStateful as Boolean = false;
  public var iPositionEpoch as Number = -1;
  public var iPositionGpoch as Number = -1;
  public var iAccuracy as Number = Pos.QUALITY_NOT_AVAILABLE;
  public var oLocation as Pos.Location?;
  public var fGroundSpeed as Float = NaN;
  public var fGroundSpeed_filtered as Float = NaN;
  public var fHeading as Float = NaN;
  public var fHeading_filtered as Float = NaN;
  // ... position calculated values
  public var fEnergyTotal as Float = NaN;
  public var fEnergyCinetic as Float = NaN;
  public var fRateOfTurn as Float = NaN;
  public var fRateOfTurn_filtered as Float = NaN;
  // ... safety processing
  public var bSafetyStateful as Boolean = false;
  // ... safety calculated values
  public var fFinesse as Float = NaN;
  public var fSpeedToDestination as Float = NaN;
  public var fDistanceToDestination as Float = NaN;
  public var fBearingToDestination as Float = NaN;
  public var fAltitudeAtDestination as Float = NaN;
  public var fHeightAtDestination as Float = NaN;
  // ... safety status
  public var bGrace as Boolean = false;
  public var iGraceEpoch as Number = -1;
  public var bAscent as Boolean = true;
  public var bDecision as Boolean = false;
  public var bAltitudeCritical as Boolean = false;
  public var bAltitudeWarning as Boolean = false;
  // ... plot buffer (using integer-only operations!)
  public var iPlotIndex as Number = -1;
  public var aiPlotEpoch as Array<Number>;
  public var aiPlotLatitude as Array<Number>;
  public var aiPlotLongitude as Array<Number>;
  public var aiPlotVariometer as Array<Number>;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Public objects
    // ... plot buffer
    aiPlotEpoch = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotEpoch[i] = -1; }
    aiPlotLatitude = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotLatitude[i] = 0; }
    aiPlotLongitude = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotLongitude[i] = 0; }
    aiPlotVariometer = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotVariometer[i] = 0; }
  }

  function resetSensorData() as Void {
    //Sys.println("DEBUG: MyProcessing.resetSensorData()");

    // Reset
    // ... we must calculate our own vertical speed
    self.iPreviousAltitudeEpoch = -1;
    self.fPreviousAltitude = 0.0f;
    // ... sensor values
    self.iSensorEpoch = -1;
    self.fAcceleration = NaN;
    self.fAcceleration_filtered = NaN;
    // ... altimeter values
    self.fAltitude = NaN;
    self.fAltitude_filtered = NaN;
    // ... altimeter calculated values
    if($.oMySettings.iVariometerMode == 0) {
      self.fVariometer = NaN;
      self.fVariometer_filtered = NaN;
      $.oMyFilter.resetFilter(MyFilter.VARIOMETER);
    }
    // ... filters
    $.oMyFilter.resetFilter(MyFilter.ACCELERATION);
  }

  function resetPositionData() as Void {
    //Sys.println("DEBUG: MyProcessing.resetPositionData()");

    // Reset
    // ... we must calculate our own potential energy "vertical speed"
    self.iPreviousEnergyGpoch = -1;
    self.fPreviousEnergyTotal = 0.0f;
    self.fPreviousEnergyCinetic = 0.0f;
    // ... we must calculate our own rate of turn
    self.iPreviousHeadingGpoch = -1;
    self.fPreviousHeading = 0.0f;
    // ... position values
    self.bPositionStateful = false;
    self.iPositionEpoch = -1;
    self.iPositionGpoch = -1;
    self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
    self.oLocation = null;
    self.fGroundSpeed = NaN;
    self.fGroundSpeed_filtered = NaN;
    self.fHeading = NaN;
    self.fHeading_filtered = NaN;
    // ... position calculated values
    if($.oMySettings.iVariometerMode == 1) {
      self.fVariometer = NaN;
      self.fVariometer_filtered = NaN;
      $.oMyFilter.resetFilter(MyFilter.VARIOMETER);
    }
    self.fEnergyTotal = NaN;
    self.fEnergyCinetic = NaN;
    self.fRateOfTurn = NaN;
    self.fRateOfTurn_filtered = NaN;
    // ... safety processing
    self.bSafetyStateful = false;
    // ... safety calculated values
    self.fFinesse = NaN;
    self.fSpeedToDestination = NaN;
    self.fDistanceToDestination = NaN;
    self.fBearingToDestination = NaN;
    self.fAltitudeAtDestination = NaN;
    self.fHeightAtDestination = NaN;
    // ... safety status
    self.bGrace = false;
    self.iGraceEpoch = -1;
    self.bAscent = true;
    self.bDecision = false;
    self.bAltitudeCritical = false;
    self.bAltitudeWarning = false;
    // ... filters
    $.oMyFilter.resetFilter(MyFilter.GROUNDSPEED);
    $.oMyFilter.resetFilter(MyFilter.HEADING_X);
    $.oMyFilter.resetFilter(MyFilter.HEADING_Y);
    $.oMyFilter.resetFilter(MyFilter.RATEOFTURN);
  }

  function importSettings() as Void {
    // Energy compensation
    self.fEnergyCineticLossFactor = 1.0f - $.oMySettings.fVariometerEnergyEfficiency;
  }

  function setDestination(_sName as String, _oLocation as Pos.Location, _fElevation as Float) as Void {
    self.sDestinationName = _sName;
    self.oDestinationLocation = _oLocation;
    self.fDestinationElevation = _fElevation;
  }

  function processSensorInfo(_oInfo as Sensor.Info, _iEpoch as Number) as Void {
    //Sys.println("DEBUG: MyProcessing.processSensorInfo()");

    // Process sensor data

    // ... acceleration
    if(_oInfo has :accel and _oInfo.accel != null) {
      self.fAcceleration = Math.sqrt((_oInfo.accel as Array<Number>)[0]*(_oInfo.accel as Array<Number>)[0]
                                     + (_oInfo.accel as Array<Number>)[1]*(_oInfo.accel as Array<Number>)[1]
                                     + (_oInfo.accel as Array<Number>)[2]*(_oInfo.accel as Array<Number>)[2]).toFloat()/1000.0f;
      self.fAcceleration_filtered = $.oMyFilter.filterValue(MyFilter.ACCELERATION, self.fAcceleration);
      //Sys.println(format("DEBUG: (Sensor.Info) acceleration = $1$ ~ $2$", [self.fAcceleration, self.fAcceleration_filtered]));
    }
    //else {
    //  Sys.println("WARNING: Sensor data have no acceleration information (:accel)");
    //}

    // ... altitude
    if(LangUtils.notNaN($.oMyAltimeter.fAltitudeActual)) {  // ... the closest to the device's raw barometric sensor value
      self.fAltitude = $.oMyAltimeter.fAltitudeActual;
      self.fAltitude_filtered = $.oMyAltimeter.fAltitudeActual_filtered;
    }
    //else {
    //  Sys.println("WARNING: Internal altimeter has no altitude available");
    //}

    // ... variometer
    if($.oMySettings.iVariometerMode == 0 and LangUtils.notNaN(self.fAltitude)) {  // ... altimetric variometer
      if(self.iPreviousAltitudeEpoch >= 0 and _iEpoch-self.iPreviousAltitudeEpoch != 0) {
        self.fVariometer = (self.fAltitude-self.fPreviousAltitude) / (_iEpoch-self.iPreviousAltitudeEpoch);
        self.fVariometer_filtered = $.oMyFilter.filterValue(MyFilter.VARIOMETER, self.fVariometer);
        //Sys.println(format("DEBUG: (Calculated) altimetric variometer = $1$ ~ $2$", [self.fVariometer, self.fVariometer_filtered]));
      }
      self.iPreviousAltitudeEpoch = _iEpoch;
      self.fPreviousAltitude = self.fAltitude;
      self.iPreviousEnergyGpoch = -1;  // ... prevent artefact when switching variometer mode
    }

    // Done
    self.iSensorEpoch = _iEpoch;
  }

  function processPositionInfo(_oInfo as Pos.Info, _iEpoch as Number) as Void {
    //Sys.println("DEBUG: MyProcessing.processPositionInfo()");

    // Process position data
    var fValue;
    var bStateful = true;

    // ... accuracy
    if(_oInfo has :accuracy and _oInfo.accuracy != null) {
      self.iAccuracy = _oInfo.accuracy as Number;
      //Sys.println(format("DEBUG: (Position.Info) accuracy = $1$", [self.iAccuracy]));
    }
    else {
      //Sys.println("WARNING: Position data have no accuracy information (:accuracy)");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }
    if(self.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or (self.iAccuracy == Pos.QUALITY_LAST_KNOWN and self.iPositionEpoch < 0)) {
      //Sys.println("WARNING: Position accuracy is not good enough to continue or start processing");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }

    // ... timestamp
    // WARNING: the value of the position (GPS) timestamp is NOT the UTC epoch but the GPS timestamp (NOT translated to the proper year quadrant... BUG?)
    //          https://en.wikipedia.org/wiki/Global_Positioning_System#Timekeeping
    if(_oInfo has :when and _oInfo.when != null) {
      self.iPositionGpoch = (_oInfo.when as Time.Moment).value();
      //DEVEL:self.iPositionGpoch = _iEpoch;  // SDK 3.0.x BUG!!! (:when remains constant)
      //Sys.println(format("DEBUG: (Position.Info) when = $1$", [self.self.iPositionGpoch]));
    }
    else {
      //Sys.println("WARNING: Position data have no timestamp information (:when)");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }

    // ... position
    self.bPositionStateful = false;
    if(_oInfo has :position and _oInfo.position != null) {
      self.oLocation = _oInfo.position;
      //Sys.println(format("DEBUG: (Position.Info) position = $1$, $2$", [self.oLocation.toDegrees()[0], self.oLocation.toDegrees()[1]]));
      // ... distance/bearing to destination
      if(self.oDestinationLocation != null) {
        var adPositionRadians = (self.oLocation as Pos.Location).toRadians();
        var adDestinationRadians = (self.oDestinationLocation as Pos.Location).toRadians();
        self.fDistanceToDestination = LangUtils.distance(adPositionRadians, adDestinationRadians);
        self.fBearingToDestination = LangUtils.bearing(adPositionRadians, adDestinationRadians);
        //Sys.println(format("DEBUG: (Calculated) distance/bearing to destination = $1$ / $2$", [self.fDistanceToDestination, self.fBearingToDestination * 57.2957795131f]));
      }
      else {
        //Sys.println("ERROR: No destination data");
        self.fDistanceToDestination = NaN;
        self.fBearingToDestination = NaN;
      }
    }
    //else {
    //  Sys.println("WARNING: Position data have no position information (:position)");
    //}
    if(self.oLocation == null) {
      bStateful = false;
    }

    // ... altitude
    if(LangUtils.isNaN(self.fAltitude)) {  // ... derived by internal altimeter on sensor events
      bStateful = false;
    }

    // ... ground speed
    if(_oInfo has :speed and _oInfo.speed != null) {
      self.fGroundSpeed = _oInfo.speed as Float;
      self.fGroundSpeed_filtered = $.oMyFilter.filterValue(MyFilter.GROUNDSPEED, self.fGroundSpeed);
      //Sys.println(format("DEBUG: (Position.Info) ground speed = $1$ ~ $2$", [self.fGroundSpeed, self.fGroundSpeed_filtered]));
    }
    //else {
    //  Sys.println("WARNING: Position data have no speed information (:speed)");
    //}
    if(LangUtils.isNaN(self.fGroundSpeed)) {
      bStateful = false;
    }

    // ... variometer
    if($.oMySettings.iVariometerMode == 1 and LangUtils.notNaN(self.fAltitude) and LangUtils.notNaN(self.fGroundSpeed)) {  // ... energetic variometer
      self.fEnergyCinetic = 0.5f*self.fGroundSpeed*self.fGroundSpeed;
      self.fEnergyTotal = self.fEnergyCinetic + 9.80665f*self.fAltitude;
      //Sys.println(format("DEBUG: (Calculated) total energy = $1$", [self.fEnergyTotal]));
      if(self.iPreviousEnergyGpoch >= 0 and self.iPositionGpoch-self.iPreviousEnergyGpoch != 0) {
        self.fVariometer =
          (self.fEnergyTotal
           - self.fPreviousEnergyTotal
           - self.fEnergyCineticLossFactor*(self.fEnergyCinetic-self.fPreviousEnergyCinetic))
          / (self.iPositionGpoch-self.iPreviousEnergyGpoch) * 0.1019716213f;  // ... 1.0f / 9.80665f = 1.019716213f
        self.fVariometer_filtered = $.oMyFilter.filterValue(MyFilter.VARIOMETER, self.fVariometer);
        //Sys.println(format("DEBUG: (Calculated) energetic variometer = $1$ ~ $2$", [self.fVariometer, self.fVariometer_filtered]));
      }
      self.iPreviousEnergyGpoch = self.iPositionGpoch;
      self.fPreviousEnergyTotal = self.fEnergyTotal;
      self.fPreviousEnergyCinetic = self.fEnergyCinetic;
      self.iPreviousAltitudeEpoch = -1;  // ... prevent artefact when switching variometer mode
    }
    if(LangUtils.isNaN(self.fVariometer)) {
      bStateful = false;
    }

    // ... heading
    // NOTE: we consider heading meaningful only if ground speed is above 1.0 m/s
    if(self.fGroundSpeed >= 1.0f and _oInfo has :heading and _oInfo.heading != null) {
      fValue = _oInfo.heading as Float;
      if(fValue < 0.0f) {
        fValue += 6.28318530718f;
      }
      self.fHeading = fValue;
      fValue = $.oMyFilter.filterValue(MyFilter.HEADING_X, Math.cos(self.fHeading).toFloat());
      fValue = Math.atan2($.oMyFilter.filterValue(MyFilter.HEADING_Y, Math.sin(self.fHeading).toFloat()), fValue).toFloat();
      if(fValue < 0.0f) {
        fValue += 6.28318530718f;
      }
      self.fHeading_filtered = fValue;
    }
    else {
      //Sys.println("WARNING: Position data have no (meaningful) heading information (:heading)");
      self.fHeading = NaN;
      self.fHeading_filtered = NaN;
    }
    if(LangUtils.notNaN(self.fHeading)) {
      //Sys.println(format("DEBUG: (Position.Info) heading = $1$ ~ $2$", [self.fHeading, self.fHeading_filtered]));
      // ... rate of turn
      if(self.iPreviousHeadingGpoch >= 0 and self.iPositionGpoch-self.iPreviousHeadingGpoch != 0) {
        fValue = (self.fHeading-self.fPreviousHeading) / (self.iPositionGpoch-self.iPreviousHeadingGpoch);
        if(fValue < -3.14159265359f) {
          fValue += 6.28318530718f;
        }
        else if(fValue > 3.14159265359f) {
          fValue -= 6.28318530718f;
        }
        self.fRateOfTurn = fValue;
        self.fRateOfTurn_filtered = $.oMyFilter.filterValue(MyFilter.RATEOFTURN, self.fRateOfTurn);
        //Sys.println(format("DEBUG: (Calculated) rate of turn = $1$ ~ $2$", [self.fRateOfTurn, self.fRateOfTurn_filtered]));
      }
      self.iPreviousHeadingGpoch = self.iPositionGpoch;
      self.fPreviousHeading = self.fHeading;
    }
    else {
      //Sys.println("WARNING: No heading available");
      self.iPreviousHeadingGpoch = -1;
      self.fRateOfTurn = NaN;
      self.fRateOfTurn_filtered = NaN;
    }
    if(LangUtils.notNaN(self.fHeading_filtered) and LangUtils.notNaN(self.fBearingToDestination)) {
      // ... speed-to(wards)-destination
      self.fSpeedToDestination = self.fGroundSpeed_filtered * Math.cos(self.fHeading_filtered-self.fBearingToDestination).toFloat();
      //Sys.println(format("DEBUG: (Calculated) speed-to(wards)-destination = $1$", [self.fSpeedToDestination]));
    }
    else {
      //Sys.println("WARNING: No heading available");
      self.fSpeedToDestination = NaN;
    }
    // NOTE: heading and rate-of-turn data are not required for processing finalization

    // Finalize
    if(bStateful) {
      self.bPositionStateful = true;
      if(self.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
        self.iPositionEpoch = _iEpoch;

        // Plot buffer
        self.iPlotIndex = (self.iPlotIndex+1) % self.PLOTBUFFER_SIZE;
        self.aiPlotEpoch[self.iPlotIndex] = self.iPositionEpoch;
        // ... location as (integer) milliseconds of arc
        var adPositionDegrees = (self.oLocation as Pos.Location).toDegrees();
        self.aiPlotLatitude[self.iPlotIndex] = (adPositionDegrees[0]*3600000.0f).toNumber();
        self.aiPlotLongitude[self.iPlotIndex] = (adPositionDegrees[1]*3600000.0f).toNumber();
        // ... vertical speed as (integer) millimeter-per-second
        self.aiPlotVariometer[self.iPlotIndex] = (self.fVariometer*1000.0f).toNumber();
      }
    }

    // ... safety
    self.processSafety();
  }

  function processSafety() as Void {
    //Sys.println("DEBUG: MyProcessing.processSafety()");
    self.bSafetyStateful = false;
    if(!self.bPositionStateful or LangUtils.isNaN(self.fDestinationElevation) or LangUtils.isNaN(self.fDistanceToDestination)) {
      //Sys.println("ERROR: Incomplete data; cannot proceed");
      self.bAscent = false;
      self.fFinesse = NaN;
      self.bDecision = false;
      self.fAltitudeAtDestination = NaN;
      self.fHeightAtDestination = NaN;
      self.bAltitudeCritical = false;
      self.bAltitudeWarning = false;
      return;
    }

    // ALGO: We're not moving; use reference finesse along distance to destination (regardless of bearing)
    //       This allows to have a safety height reading at stop and verify the reference height setting
    if(LangUtils.isNaN(self.fSpeedToDestination)) {
      //Sys.println("WARNING: No speed/bearing data");
      self.bAscent = false;
      self.fFinesse = $.oMySettings.iSafetyFinesse.toFloat();
      self.bDecision = false;
      self.fAltitudeAtDestination = self.fAltitude - self.fDistanceToDestination / self.fFinesse;
      self.fHeightAtDestination = self.fAltitudeAtDestination - self.fDestinationElevation;
      self.bAltitudeCritical = false;
      self.bAltitudeWarning = false;
      if(self.fHeightAtDestination <= $.oMySettings.fSafetyHeightCritical) {
        self.bAltitudeCritical = true;
      }
      else if(self.fHeightAtDestination <= $.oMySettings.fSafetyHeightWarning) {
        self.bAltitudeWarning = true;
      }
      self.bSafetyStateful = true;
      return;
    }

    // ALGO: We always use filtered (averaged) time-derived data to compute safety values,
    //       to avoid readings jumping around

    // Grace period
    if(self.iGraceEpoch < 0) {
      if($.oMySettings.iSafetyGraceDuration > 0) {
        //Sys.println("DEBUG: Grace period automatically enabled");
        self.iGraceEpoch = Time.now().value() + $.oMySettings.iSafetyGraceDuration;
        self.bGrace = true;
      }
      else {
        self.iGraceEpoch = 0;
        self.bGrace = false;
      }
    }
    if(self.bGrace and self.iPositionEpoch >= 0 and self.iPositionEpoch > self.iGraceEpoch) {
      //Sys.println("DEBUG: Grace period automatically disabled");
      self.bGrace = false;
    }

    // Ascent/finesse

    // ... ascending ?
    if(self.fVariometer_filtered >= -0.005f * self.fGroundSpeed_filtered) {  // climbing (quite... finesse >= 200)
      self.bAscent = true;
    }
    else {  // descending (really!)
      self.bAscent = false;
    }
    //Sys.println(format("DEBUG: (Calculated) ascent = $1$", [self.bAscent]));

    // ... finesse
    if(self.bAscent) {
      // ALGO: Let's use the user-specified reference finesse to estimate where we'd stand if we were to descend and head straight back home
      self.fFinesse = $.oMySettings.iSafetyFinesse.toFloat();
    }
    else {
      // ALGO: The "descending (really!)" test above guarantees a negative, non-zero variometer
      self.fFinesse = - self.fGroundSpeed_filtered / self.fVariometer_filtered;
    }
    //Sys.println(format("DEBUG: (Calculated) average finesse ~ $1$", [self.fFinesse]));

    // Safety
    // ALGO: The trick here is to avoid alerts when our altitude is high enough, no matter what our descent rate (finesse) or heading are
    //       (we ARE enjoying ourself gliding in that blue-blue sky; that's what we want in the first place!).
    //       BUT, if the altitude becomes to low (height at destination below or equal to our decision height), then we must trigger
    //       meaningful alerts.
    if(self.fFinesse > 0.0f) {
      // ALGO: We always use the *worst* between the *actual* and the user-specified *reference* finesse
      var fFinesse_safety = (self.fFinesse < $.oMySettings.iSafetyFinesse) ? self.fFinesse : $.oMySettings.iSafetyFinesse;
      // ALGO: Let's start by estimating our altitude at destination assuming we're *heading straight to it*, i.e. speed-to(wards)-destination
      //       is equal to ground speed.
      //       This is the worst-case scenario as far as finesse is concerned BUT the best-case scenario as far as our heading
      //       (vs. bearing to destination) is concerned.
      self.fAltitudeAtDestination = self.fAltitude - self.fDistanceToDestination / fFinesse_safety;
      self.fHeightAtDestination = self.fAltitudeAtDestination-self.fDestinationElevation;
      // ALGO: Then, if the corresponding height at destination is below our decision height, let's re-calculate our altitude at
      //       destination by using our *actual* speed-to(wards)-destination (which accounts for our *heading vs bearing to destination*)
      //       UNLESS we are within the grace period.
      self.bDecision = (self.fHeightAtDestination <= $.oMySettings.fSafetyHeightDecision);
      if(self.bDecision and !self.bGrace) {
        if(self.fSpeedToDestination > 0.0f) {
          self.fAltitudeAtDestination = self.fAltitude - self.fDistanceToDestination / fFinesse_safety * self.fGroundSpeed_filtered / self.fSpeedToDestination;
          self.fHeightAtDestination = self.fAltitudeAtDestination - self.fDestinationElevation;
          // ALGO: Our finesse or speed-to(wards)-destination aren't good enough; we'll touch the ground before reaching our destination
          //if(self.fHeightAtDestination <= 0.0f) {
          //  self.fAltitudeAtDestination = self.fDestinationElevation;
          //  self.fHeightAtDestination = 0.0f;
          //}
        }
        else {  // NOT(self.fSpeedToDestination > 0.0f)
          // ALGO: We're moving away from our destination; we'll never reach it
          self.fAltitudeAtDestination = -999999.9f;
          self.fHeightAtDestination = -999999.9f;
        }
      }
    }
    else {  // NOT(self.fFinesse > 0.0f)
      // ALGO: We should never get here
      self.bDecision = true;
      self.fAltitudeAtDestination = -999999.9f;
      self.fHeightAtDestination = -999999.9f;
    }
    //Sys.println(format("DEBUG: (Calculated) altitude/height at destination ~ $1$ / $2$", [self.fAltitudeAtDestination, self.fHeightAtDestination]));

    // ... status
    self.bAltitudeCritical = false;
    self.bAltitudeWarning = false;
    if(self.fHeightAtDestination <= $.oMySettings.fSafetyHeightCritical) {
      self.bAltitudeCritical = true;
    }
    else if(self.fHeightAtDestination <= $.oMySettings.fSafetyHeightWarning) {
      self.bAltitudeWarning = true;
    }

    // Done
    self.bSafetyStateful = true;
  }

}
