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

class MyPickerGenericOnOff extends PickerGenericOnOff {

  //
  // FUNCTIONS: PickerGenericOnOff (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextSettings) {
      if(_item == :itemSoundsVariometerTones) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleSoundsVariometerTones) as String,
                                      $.oMySettings.loadSoundsVariometerTones());
      }
      else if(_item == :itemSoundsSafetyTones) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleSoundsSafetyTones) as String,
                                      $.oMySettings.loadSoundsSafetyTones());
      }
      else if(_item == :itemActivityAuto) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleActivityAuto) as String,
                                      $.oMySettings.loadActivityAuto());
      }
      else if(_item == :itemGeneralLapKey) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleGeneralLapKey) as String,
                                      $.oMySettings.loadGeneralLapKey());
      }
    }
  }

}

class MyPickerGenericOnOffDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    var bValue = PickerGenericOnOff.getValue(_amValues);
    if(self.context == :contextSettings) {
      if(self.item == :itemSoundsVariometerTones) {
        $.oMySettings.saveSoundsVariometerTones(bValue);
      }
      else if(self.item == :itemSoundsSafetyTones) {
        $.oMySettings.saveSoundsSafetyTones(bValue);
      }
      else if(self.item == :itemActivityAuto) {
        $.oMySettings.saveActivityAuto(bValue);
      }
      else if(self.item == :itemGeneralLapKey) {
        $.oMySettings.saveGeneralLapKey(bValue);
      }
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
