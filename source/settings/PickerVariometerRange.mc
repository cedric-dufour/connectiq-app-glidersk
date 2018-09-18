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

class PickerVariometerRange extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var iVariometerRange = App.Properties.getValue("userVariometerRange");

    // Initialize picker
    $.GSK_oSettings.load();  // ... reload potentially modified settings
    var sFormat = $.GSK_oSettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
    var asValues =
      [ Lang.format("$1$\n$2$", [(3.0f*$.GSK_oSettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.GSK_oSettings.sUnitVerticalSpeed]),
        Lang.format("$1$\n$2$", [(6.0f*$.GSK_oSettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.GSK_oSettings.sUnitVerticalSpeed]),
        Lang.format("$1$\n$2$", [(9.0f*$.GSK_oSettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.GSK_oSettings.sUnitVerticalSpeed]) ];
    var oFactory = new PickerFactoryDictionary([0, 1, 2], asValues, { :font => Gfx.FONT_TINY });
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.titleVariometerRange), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory ],
      :defaults => [ oFactory.indexOfKey(iVariometerRange) ]
    });
  }

}

class PickerVariometerRangeDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Set property and exit
    App.Properties.setValue("userVariometerRange", _amValues[0]);
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
