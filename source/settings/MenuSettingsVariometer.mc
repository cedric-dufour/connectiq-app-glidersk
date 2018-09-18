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

class MenuSettingsVariometer extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsVariometer));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerRange), :menuVariometerRange);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerMode), :menuVariometerMode);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerEnergyEfficiency), :menuVariometerEnergyEfficiency);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerPlotRange), :menuVariometerPlotRange);
  }

}

class MenuSettingsVariometerDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuVariometerRange) {
      //Sys.println("DEBUG: MenuSettingsVariometerDelegate.onMenuItem(:menuVariometerRange)");
      Ui.pushView(new PickerVariometerRange(), new PickerVariometerRangeDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuVariometerMode) {
      //Sys.println("DEBUG: MenuSettingsVariometerDelegate.onMenuItem(:menuVariometerMode)");
      Ui.pushView(new PickerVariometerMode(), new PickerVariometerModeDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuVariometerEnergyEfficiency) {
      //Sys.println("DEBUG: MenuSettingsVariometerDelegate.onMenuItem(:menuVariometerEnergyEfficiency)");
      Ui.pushView(new PickerVariometerEnergyEfficiency(), new PickerVariometerEnergyEfficiencyDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuVariometerPlotRange) {
      //Sys.println("DEBUG: MenuSettingsVariometerDelegate.onMenuItem(:menuVariometerPlotRange)");
      Ui.pushView(new PickerVariometerPlotRange(), new PickerVariometerPlotRangeDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
