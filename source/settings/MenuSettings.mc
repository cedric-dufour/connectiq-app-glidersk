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

class MenuSettings extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettings));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsAltimeter), :menuSettingsAltimeter);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsVariometer), :menuSettingsVariometer);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsSafety), :menuSettingsSafety);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsSounds), :menuSettingsSounds);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsGeneral), :menuSettingsGeneral);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsUnits), :menuSettingsUnits);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsAbout), :menuSettingsAbout);
  }

}

class MenuSettingsDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuSettingsAltimeter) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsAltimeter)");
      Ui.pushView(new MenuSettingsAltimeter(), new MenuSettingsAltimeterDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsVariometer) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsVariometer)");
      Ui.pushView(new MenuSettingsVariometer(), new MenuSettingsVariometerDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsSafety) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsSafety)");
      Ui.pushView(new MenuSettingsSafety(), new MenuSettingsSafetyDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsSounds) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsSounds)");
      Ui.pushView(new MenuSettingsSounds(), new MenuSettingsSoundsDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsGeneral) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsGeneral)");
      Ui.pushView(new MenuSettingsGeneral(), new MenuSettingsGeneralDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsUnits) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsUnits)");
      Ui.pushView(new MenuSettingsUnits(), new MenuSettingsUnitsDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsAbout) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsAbout)");
      Ui.pushView(new MenuSettingsAbout(), new MenuSettingsAboutDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
