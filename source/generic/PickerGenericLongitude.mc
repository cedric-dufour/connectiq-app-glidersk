// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class PickerGenericLongitude extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sTitle, _fValue) {
    // Split components
    var iValue_qua = _fValue < 0.0f ? -1 : 1;
    _fValue = _fValue.abs();
    var iValue_deg = _fValue.toNumber();
    _fValue = (_fValue - iValue_deg) * 60.0f;
    var iValue_min = _fValue.toNumber();
    _fValue = (_fValue - iValue_min) * 60.0f + 0.5f;
    var iValue_sec = _fValue.toNumber();
    if(iValue_sec >= 60) {
      iValue_sec = 59;
    }

    // Initialize picker
    var oFactory_qua = new PickerFactoryDictionary([1, -1], ["E", "W"], null);
    Picker.initialize({
      :title => new Ui.Text({ :text => _sTitle, :font => Gfx.FONT_TINY, :locX=>Ui.LAYOUT_HALIGN_CENTER, :locY=>Ui.LAYOUT_VALIGN_BOTTOM, :color => Gfx.COLOR_BLUE }),
      :pattern => [ oFactory_qua,
                    new PickerFactoryNumber(0, 179, { :langFormat => "$1$°" }),
                    new PickerFactoryNumber(0, 59, { :langFormat => "$1$'", :format => "%02d" }),
                    new PickerFactoryNumber(0, 59, { :langFormat => "$1$\"", :format => "%02d" }) ],
      :defaults => [ oFactory_qua.indexOfKey(iValue_qua), iValue_deg, iValue_min, iValue_sec ]
    });
  }


  //
  // FUNCTIONS: self
  //

  function getValue(_amValues) {
    // Assemble components
    var fValue = _amValues[0] * (_amValues[1] + _amValues[2]/60.0f + _amValues[3]/3600.0f);

    // Return value
    return fValue;
  }
}
