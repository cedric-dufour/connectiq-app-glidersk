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

// Menu: resources/menus/menuSettingsSafety.xml

class MenuDelegateSettingsSafety extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuFinesseReference) {
      //Sys.println("DEBUG: MenuDelegateSettingsSafety.onMenuItem(:menuFinesseReference)");
      Ui.pushView(new PickerFinesse(), new PickerDelegateFinesse(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuHeightDecision) {
      //Sys.println("DEBUG: MenuDelegateSettingsSafety.onMenuItem(:menuHeightDecision)");
      $.GSK_Settings.load();  // ... reload potentially modified settings
      Ui.pushView(new PickerGenericElevation("userHeightDecision", Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.titleHeightDecision), $.GSK_Settings.sUnitElevation])), new PickerDelegateGenericElevation("userHeightDecision"), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuHeightWarning) {
      //Sys.println("DEBUG: MenuDelegateSettingsSafety.onMenuItem(:menuHeightWarning)");
      $.GSK_Settings.load();  // ... reload potentially modified settings
      Ui.pushView(new PickerGenericElevation("userHeightWarning", Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.titleHeightWarning), $.GSK_Settings.sUnitElevation])), new PickerDelegateGenericElevation("userHeightWarning"), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuHeightCritical) {
      //Sys.println("DEBUG: MenuDelegateSettingsSafety.onMenuItem(:menuHeightCritical)");
      $.GSK_Settings.load();  // ... reload potentially modified settings
      Ui.pushView(new PickerGenericElevation("userHeightCritical", Lang.format("$1$ [$2$]", [Ui.loadResource(Rez.Strings.titleHeightCritical), $.GSK_Settings.sUnitElevation])), new PickerDelegateGenericElevation("userHeightCritical"), Ui.SLIDE_IMMEDIATE);
    }
  }

}
