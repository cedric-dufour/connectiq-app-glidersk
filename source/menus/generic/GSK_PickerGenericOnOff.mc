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

class GSK_PickerGenericOnOff extends PickerGenericOnOff {

  //
  // FUNCTIONS: PickerGenericOnOff (override/implement)
  //

  function initialize(_context, _item) {
    if(_context == :contextSettings) {
      if(_item == :itemSoundsVariometerTones) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleSoundsVariometerTones), App.Properties.getValue("userSoundsVariometerTones"));
      }
      else if(_item == :itemSoundsSafetyTones) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleSoundsSafetyTones), App.Properties.getValue("userSoundsSafetyTones"));
      }
      else if(_item == :itemGeneralLapKey) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleGeneralLapKey), App.Properties.getValue("userGeneralLapKey"));
      }
    }
  }

}

class GSK_PickerGenericOnOffDelegate extends Ui.PickerDelegate {

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
    var bValue = PickerGenericOnOff.getValue(_amValues);
    if(self.context == :contextSettings) {
      if(self.item == :itemSoundsVariometerTones) {
        App.Properties.setValue("userSoundsVariometerTones", bValue);
      }
      else if(self.item == :itemSoundsSafetyTones) {
        App.Properties.setValue("userSoundsSafetyTones", bValue);
      }
      else if(self.item == :itemGeneralLapKey) {
        App.Properties.setValue("userGeneralLapKey", bValue);
      }
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
