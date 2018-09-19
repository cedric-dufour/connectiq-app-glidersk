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

using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerAltimeterCalibrationElevation extends PickerGenericElevation {

  //
  // FUNCTIONS: PickerGenericElevation (override/implement)
  //

  function initialize() {
    PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleAltimeterCalibrationElevation), $.GSK_oAltimeter.fAltitudeActual, $.GSK_oSettings.iUnitElevation, false);
  }

}

class PickerAltimeterCalibrationElevationDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Calibrate altimeter, set property (QNH) and exit
    var fValue = PickerGenericElevation.getValue(_amValues, $.GSK_oSettings.iUnitElevation);
    $.GSK_oAltimeter.setAltitudeActual(fValue);
    App.Properties.setValue("userAltimeterCalibrationQNH", $.GSK_oAltimeter.fQNH);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
