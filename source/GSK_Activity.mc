// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.Attention as Attn;
using Toybox.FitContributor as FC;
using Toybox.Time;

//
// CLASS
//

class GSK_Activity {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  // ... record
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_RATEOFTURN = 1;
  public const FITFIELD_ACCELERATION = 2;
  public const FITFIELD_BAROMETRICALTITUDE = 3;


  //
  // VARIABLES
  //

  // Session (recording)
  private var oSession;

  // FIT fields
  // ... (unit conversion) coefficients
  private var fUnitCoefficient_Altitude = 1.0f;
  private var fUnitCoefficient_VerticalSpeed = 1.0f;
  private var fUnitCoefficient_RateOfTurn = 1.0f;
  // ... record
  private var oFitField_BarometricAltitude = null;
  private var oFitField_VerticalSpeed = null;
  private var oFitField_RateOfTurn = null;
  private var oFitField_Acceleration = null;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    //Sys.println("DEBUG: GSK_Activity.initialize()");

    // Session (recording)
    // NOTE: "Flying" activity number is 20 (cf. https://www.thisisant.com/resources/fit -> Profiles.xlsx)
    self.oSession = AR.createSession({ :name=>"GliderSK", :sport=>20, :subSport=>AR.SUB_SPORT_GENERIC });

    // FIT fields

    // ... (unit conversion) coefficients
    self.fUnitCoefficient_Altitude = $.GSK_oSettings.fUnitElevationCoefficient;
    self.fUnitCoefficient_VerticalSpeed = $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
    self.fUnitCoefficient_RateOfTurn = $.GSK_oSettings.fUnitRateOfTurnCoefficient;

    // ... record
    self.oFitField_BarometricAltitude = self.oSession.createField("BarometricAltitude", GSK_Activity.FITFIELD_BAROMETRICALTITUDE, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.GSK_oSettings.sUnitElevation });
    self.oFitField_VerticalSpeed = self.oSession.createField("VerticalSpeed", GSK_Activity.FITFIELD_VERTICALSPEED, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.GSK_oSettings.sUnitVerticalSpeed });
    self.oFitField_RateOfTurn = self.oSession.createField("RateOfTurn", GSK_App.FITFIELD_RATEOFTURN, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.GSK_oSettings.sUnitRateOfTurn });
    self.oFitField_Acceleration = self.oSession.createField("Acceleration", GSK_App.FITFIELD_ACCELERATION, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>"g" });
  }


  //
  // FUNCTIONS: self (session)
  //

  function start() {
    //Sys.println("DEBUG: GSK_Activity.start()");

    self.oSession.start();
    $.GSK_Activity_oTimeStart = Time.now();
    $.GSK_Activity_oTimeLap = Time.now();
    $.GSK_Activity_iCountLaps = 1;
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
  }

  function isRecording() {
    //Sys.println("DEBUG: GSK_Activity.isRecording()");

    return self.oSession.isRecording();
  }

  function addLap() {
    //Sys.println("DEBUG: GSK_Activity.lap()");

    self.oSession.addLap();
    $.GSK_Activity_oTimeLap = Time.now();
    $.GSK_Activity_iCountLaps += 1;
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_LAP);
    }
  }

  function pause() {
    //Sys.println("DEBUG: GSK_Activity.pause()");

    if(!self.oSession.isRecording()) {
      return;
    }
    self.oSession.stop();
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_STOP);
    }
  }

  function resume() {
    //Sys.println("DEBUG: GSK_Activity.resume()");

    if(self.oSession.isRecording()) {
      return;
    }
    self.oSession.start();
    if(Attn has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
  }

  function stop(_bSave) {
    //Sys.println(Lang.format("DEBUG: GSK_Activity.stop($1$)", [_bSave]));

    if(self.oSession.isRecording()) {
      self.oSession.stop();
    }
    if(_bSave) {
      self.oSession.save();
      $.GSK_Activity_oTimeStop = Time.now();
      if(Attn has :playTone) {
        Attn.playTone(Attn.TONE_STOP);
      }
    }
    else {
      self.oSession.discard();
      $.GSK_Activity_oTimeStart = null;
      $.GSK_Activity_oTimeLap = null;
      $.GSK_Activity_iCountLaps = null;
      $.GSK_Activity_oTimeStop = null;
      if(Attn has :playTone) {
        Attn.playTone(Attn.TONE_RESET);
      }
    }
  }


  //
  // FUNCTIONS: self (fields)
  //

  // Record

  function setBarometricAltitude(_fValue) {
    //Sys.println(Lang.format("DEBUG: GSK_Activity.setBarometricAltitude($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_BarometricAltitude.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setVerticalSpeed(_fValue) {
    //Sys.println(Lang.format("DEBUG: GSK_Activity.setVerticalSpeed($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_VerticalSpeed.setData(_fValue * self.fUnitCoefficient_VerticalSpeed);
    }
  }

  function setRateOfTurn(_fValue) {
    //Sys.println(Lang.format("DEBUG: GSK_Activity.setRateOfTurn($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_RateOfTurn.setData(_fValue * self.fUnitCoefficient_RateOfTurn);
    }
  }

  function setAcceleration(_fValue) {
    //Sys.println(Lang.format("DEBUG: GSK_Activity.setAcceleration($1$)", [_fValue]));
    if(_fValue != null) {
      self.oFitField_Acceleration.setData(_fValue);
    }
  }

}
