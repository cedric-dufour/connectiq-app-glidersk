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

// Menu: resources/menus/menuSettingsGeneral.xml

class MenuDelegateSettingsGeneral extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuTimeConstant) {
      //Sys.println("DEBUG: MenuDelegateSettingsGeneral.onMenuItem(:menuTimeConstant)");
      Ui.pushView(new PickerTimeConstant(), new PickerDelegateTimeConstant(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuBackgroundColor) {
      //Sys.println("DEBUG: MenuDelegateSettingsGeneral.onMenuItem(:menuBackgroundColor)");
      Ui.pushView(new PickerBackgroundColor(), new PickerDelegateBackgroundColor(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuLapKey) {
      //Sys.println("DEBUG: MenuDelegateSettingsGeneral.onMenuItem(:menuLapKey)");
      Ui.pushView(new PickerGenericOnOff("userLapKey", Ui.loadResource(Rez.Strings.titleLapKey)), new PickerDelegateGenericOnOff("userLapKey"), Ui.SLIDE_IMMEDIATE);
    }
  }

}
