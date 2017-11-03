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

class PickerGenericElevation extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sPropertyId, _sTitle) {
    // Get property
    var fElevation = App.getApp().getProperty(_sPropertyId);
    if(fElevation == null or fElevation < 0.0f ) { fElevation = 0.0f; }

    // Use user-specified elevation unit (NB: always use metric units in object store)
    fElevation = fElevation * $.GSK_Settings.fUnitElevationConstant;  // ... from meters

    // Split components
    fElevation += 0.05f;
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
      :title => new Ui.Text({ :text => _sTitle, :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryNumber(0, $.GSK_Settings.iUnitElevation == Sys.UNIT_STATUTE ? 29 : 9, null), oText_10e3,
                    new PickerFactoryNumber(0, 9, null), oText_10e2,
                    new PickerFactoryNumber(0, 9, null), oText_10e1,
                    new PickerFactoryNumber(0, 9, null), oText_10e0 ],
      :defaults => [ iElevation_10e3, 0, iElevation_10e2, 0, iElevation_10e1, 0, iElevation_10e0 ]
    });
  }

}

class PickerDelegateGenericElevation extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var sPropertyId;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_sPropertyId) {
    PickerDelegate.initialize();
    self.sPropertyId = _sPropertyId;
  }

  function onAccept(_amValues) {
    // Assemble components
    var fElevation = _amValues[0]*1000.0f + _amValues[2]*100.0f + _amValues[4]*10.0f + _amValues[6];

    // Use user-specified elevation unit (NB: always use metric units in object store)
    fElevation = fElevation / $.GSK_Settings.fUnitElevationConstant;  // ... to meters

    // Set property and exit
    App.getApp().setProperty(self.sPropertyId, fElevation);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
