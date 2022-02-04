// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class MyPickerGenericText extends Ui.TextPicker {

  //
  // FUNCTIONS: Ui.TextPicker (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextDestination) {

      var d = App.Storage.getValue("storDestInUse") as Dictionary?;
      if(_item == :itemName) {
        TextPicker.initialize(d != null ? d["name"] as String : "");
      }

    }
    else if(_context == :contextStorage) {

      if(_item == :itemImportData) {
        TextPicker.initialize("");
      }

    }
  }

}

class MyPickerGenericTextDelegate extends Ui.TextPickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;


  //
  // FUNCTIONS: Ui.TextPickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    TextPickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onTextEntered(_sText, _bChanged) {
    if(self.context == :contextDestination) {

      var d = App.Storage.getValue("storDestInUse") as Dictionary?;
      if(d == null) {
        d = {"name" => "----", "latitude" => 0.0f, "longitude" => 0.0f, "elevation" => 0.0f};
      }
      if(self.item == :itemName) {
        d["name"] = _sText;
      }
      App.Storage.setValue("storDestInUse", d as App.PropertyValueType);

    }
    else if(self.context == :contextStorage) {

      if(self.item == :itemImportData) {
        (App.getApp() as MyApp).importStorageData(_sText);
      }

    }
    return true;
  }

}
