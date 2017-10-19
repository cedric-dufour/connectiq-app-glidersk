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

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerFactoryNumber extends Ui.PickerFactory {

  //
  // VARIABLES
  //

  private var iNumberMinimum;
  private var iNumberMaximum;
  private var sFormat;
  private var amSettingsKeys;
  private var amSettingsValues;

  //
  // FUNCTIONS: Ui.PickerFactory (override/implement)
  //

  function initialize(_iNumberMinimum, _iNumberMaximum, _dictSettings) {
    PickerFactory.initialize();
    self.iNumberMinimum = _iNumberMinimum;
    self.iNumberMaximum = _iNumberMaximum;
    if(_dictSettings != null) {
      self.sFormat = _dictSettings.get(:format);
      if(self.sFormat == null) {
        self.sFormat = "%d";
      }
      else {
        _dictSettings.remove(:format);
      }
      self.amSettingsKeys = _dictSettings.keys();
      self.amSettingsValues = _dictSettings.values();
    }
    else {
      self.sFormat = "%d";
      self.amSettingsKeys = null;
      self.amSettingsValues = null;
    }
  }

  function getDrawable(_iItem, _bSelected) {
    var dictSettings = {
      :text => self.getValue(_iItem).format(self.sFormat),
      :locX => Ui.LAYOUT_HALIGN_CENTER,
      :locY => Ui.LAYOUT_VALIGN_CENTER,
      :color => _bSelected ? Gfx.COLOR_WHITE : Gfx.COLOR_DK_GRAY
    };
    if(self.amSettingsKeys != null) {
      for(var i=0; i<self.amSettingsKeys.size(); i++) {
        dictSettings[self.amSettingsKeys[i]] = self.amSettingsValues[i];
      }
    }
    return new Ui.Text(dictSettings);
  }

  function getValue(_iItem) {
    return self.iNumberMinimum+_iItem;
  }

  function getSize() {
    return self.iNumberMaximum-self.iNumberMinimum+1;
  }


  //
  // FUNCTIONS: self
  //

  function indexOf(_iNumber) {
    return _iNumber-self.iNumberMinimum;
  }

}
