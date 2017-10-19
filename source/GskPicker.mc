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

using Toybox.WatchUi as Ui;

class GskPicker extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_dictSettings) {
    // Use our own icons by default
    if(!(_dictSettings has :previousArrow)) {
      _dictSettings[:previousArrow] = new Ui.Bitmap({ :rezId => Rez.Drawables.iconPickerDown, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER });
    }
    if(!(_dictSettings has :nextArrow)) {
      _dictSettings[:nextArrow] = new Ui.Bitmap({ :rezId => Rez.Drawables.iconPickerUp, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER });
    }
    if(!(_dictSettings has :confirm)) {
      _dictSettings[:confirm] = new Ui.Bitmap({ :rezId => Rez.Drawables.iconPickerOk, :locX => Ui.LAYOUT_HALIGN_CENTER, :locY => Ui.LAYOUT_VALIGN_CENTER });
    }

    // Initialize picker
    Picker.initialize(_dictSettings);
  }

}
