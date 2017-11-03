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

using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Menu: resources/menus/menuSettingsVariometer.xml

class MenuDelegateSettingsVariometer extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuVariometerRange) {
      //Sys.println("DEBUG: MenuDelegateSettingsVariometer.onMenuItem(:menuVariometerRange)");
      Ui.pushView(new PickerVariometerRange(), new PickerDelegateVariometerRange(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuVariometerMode) {
      //Sys.println("DEBUG: MenuDelegateSettingsVariometer.onMenuItem(:menuVariometerMode)");
      Ui.pushView(new PickerVariometerMode(), new PickerDelegateVariometerMode(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuEnergyEfficiency) {
      //Sys.println("DEBUG: MenuDelegateSettingsVariometer.onMenuItem(:menuEnergyEfficiency)");
      Ui.pushView(new PickerEnergyEfficiency(), new PickerDelegateEnergyEfficiency(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuPlotRange) {
      //Sys.println("DEBUG: MenuDelegateSettingsVariometer.onMenuItem(:menuPlotRange)");
      Ui.pushView(new PickerPlotRange(), new PickerDelegatePlotRange(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
