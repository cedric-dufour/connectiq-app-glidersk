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

class PickerGenericDistance extends GskPicker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sPropertyId, _sTitle) {
    // Get property
    var fDistance = App.getApp().getProperty(_sPropertyId);
    if(fDistance == null or fDistance < 0.0f ) { fDistance = 0.0f; }

    // Use user-specified distance unit (NB: always use metric units in object store)
    fDistance = fDistance * $.GSK_Settings.fUnitDistanceConstant;  // ... from meters

    // Split components
    fDistance += 0.05f;
    var iDistance_10e0 = fDistance.toNumber() % 10;
    fDistance = (fDistance - iDistance_10e0) * 10.0f;
    var iDistance_10e_1 = fDistance.toNumber() % 10;
    if(iDistance_10e0 > 9 ) { iDistance_10e0 = 9; }

    // Initialize picker
    var oText_10e0 = new Ui.Text({ :text => "x1", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    var oText_10e_1 = new Ui.Text({ :text => "x0.1", :font => Gfx.FONT_TINY, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER, :color => Gfx.COLOR_LT_GRAY });
    GskPicker.initialize({
      :title => new Ui.Text({ :text => _sTitle, :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryNumber(0, 9, null), oText_10e0,
                    new PickerFactoryNumber(0, 9, null), oText_10e_1 ],
      :defaults => [ iDistance_10e0, 0, iDistance_10e_1 ]
    });
  }

}

class PickerDelegateGenericDistance extends Ui.PickerDelegate {

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
    var fDistance = _amValues[0] + _amValues[2]*0.1f;

    // Use user-specified distance unit (NB: always use metric units in object store)
    fDistance = fDistance / $.GSK_Settings.fUnitDistanceConstant;  // ... to meters

    // Set property and exit
    App.getApp().setProperty(self.sPropertyId, fDistance);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
