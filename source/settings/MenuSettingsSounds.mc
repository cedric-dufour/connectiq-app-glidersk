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

class MenuSettingsSounds extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsSounds));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSoundsVariometerTones), :menuSoundsVariometerTones);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSoundsSafetyTones), :menuSoundsSafetyTones);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleSoundsMuteDistance), :menuSoundsMuteDistance);
  }

}

class MenuSettingsSoundsDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuSoundsVariometerTones) {
      //Sys.println("DEBUG: MenuSettingsSoundsDelegate.onMenuItem(:menuSoundsVariometerTones)");
      Ui.pushView(new PickerSoundsVariometerTones(), new PickerSoundsVariometerTonesDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSoundsSafetyTones) {
      //Sys.println("DEBUG: MenuSettingsSoundsDelegate.onMenuItem(:menuSoundsSafetyTones)");
      Ui.pushView(new PickerSoundsSafetyTones(), new PickerSoundsSafetyTonesDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuSoundsMuteDistance) {
      //Sys.println("DEBUG: MenuSettingsSoundsDelegate.onMenuItem(:menuSoundsMuteDistance)");
      Ui.pushView(new PickerSoundsMuteDistance(), new PickerSoundsMuteDistanceDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
