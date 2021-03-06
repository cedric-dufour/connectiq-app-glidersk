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

using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class GSK_PickerGenericLongitude extends PickerGenericLongitude {

  //
  // FUNCTIONS: PickerGenericLongitude (override/implement)
  //

  function initialize(_context, _item) {
    if(_context == :contextDestination) {
      if(_item == :itemPosition) {
        var d = App.Storage.getValue("storDestInUse");
        PickerGenericLongitude.initialize(Ui.loadResource(Rez.Strings.titleDestinationLongitude), d != null ? d["longitude"] : 0.0f);
      }
    }
  }

}

class GSK_PickerGenericLongitudeDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context;
  private var item;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context, _item) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    var fValue = PickerGenericLongitude.getValue(_amValues);
    if(self.context == :contextDestination) {
      var d = App.Storage.getValue("storDestInUse");
      if(d == null) {
        d = { "name" => "----", "latitude" => 0.0f, "longitude" => 0.0f, "elevation" => 0.0f };
      }
      if(self.item == :itemPosition) {
        d["longitude"] = fValue;
      }
      App.Storage.setValue("storDestInUse", d);
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
