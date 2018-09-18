// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
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

class MenuSettingsSafety extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsSafety));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyFinesse), :menuSafetyFinesse);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightDecision), :menuSafetyHeightDecision);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightWarning), :menuSafetyHeightWarning);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightCritical), :menuSafetyHeightCritical);
  }

}

class MenuSettingsSafetyDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuSafetyFinesse) {
      //Sys.println("DEBUG: MenuSettingsSafetyDelegate.onMenuItem(:menuSafetyFinesse)");
      Ui.pushView(new PickerSafetyFinesse(), new PickerSafetyFinesseDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSafetyHeightDecision) {
      //Sys.println("DEBUG: MenuSettingsSafetyDelegate.onMenuItem(:menuSafetyHeightDecision)");
      Ui.pushView(new PickerSafetyHeightDecision(), new PickerSafetyHeightDecisionDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSafetyHeightWarning) {
      //Sys.println("DEBUG: MenuSettingsSafetyDelegate.onMenuItem(:menuSafetyHeightWarning)");
      Ui.pushView(new PickerSafetyHeightWarning(), new PickerSafetyHeightWarningDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSafetyHeightCritical) {
      //Sys.println("DEBUG: MenuSettingsSafetyDelegate.onMenuItem(:menuSafetyHeightCritical)");
      Ui.pushView(new PickerSafetyHeightCritical(), new PickerSafetyHeightCriticalDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
