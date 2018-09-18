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
using Toybox.WatchUi as Ui;

class PickerDestinationEditLatitude extends PickerGenericLatitude {

  //
  // FUNCTIONS: PickerGenericLatitude (override/implement)
  //

  function initialize() {
    // Get property
    var dictDestination = App.Storage.getValue("storDestInUse");
    var fLatitude = dictDestination != null ? dictDestination["latitude"] : 0.0f;
    PickerGenericLatitude.initialize(Ui.loadResource(Rez.Strings.titleDestinationLatitude), fLatitude);
  }

}

class PickerDestinationEditLatitudeDelegate extends Ui.PickerDelegate {

  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize() {
    PickerDelegate.initialize();
  }

  function onAccept(_amValues) {
    // Assemble components
    var fLatitude = PickerGenericLatitude.getValue(_amValues);

    // Update/create destination (dictionary)
    var dictDestination = App.Storage.getValue("storDestInUse");
    if(dictDestination != null) {
      dictDestination["latitude"] = fLatitude;
    }
    else {
      dictDestination = { "name" => "----", "latitude" => fLatitude, "longitude" => 0.0f, "elevation" => 0.0f };
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
