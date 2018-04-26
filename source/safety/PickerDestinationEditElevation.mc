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

class PickerDestinationEditElevation extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var dictDestination = App.Storage.getValue("storDestInUse");
    var fElevation = dictDestination != null ? dictDestination["elevation"] : 0.0f;
    if(fElevation < 0.0f) { fElevation = 0.0f; }

    // Use user-specified elevation unit (NB: always use metric units in object store)
    $.GSK_Settings.load();  // ... reload potentially modified settings
    fElevation = fElevation * $.GSK_Settings.fUnitElevationConstant;  // ... from meters

    // Split components
    fElevation += 0.5f;
    var iElevation_10e0 = fElevation.toNumber() % 10;
    fElevation = fElevation / 10.0f;
    var iElevation_10e1 = fElevation.toNumber() % 10;
    fElevation = fElevation / 10.0f;
    var iElevation_10e2 = fElevation.toNumber() % 10;
    fElevation = fElevation / 10.0f;
    var iElevation_10e3 = fElevation.toNumber();
    if($.GSK_Settings.iUnitElevation == Sys.UNIT_STATUTE) {
      if(iElevation_10e3 > 29 ) { iElevation_10e3 = 29; }
    }
    else {
      if(iElevation_10e3 > 9 ) { iElevation_10e3 = 9; }
    }

    // Initialize picker
    var oText_10e3 = new Ui.Text({ :text => "x1000", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e2 = new Ui.Text({ :text => "x100", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e1 = new Ui.Text({ :text => "x10", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e0 = new Ui.Text({ :text => "x1", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    Picker.initialize({
      :title => new Ui.Text({ :text => Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.menuDestinationElevation), $.GSK_Settings.sUnitElevation]), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryNumber(0, $.GSK_Settings.iUnitElevation == Sys.UNIT_STATUTE ? 29 : 9, null), oText_10e3,
                    new PickerFactoryNumber(0, 9, null), oText_10e2,
                    new PickerFactoryNumber(0, 9, null), oText_10e1,
                    new PickerFactoryNumber(0, 9, null), oText_10e0 ],
      :defaults => [ iElevation_10e3, 0, iElevation_10e2, 0, iElevation_10e1, 0, iElevation_10e0 ]
    });
  }

}

class PickerDelegateDestinationEditElevation extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var fElevation = _amValues[0]*1000.0f + _amValues[2]*100.0f + _amValues[4]*10.0f + _amValues[6];

    // Use user-specified elevation unit (NB: always use metric units in object store)
    fElevation = fElevation / $.GSK_Settings.fUnitElevationConstant;  // ... to meters

    // Update/create destination (dictionary)
    var dictDestination = App.Storage.getValue("storDestInUse");
    if(dictDestination != null) {
      dictDestination["elevation"] = fElevation;
    }
    else {
      dictDestination = { "name" => "----", "latitude" => 0.0f, "longitude" => 0.0f, "elevation" => fElevation };
    }

    // Set property and exit
    App.Storage.setValue("storDestInUse", dictDestination);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
