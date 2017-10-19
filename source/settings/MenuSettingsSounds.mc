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

// Menu: resources/menus/menuSettingsSounds.xml

class MenuDelegateSettingsSounds extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuVariometerTones) {
      //Sys.println("DEBUG: MenuDelegateVariometerTones.onMenuItem(:menuVariometerTones)");
      Ui.pushView(new PickerGenericOnOff("userVariometerTones", Ui.loadResource(Rez.Strings.titleVariometerTones)), new PickerDelegateGenericOnOff("userVariometerTones"), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSafetyTones) {
      //Sys.println("DEBUG: MenuDelegateSafetyTones.onMenuItem(:menuSafetyTones)");
      Ui.pushView(new PickerGenericOnOff("userSafetyTones", Ui.loadResource(Rez.Strings.titleSafetyTones)), new PickerDelegateGenericOnOff("userSafetyTones"), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuMuteDistance) {
      //Sys.println("DEBUG: MenuDelegateMuteDistance.onMenuItem(:menuMuteDistance)");
      $.GSK_Settings.load();  // ... reload potentially modified settings
      Ui.pushView(new PickerGenericDistance("userMuteDistance", Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.titleMuteDistance), $.GSK_Settings.sUnitDistance])), new PickerDelegateGenericDistance("userMuteDistance"), Ui.SLIDE_IMMEDIATE);
    }
  }

}
