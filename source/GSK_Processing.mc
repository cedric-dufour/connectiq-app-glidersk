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

using Toybox.Lang;
using Toybox.Math;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.Time;

//
// CLASS
//

class GSK_Processing {

  //
  // CONSTANTS
  //

  // Plot buffer
  public const PLOTBUFFER_SIZE = 300;  // 5 minutes = 300 seconds


  //
  // VARIABLES
  //

  // Internal calculation objects
  private var fEnergyCineticLossFactor;
  // ... we must calculate our own vertical speed
  private var iPreviousAltitudeEpoch;
  private var fPreviousAltitude;
  // ... we must calculate our own potential energy "vertical speed"
  private var iPreviousEnergyGpoch;
  private var fPreviousEnergyTotal;
  private var fPreviousEnergyCinetic;
  // ... we must calculate our own rate of turn
  private var iPreviousHeadingGpoch;
  private var fPreviousHeading;

  // Public objects
  // ... destination values
  public var sDestinationName;
  public var oDestinationLocation;
  public var fDestinationElevation;
  // ... sensor values (fed by Toybox.Sensor)
  public var iSensorEpoch;
  public var fAcceleration;
  public var fAcceleration_filtered;
  // ... altimeter values (fed by Toybox.Activity, on Toybox.Sensor events)
  public var fAltitude;
  public var fAltitude_filtered;
  // ... altimeter calculated values
  public var fVariometer;
  public var fVariometer_filtered;
  // ... position values (fed by Toybox.Position)
  public var bPositionStateful;
  public var iPositionEpoch;
  public var iPositionGpoch;
  public var iAccuracy;
  public var oLocation;
  public var fGroundSpeed;
  public var fGroundSpeed_filtered;
  public var fHeading;
  public var fHeading_filtered;
  // ... position calculated values
  public var fEnergyTotal;
  public var fEnergyCinetic;
  public var fRateOfTurn;
  public var fRateOfTurn_filtered;
  // ... safety processing
  public var bSafetyStateful;
  // ... safety calculated values
  public var fFinesse;
  public var fSpeedToDestination;
  public var fDistanceToDestination;
  public var fBearingToDestination;
  public var fAltitudeAtDestination;
  public var fHeightAtDestination;
  // ... safety status
  public var bGrace;
  public var iGraceEpoch;
  public var bAscent;
  public var bEstimation;
  public var bAltitudeCritical;
  public var bAltitudeWarning;
  // ... plot buffer (using integer-only operations!)
  public var iPlotIndex;
  public var aiPlotEpoch;
  public var aiPlotLatitude;
  public var aiPlotLongitude;
  public var aiPlotVariometer;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Internal calculation objects
    self.fEnergyCineticLossFactor = 0.25f;

