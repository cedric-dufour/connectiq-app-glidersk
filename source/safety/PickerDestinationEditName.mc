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

class PickerDestinationEditName extends Ui.TextPicker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize() {
    // Get property
    var dictDestination = App.Storage.getValue("storDestInUse");

    // Initialize picker
    TextPicker.initialize(dictDestination != null ? dictDestination["name"] : "");
  }

}

class PickerDelegateDestinationEditName extends Ui.TextPickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    TextPickerDelegate.initialize();
  }

  function onTextEntered(_sText, _bChanged) {
    // Update/create destination (dictionary)
    var dictDestination = App.Storage.getValue("storDestInUse");
    if(dictDestination != null) {
      dictDestination["name"] = _sText;
    }
    else {
      dictDestination = { "name" => _sText, "latitude" => 0.0f, "longitude" => 0.0f, "elevation" => 0.0f };
    }

    // Set property and exit
    App.Storage.setValue("storDestInUse", dictDestination);
  }

  function onCancel() {
    // Exit
  }

}
