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

class MenuDestination extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleDestination));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationLoad), :menuDestinationLoad);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationEdit), :menuDestinationEdit);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationSave), :menuDestinationSave);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationDelete), :menuDestinationDelete);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsSafety), :menuSettingsSafety);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSettings), :menuSettings);
  }

}

class MenuDestinationDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuDestinationLoad) {
      //Sys.println("DEBUG: MenuDestinationDelegate.onMenuItem(:menuDestinationLoad)");
      $.GSK_oSettings.load();  // ... (re)load settings
      Ui.pushView(new PickerDestinationLoad(), new PickerDestinationLoadDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationEdit) {
      //Sys.println("DEBUG: MenuDestinationDelegate.onMenuItem(:menuDestinationEdit)");
      Ui.pushView(new MenuDestinationEdit(), new MenuDestinationEditDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationSave) {
      //Sys.println("DEBUG: MenuDestinationDelegate.onMenuItem(:menuDestinationSave)");
      Ui.pushView(new PickerDestinationSave(), new PickerDestinationSaveDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationDelete) {
      //Sys.println("DEBUG: MenuDestinationDelegate.onMenuItem(:menuDestinationDelete)");
      Ui.pushView(new PickerDestinationDelete(), new PickerDestinationDeleteDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettingsSafety) {
      //Sys.println("DEBUG: MenuSettingsDelegate.onMenuItem(:menuSettingsSafety)");
      Ui.pushView(new MenuSettingsSafety(), new MenuSettingsSafetyDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSettings) {
      //Sys.println("DEBUG: MenuDestinationDelegate.onMenuItem(:menuSettings)");
      Ui.pushView(new MenuSettings(), new MenuSettingsDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
