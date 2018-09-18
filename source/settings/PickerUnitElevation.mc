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

class PickerUnitElevation extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var iUnitElevation = App.Properties.getValue("userUnitElevation");

    // Initialize picker
    var oFactory = new PickerFactoryDictionary([-1, 0, 1], [Ui.loadResource(Rez.Strings.valueUnitElevationAuto), Ui.loadResource(Rez.Strings.valueUnitElevationMetric), Ui.loadResource(Rez.Strings.valueUnitElevationStatute)], null);
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleUnitElevation), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory ],
      :defaults => [ oFactory.indexOfKey(iUnitElevation) ]
    });
  }

}

class PickerUnitElevationDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Set property and exit
    App.Properties.setValue("userUnitElevation", _amValues[0]);
    $.GSK_oSettings.load();  // ... use proper units in settings
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
