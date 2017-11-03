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
using Toybox.WatchUi as Ui;

class PickerDestinationSave extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Destination memory
    var iMemorySize = 50;
    var aiMemoryKeys = new [iMemorySize];
    var asMemoryValues = new [iMemorySize];
    for(var n=0; n<iMemorySize; n++) {
      aiMemoryKeys[n] = n;
      var s = n.format("%02d");
      var dictDestination = App.getApp().getProperty("storDest"+s);
      if(dictDestination != null) {
        asMemoryValues[n] = Lang.format("[$1$]\n$2$", [s, dictDestination["name"]]);
      }
      else {
        asMemoryValues[n] = Lang.format("[$1$]\n----", [s]);
      }
    }

    // Initialize picker
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.menuDestinationSave), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ new PickerFactoryDictionary(aiMemoryKeys, asMemoryValues, { :font => Gfx.FONT_TINY }) ]
    });
  }

}

class PickerDelegateDestinationSave extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Save destination
    var dictDestination = App.getApp().getProperty("storDestInUse");
    if(dictDestination != null) {
      // Set property (destination memory)
      // WARNING: We MUST store a new (different) dictionary instance (deep copy)!
      var s = _amValues[0].format("%02d");
      App.getApp().setProperty("storDest"+s, GskUtils.copy(dictDestination));
    }

    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
