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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class MyPickerGenericElevation extends PickerGenericElevation {

  //
  // FUNCTIONS: PickerGenericElevation (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextSettings) {
      if(_item == :itemAltimeterCalibration) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleAltimeterCalibrationElevation) as String,
                                          $.oMyAltimeter.fAltitudeActual,
                                          $.oMySettings.iUnitElevation,
                                          false);
      }
      else if(_item == :itemSafetyHeightDecision) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleSafetyHeightDecision) as String,
                                          $.oMySettings.loadSafetyHeightDecision(),
                                          $.oMySettings.iUnitElevation,
                                          false);
      }
      else if(_item == :itemSafetyHeightWarning) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleSafetyHeightWarning) as String,
                                          $.oMySettings.loadSafetyHeightWarning(),
                                          $.oMySettings.iUnitElevation,
                                          false);
      }
      else if(_item == :itemSafetyHeightCritical) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleSafetyHeightCritical) as String,
                                          $.oMySettings.loadSafetyHeightCritical(),
                                          $.oMySettings.iUnitElevation,
                                          false);
      }
      else if(_item == :itemSafetyHeightReference) {
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleSafetyHeightReference) as String,
                                          $.oMySettings.loadSafetyHeightReference(),
                                          $.oMySettings.iUnitElevation,
                                          false);
      }
    }
    else if(_context == :contextDestination) {
      if(_item == :itemPosition) {
        var d = App.Storage.getValue("storDestInUse") as Dictionary?;
        PickerGenericElevation.initialize(Ui.loadResource(Rez.Strings.titleDestinationElevation) as String,
                                          d != null ? d["elevation"] as Float : 0.0f,
                                          $.oMySettings.iUnitElevation,
                                          false);
      }
    }
  }

}

class MyPickerGenericElevationDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    var fValue = PickerGenericElevation.getValue(_amValues, $.oMySettings.iUnitElevation);
    if(self.context == :contextSettings) {
      if(self.item == :itemAltimeterCalibration) {
        $.oMyAltimeter.setAltitudeActual(fValue);
        $.oMySettings.saveAltimeterCalibrationQNH($.oMyAltimeter.fQNH);
      }
      else if(self.item == :itemSafetyHeightDecision) {
        $.oMySettings.saveSafetyHeightDecision(fValue);
      }
      else if(self.item == :itemSafetyHeightWarning) {
        $.oMySettings.saveSafetyHeightWarning(fValue);
      }
      else if(self.item == :itemSafetyHeightCritical) {
        $.oMySettings.saveSafetyHeightCritical(fValue);
      }
      else if(self.item == :itemSafetyHeightReference) {
        $.oMySettings.saveSafetyHeightReference(fValue);
      }
    }
    else if(self.context == :contextDestination) {
      var d = App.Storage.getValue("storDestInUse") as Dictionary?;
      if(d == null) {
        d = {"name" => "----", "latitude" => 0.0f, "longitude" => 0.0f, "elevation" => 0.0f};
      }
      if(self.item == :itemPosition) {
        d["elevation"] = fValue;
      }
      App.Storage.setValue("storDestInUse", d as App.PropertyValueType);
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
