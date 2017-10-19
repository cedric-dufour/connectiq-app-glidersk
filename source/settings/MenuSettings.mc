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

// Menu: resources/menus/menuSettings.xml

class MenuDelegateSettings extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuSettingsGeneral) {
      //Sys.println("DEBUG: MenuDelegateSettings.onMenuItem(:menuSettingsGeneral)");
      Ui.pushView(new Rez.Menus.menuSettingsGeneral(), new MenuDelegateSettingsGeneral(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsSounds) {
      //Sys.println("DEBUG: MenuDelegateSettings.onMenuItem(:menuSettingsSounds)");
      Ui.pushView(new Rez.Menus.menuSettingsSounds(), new MenuDelegateSettingsSounds(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsVariometer) {
      //Sys.println("DEBUG: MenuDelegateSettings.onMenuItem(:menuSettingsVariometer)");
      Ui.pushView(new Rez.Menus.menuSettingsVariometer(), new MenuDelegateSettingsVariometer(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsUnits) {
      //Sys.println("DEBUG: MenuDelegateSettings.onMenuItem(:menuSettingsUnits)");
      Ui.pushView(new Rez.Menus.menuSettingsUnits(), new MenuDelegateSettingsUnits(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsSafety) {
      //Sys.println("DEBUG: MenuDelegateSettings.onMenuItem(:menuSettingsSafety)");
      Ui.pushView(new Rez.Menus.menuSettingsSafety(), new MenuDelegateSettingsSafety(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsAbout) {
      //Sys.println("DEBUG: MenuDelegateSettings.onMenuItem(:menuSettingsAbout)");
      Ui.pushView(new MenuSettingsAbout(), new MenuDelegateSettingsAbout(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
