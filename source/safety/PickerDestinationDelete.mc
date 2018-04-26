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

class PickerDestinationDelete extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Destination memory
    var aiMemoryKeys = new [$.GSK_STORAGE_SLOTS];
    var asMemoryValues = new [$.GSK_STORAGE_SLOTS];
    var iMemoryUsed = 0;
    for(var n=0; n<$.GSK_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      var dictDestination = App.Storage.getValue("storDest"+s);
      if(dictDestination != null) {
        aiMemoryKeys[iMemoryUsed] = n;
        asMemoryValues[iMemoryUsed] = Lang.format("[$1$]\n$2$", [s, dictDestination["name"]]);
        iMemoryUsed++;
      }
    }

    // Initialize picker
    var oPattern;
    if(iMemoryUsed > 0) {
      aiMemoryKeys = aiMemoryKeys.slice(0, iMemoryUsed);
      asMemoryValues = asMemoryValues.slice(0, iMemoryUsed);
      oPattern = new PickerFactoryDictionary(aiMemoryKeys, asMemoryValues, { :font => Gfx.FONT_TINY });
    }
    else {
      oPattern = new PickerFactoryDictionary([null], ["-"], { :color => Gfx.COLOR_DK_GRAY });
    }
    Picker.initialize({
      :title => new Ui.Text({ :text => Ui.loadResource(Rez.Strings.menuDestinationDelete), :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oPattern ]
    });
  }

}

class PickerDelegateDestinationDelete extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Delete property (destination memory)
    if(_amValues[0] != null) {
      var s = _amValues[0].format("%02d");
      App.Storage.deleteValue("storDest"+s);
    }

    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
