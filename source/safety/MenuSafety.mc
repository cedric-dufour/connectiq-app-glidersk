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

// Menu: resources/menus/menuSafety.xml

class MenuDelegateSafety extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuDestinationLoad) {
      //Sys.println("DEBUG: MenuDelegateSafety.onMenuItem(:menuDestinationLoad)");
      $.GSK_Settings.load();  // ... (re)load settings
      Ui.pushView(new PickerDestinationLoad(), new PickerDelegateDestinationLoad(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationEdit) {
      //Sys.println("DEBUG: MenuDelegateSafety.onMenuItem(:menuDestinationEdit)");
      Ui.pushView(new MenuDestinationEdit(), new MenuDelegateDestinationEdit(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationSave) {
      //Sys.println("DEBUG: MenuDelegateSafety.onMenuItem(:menuDestinationSave)");
      Ui.pushView(new PickerDestinationSave(), new PickerDelegateDestinationSave(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationDelete) {
      //Sys.println("DEBUG: MenuDelegateSafety.onMenuItem(:menuDestinationDelete)");
      Ui.pushView(new PickerDestinationDelete(), new PickerDelegateDestinationDelete(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettings) {
      //Sys.println("DEBUG: MenuDelegateSafety.onMenuItem(:menuSettings)");
      Ui.pushView(new Rez.Menus.menuSettings(), new MenuDelegateSettings(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