    // Public objects
    // ... destination values (depending on user choice)
    self.sDestinationName = null;
    self.oDestinationLocation = null;
    self.fDestinationElevation = null;
    // ... processing values and status
    self.resetSensorData();
    self.resetPositionData();
    // ... plot buffer
    self.iPlotIndex = -1;
    self.aiPlotEpoch = new [self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotEpoch[i] = null; }
    self.aiPlotLatitude = new [self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotLatitude[i] = null; }
    self.aiPlotLongitude = new [self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotLongitude[i] = null; }
    self.aiPlotVariometer = new [self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotVariometer[i] = null; }
  }

  function resetSensorData() {
    //Sys.println("DEBUG: GSK_Processing.resetSensorData()");

    // Reset
    // ... we must calculate our own vertical speed
    self.iPreviousAltitudeEpoch = null;
    self.fPreviousAltitude = 0.0f;
    // ... sensor values
    self.iSensorEpoch = null;
    self.fAcceleration = null;
    self.fAcceleration_filtered = null;
    // ... altimeter values
    self.fAltitude = null;
    self.fAltitude_filtered = null;
    // ... altimeter calculated values
    if($.GSK_oSettings.iVariometerMode == 0) {
      self.fVariometer = null;
      self.fVariometer_filtered = null;
      $.GSK_oFilter.resetFilter(GSK_Filter.VARIOMETER);
    }
    // ... filters
    $.GSK_oFilter.resetFilter(GSK_Filter.ACCELERATION);
  }

  function resetPositionData() {
    //Sys.println("DEBUG: GSK_Processing.resetPositionData()");

    // Reset
    // ... we must calculate our own potential energy "vertical speed"
    self.iPreviousEnergyGpoch = null;
    self.fPreviousEnergyTotal = 0.0f;
    self.fPreviousEnergyCinetic = 0.0f;
    // ... we must calculate our own rate of turn
    self.iPreviousHeadingGpoch = null;
    self.fPreviousHeading = 0.0f;
    // ... position values
    self.bPositionStateful = false;
    self.iPositionEpoch = null;
    self.iPositionGpoch = null;
    self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
    self.oLocation = null;
    self.fGroundSpeed = null;
    self.fGroundSpeed_filtered = null;
    self.fHeading = null;
    self.fHeading_filtered = null;
    // ... position calculated values
    if($.GSK_oSettings.iVariometerMode == 1) {
      self.fVariometer = null;
      self.fVariometer_filtered = null;
      $.GSK_oFilter.resetFilter(GSK_Filter.VARIOMETER);
    }
    self.fEnergyTotal = null;
    self.fEnergyCinetic = null;
    self.fRateOfTurn = null;
    self.fRateOfTurn_filtered = null;
    // ... safety processing
    self.bSafetyStateful = false;
    // ... safety calculated values
    self.fFinesse = null;
    self.fSpeedToDestination = null;
    self.fDistanceToDestination = null;
    self.fBearingToDestination = null;
    self.fAltitudeAtDestination = null;
    self.fHeightAtDestination = null;
    // ... safety status
    self.bGrace = false;
    self.iGraceEpoch = null;
    self.bAscent = true;
    self.bEstimation = true;
    self.bAltitudeCritical = false;
    self.bAltitudeWarning = false;
    // ... filters
    $.GSK_oFilter.resetFilter(GSK_Filter.GROUNDSPEED);
    $.GSK_oFilter.resetFilter(GSK_Filter.HEADING_X);
    $.GSK_oFilter.resetFilter(GSK_Filter.HEADING_Y);
    $.GSK_oFilter.resetFilter(GSK_Filter.RATEOFTURN);
  }

  function importSettings() {
    // Energy compensation
    self.fEnergyCineticLossFactor = 1.0f - $.GSK_oSettings.fVariometerEnergyEfficiency;
  }

  function setDestination(_sName, _oLocation, _fElevation) {
    self.sDestinationName = _sName;
    self.oDestinationLocation = _oLocation;
    self.fDestinationElevation = _fElevation;
  }

  function processSensorInfo(_oInfo, _iEpoch) {
    //Sys.println("DEBUG: GSK_Processing.processSensorInfo()");

    // Process sensor data

    // ... acceleration
    if(_oInfo has :accel and _oInfo.accel != null) {
      self.fAcceleration = Math.sqrt(_oInfo.accel[0]*_oInfo.accel[0]+_oInfo.accel[1]*_oInfo.accel[1]+_oInfo.accel[2]*_oInfo.accel[2])/1000.0f;
      self.fAcceleration_filtered = $.GSK_oFilter.filterValue(GSK_Filter.ACCELERATION, self.fAcceleration);
      //Sys.println(Lang.format("DEBUG: (Sensor.Info) acceleration = $1$ ~ $2$", [self.fAcceleration, self.fAcceleration_filtered]));
    }
    //else {
    //  Sys.println("WARNING: Sensor data have no acceleration information (:accel)");
    //}

    // ... altitude
    if($.GSK_oAltimeter.fAltitudeActual != null) {  // ... the closest to the device's raw barometric sensor value
      self.fAltitude = $.GSK_oAltimeter.fAltitudeActual;
      self.fAltitude_filtered = $.GSK_oAltimeter.fAltitudeActual_filtered;
    }
    //else {
    //  Sys.println("WARNING: Internal altimeter has no altitude available");
    //}

    // ... variometer
    if($.GSK_oSettings.iVariometerMode == 0 and self.fAltitude != null) {  // ... altimetric variometer
      if(self.iPreviousAltitudeEpoch != null and self.iSensorEpoch-self.iPreviousAltitudeEpoch != 0) {
        self.fVariometer = (self.fAltitude-self.fPreviousAltitude) / (self.iSensorEpoch-self.iPreviousAltitudeEpoch);
        self.fVariometer_filtered = $.GSK_oFilter.filterValue(GSK_Filter.VARIOMETER, self.fVariometer);
        //Sys.println(Lang.format("DEBUG: (Calculated) altimetric variometer = $1$ ~ $2$", [self.fVariometer, self.fVariometer_filtered]));
      }
      self.iPreviousAltitudeEpoch = self.iSensorEpoch;
      self.fPreviousAltitude = self.fAltitude;
      self.iPreviousEnergyGpoch = null;  // ... prevent artefact when switching variometer mode
    }

    // Done
    self.iSensorEpoch = _iEpoch;
  }

  function processPositionInfo(_oInfo, _iEpoch) {
    //Sys.println("DEBUG: GSK_Processing.processPositionInfo()");

    // Process position data
    var fValue;
    var bStateful = true;

    // ... accuracy
    if(_oInfo has :accuracy and _oInfo.accuracy != null) {
      self.iAccuracy = _oInfo.accuracy;
      //Sys.println(Lang.format("DEBUG: (Position.Info) accuracy = $1$", [self.iAccuracy]));
    }
    else {
      //Sys.println("WARNING: Position data have no accuracy information (:accuracy)");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }
    if(self.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or (self.iAccuracy == Pos.QUALITY_LAST_KNOWN and self.iPositionEpoch == null)) {
      //Sys.println("WARNING: Position accuracy is not good enough to continue or start processing");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }

    // ... timestamp
    // WARNING: the value of the position (GPS) timestamp is NOT the UTC epoch but the GPS timestamp (NOT translated to the proper year quadrant... BUG?)
    //          https://en.wikipedia.org/wiki/Global_Positioning_System#Timekeeping
    if(_oInfo has :when and _oInfo.when != null) {
      self.iPositionGpoch = _oInfo.when.value();
      //DEVEL:self.iPositionGpoch = _iEpoch;  // SDK 3.0.x BUG!!! (:when remains constant)
      //Sys.println(Lang.format("DEBUG: (Position.Info) when = $1$", [self.self.iPositionGpoch]));
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
      //Sys.println(Lang.format("DEBUG: (Position.Info) position = $1$, $2$", [self.oLocation.toDegrees()[0], self.oLocation.toDegrees()[1]]));
      // ... distance/bearing to destination
      if(self.oDestinationLocation != null) {
        var adPositionRadians = self.oLocation.toRadians();
        var adDestinationRadians = self.oDestinationLocation.toRadians();
        self.fDistanceToDestination = LangUtils.distance(adPositionRadians, adDestinationRadians);
        self.fBearingToDestination = LangUtils.bearing(adPositionRadians, adDestinationRadians);
        //Sys.println(Lang.format("DEBUG: (Calculated) distance/bearing to destination = $1$ / $2$", [self.fDistanceToDestination, self.fBearingToDestination * 57.2957795131f]));
      }
      else {
        //Sys.println("ERROR: No destination data");
        self.fDistanceToDestination = null;
        self.fBearingToDestination = null;
      }
    }
    //else {
    //  Sys.println("WARNING: Position data have no position information (:position)");
    //}
    if(self.oLocation == null) {
      bStateful = false;
    }

    // ... altitude
    if(self.fAltitude == null) {  // ... derived by internal altimeter on sensor events
      bStateful = false;
    }

    // ... ground speed
    if(_oInfo has :speed and _oInfo.speed != null) {
      self.fGroundSpeed = _oInfo.speed;
      self.fGroundSpeed_filtered = $.GSK_oFilter.filterValue(GSK_Filter.GROUNDSPEED, self.fGroundSpeed);
      //Sys.println(Lang.format("DEBUG: (Position.Info) ground speed = $1$ ~ $2$", [self.fGroundSpeed, self.fGroundSpeed_filtered]));
    }
    //else {
    //  Sys.println("WARNING: Position data have no speed information (:speed)");
    //}
    if(self.fGroundSpeed == null) {
      bStateful = false;
    }

    // ... variometer
    if($.GSK_oSettings.iVariometerMode == 1 and self.fAltitude != null and self.fGroundSpeed != null) {  // ... energetic variometer
      self.fEnergyCinetic = 0.5f*self.fGroundSpeed*self.fGroundSpeed;
      self.fEnergyTotal = self.fEnergyCinetic + 9.80665f*self.fAltitude;
      //Sys.println(Lang.format("DEBUG: (Calculated) total energy = $1$", [self.fEnergyTotal]));
      if(self.iPreviousEnergyGpoch != null and self.iPositionGpoch-self.iPreviousEnergyGpoch != 0) {
        self.fVariometer = (self.fEnergyTotal-self.fPreviousEnergyTotal-self.fEnergyCineticLossFactor*(self.fEnergyCinetic-self.fPreviousEnergyCinetic)) / (self.iPositionGpoch-self.iPreviousEnergyGpoch) * 0.1019716213f;  // ... 1.0f / 9.80665f = 1.019716213f
        self.fVariometer_filtered = $.GSK_oFilter.filterValue(GSK_Filter.VARIOMETER, self.fVariometer);
        //Sys.println(Lang.format("DEBUG: (Calculated) energetic variometer = $1$ ~ $2$", [self.fVariometer, self.fVariometer_filtered]));
      }
      self.iPreviousEnergyGpoch = self.iPositionGpoch;
      self.fPreviousEnergyTotal = self.fEnergyTotal;
      self.fPreviousEnergyCinetic = self.fEnergyCinetic;
      self.iPreviousAltitudeEpoch = null;  // ... prevent artefact when switching variometer mode
    }
    if(self.fVariometer == null) {
      bStateful = false;
    }

    // ... heading
    // NOTE: we consider heading meaningful only if ground speed is above 1.0 m/s
    if(self.fGroundSpeed != null and self.fGroundSpeed >= 1.0f and _oInfo has :heading and _oInfo.heading != null) {
      fValue = _oInfo.heading;
      if(fValue < 0.0f) {
        fValue += 6.28318530718f;
      }
      self.fHeading = fValue;
      fValue = $.GSK_oFilter.filterValue(GSK_Filter.HEADING_X, Math.cos(self.fHeading));
      fValue = Math.atan2($.GSK_oFilter.filterValue(GSK_Filter.HEADING_Y, Math.sin(self.fHeading)), fValue);
      if(fValue == NaN) {
        fValue = null;  // WARNING! The one case where the filtered value may be null while the instantaneous value is not!
      }
      else if(fValue < 0.0f) {
        fValue += 6.28318530718f;
      }
      self.fHeading_filtered = fValue;
    }
    else {
      //Sys.println("WARNING: Position data have no (meaningful) heading information (:heading)");
      self.fHeading = null;
      self.fHeading_filtered = null;
    }
    if(self.fHeading != null) {
      //Sys.println(Lang.format("DEBUG: (Position.Info) heading = $1$ ~ $2$", [self.fHeading, self.fHeading_filtered]));
      // ... rate of turn
      if(self.iPreviousHeadingGpoch != null and self.iPositionGpoch-self.iPreviousHeadingGpoch != 0) {
        fValue = (self.fHeading-self.fPreviousHeading) / (self.iPositionGpoch-self.iPreviousHeadingGpoch);
        if(fValue < -3.14159265359f) {
          fValue += 6.28318530718f;
        }
        else if(fValue > 3.14159265359f) {
          fValue -= 6.28318530718f;
        }
        self.fRateOfTurn = fValue;
        self.fRateOfTurn_filtered = $.GSK_oFilter.filterValue(GSK_Filter.RATEOFTURN, self.fRateOfTurn);
        //Sys.println(Lang.format("DEBUG: (Calculated) rate of turn = $1$ ~ $2$", [self.fRateOfTurn, self.fRateOfTurn_filtered]));
      }
      self.iPreviousHeadingGpoch = self.iPositionGpoch;
      self.fPreviousHeading = self.fHeading;
    }
    else {
      //Sys.println("WARNING: No heading available");
      self.iPreviousHeadingGpoch = null;
      self.fRateOfTurn = null;
      self.fRateOfTurn_filtered = null;
    }
    if(self.fHeading_filtered != null and self.fBearingToDestination != null) {
      // ... speed-to(wards)-destination
      self.fSpeedToDestination = self.fGroundSpeed_filtered * Math.cos(self.fHeading_filtered-self.fBearingToDestination);
      //Sys.println(Lang.format("DEBUG: (Calculated) speed-to(wards)-destination = $1$", [self.fSpeedToDestination]));
    }
    else {
      //Sys.println("WARNING: No heading available");
      self.fSpeedToDestination = null;
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
        var adPositionDegrees = self.oLocation.toDegrees();
        self.aiPlotLatitude[self.iPlotIndex] = (adPositionDegrees[0]*3600000.0f).toNumber();
        self.aiPlotLongitude[self.iPlotIndex] = (adPositionDegrees[1]*3600000.0f).toNumber();
        // ... vertical speed as (integer) millimeter-per-second
        self.aiPlotVariometer[self.iPlotIndex] = (self.fVariometer*1000.0f).toNumber();
      }
    }

    // ... safety
    self.processSafety();
  }

  function processSafety() {
    //Sys.println("DEBUG: GSK_Processing.processSafety()");
    self.bSafetyStateful = false;
    if(!self.bPositionStateful or self.fDestinationElevation == null or self.fDistanceToDestination == null) {
      //Sys.println("ERROR: Incomplete data; cannot proceed");
      self.bAscent = false;
      self.fFinesse = null;
      self.bEstimation = true;
      self.fAltitudeAtDestination = null;
      self.fHeightAtDestination = null;
      self.bAltitudeCritical = false;
      self.bAltitudeWarning = false;
      return;
    }

    // ALGO: We're not moving; use reference finesse along distance to destination (regardless of bearing)
    //       This allows to have a safety height reading at stop and verify the reference height setting
    if(self.fSpeedToDestination == null) {
      //Sys.println("WARNING: No speed/bearing data");
      self.bAscent = false;
      self.fFinesse = $.GSK_oSettings.iSafetyFinesse.toFloat();
      self.bEstimation = true;
      self.fAltitudeAtDestination = self.fAltitude - self.fDistanceToDestination / self.fFinesse;
      self.fHeightAtDestination = self.fAltitudeAtDestination - self.fDestinationElevation;
      self.bAltitudeCritical = false;
      self.bAltitudeWarning = false;
      if(self.fHeightAtDestination <= $.GSK_oSettings.fSafetyHeightCritical) {
        self.bAltitudeCritical = true;
      }
      else if(self.fHeightAtDestination <= $.GSK_oSettings.fSafetyHeightWarning) {
        self.bAltitudeWarning = true;
      }
      self.bSafetyStateful = true;
      return;
    }

    // ALGO: We always use filtered (averaged) time-derived data to compute safety values,
    //       to avoid readings jumping around

    // Grace period
    if(self.iGraceEpoch == null) {
      if($.GSK_oSettings.iSafetyGraceDuration > 0) {
        //Sys.println("DEBUG: Grace period automatically enabled");
        self.iGraceEpoch = Time.now().value() + $.GSK_oSettings.iSafetyGraceDuration;
        self.bGrace = true;
      }
      else {
        self.iGraceEpoch = 0;
        self.bGrace = false;
      }
    }
    if(self.bGrace and self.iPositionEpoch != null and self.iPositionEpoch > self.iGraceEpoch) {
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
    //Sys.println(Lang.format("DEBUG: (Calculated) ascent = $1$", [self.bAscent]));

    // ... finesse
    if(self.bAscent) {
      // ALGO: Let's use the user-specified reference finesse to estimate where we'd stand if we were to descend and head straight back home
      self.fFinesse = $.GSK_oSettings.iSafetyFinesse.toFloat();
    }
    else {
      // ALGO: The "descending (really!)" test above guarantees a negative, non-zero variometer
      self.fFinesse = - self.fGroundSpeed_filtered / self.fVariometer_filtered;
    }
    //Sys.println(Lang.format("DEBUG: (Calculated) average finesse ~ $1$", [self.fFinesse]));

    // Safety
    // ALGO: The trick here is to avoid alerts when our altitude is high enough, no matter what our descent rate (finesse) or heading are
    //       (we ARE enjoying ourself gliding in that blue-blue sky; that's what we want in the first place!).
    //       BUT, if the altitude becomes to low (height at destination below or equal to our decision height), then we must trigger
    //       meaningful alerts.
    if(self.fFinesse > 0.0f) {
      // ALGO: We always use the *worst* between the *actual* and the user-specified *reference* finesse
      var fFinesse_safety = (self.fFinesse < $.GSK_oSettings.iSafetyFinesse) ? self.fFinesse : $.GSK_oSettings.iSafetyFinesse;
      // ALGO: Let's start by estimating our altitude at destination assuming we're *heading straight to it*, i.e. speed-to(wards)-destination
      //       is equal to ground speed.
      //       This is the worst-case scenario as far as finesse is concerned BUT the best-case scenario as far as our heading
      //       (vs. bearing to destination) is concerned.
      self.fAltitudeAtDestination = self.fAltitude - self.fDistanceToDestination / fFinesse_safety;
      self.fHeightAtDestination = self.fAltitudeAtDestination-self.fDestinationElevation;
      // ALGO: Then, if the corresponding height at destination is below our decision height, let's re-calculate our altitude at
      //       destination by using our *actual* speed-to(wards)-destination (which accounts for our *heading vs bearing to destination*)
      //       UNLESS we are within the grace period.
      if(self.fHeightAtDestination <= $.GSK_oSettings.fSafetyHeightDecision and !self.bGrace) {
        self.bEstimation = false;
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
      else {  // NOT(self.fHeightAtDestination <= $.GSK_oSettings.fSafetyHeightDecision)
        self.bEstimation = true;
      }
    }
    else {  // NOT(self.fFinesse > 0.0f)
      // ALGO: We should never get here
      self.bEstimation = false;
      self.fAltitudeAtDestination = -999999.9f;
      self.fHeightAtDestination = -999999.9f;
    }
    //Sys.println(Lang.format("DEBUG: (Calculated) altitude/height at destination ~ $1$ / $2$", [self.fAltitudeAtDestination, self.fHeightAtDestination]));

    // ... status
    self.bAltitudeCritical = false;
    self.bAltitudeWarning = false;
    if(self.fHeightAtDestination <= $.GSK_oSettings.fSafetyHeightCritical) {
      self.bAltitudeCritical = true;
    }
    else if(self.fHeightAtDestination <= $.GSK_oSettings.fSafetyHeightWarning) {
      self.bAltitudeWarning = true;
    }

    // Done
    self.bSafetyStateful = true;
  }

}
