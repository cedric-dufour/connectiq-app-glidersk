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

class MenuSettingsAltimeter extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsAltimeter));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCalibration), :menuAltimeterCalibration);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCorrection), :menuAltimeterCorrection);
  }

}

class MenuSettingsAltimeterDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuAltimeterCalibration) {
      //Sys.println("DEBUG: MenuSettingsAltimeterDelegate.onMenuItem(:menuAltimeterCalibration)");
      Ui.pushView(new MenuAltimeterCalibration(), new MenuAltimeterCalibrationDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuAltimeterCorrection) {
      //Sys.println("DEBUG: MenuSettingsAltimeterDelegate.onMenuItem(:menuAltimeterCorrection)");
      Ui.pushView(new MenuAltimeterCorrection(), new MenuAltimeterCorrectionDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
