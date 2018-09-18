// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2018 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuActivity extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleActivity));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityResume), :menuActivityResume);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityPause), :menuActivityPause);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleActivitySave), :menuActivitySave);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityDiscard), :menuActivityDiscard);
  }

}

class MenuActivityDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuActivityResume) {
      //Sys.println("DEBUG: MenuActivityDelegate.onMenuItem(:menuActivityResume)");
      App.getApp().resumeActivity();
    }
    else if (item == :menuActivityPause) {
      //Sys.println("DEBUG: MenuActivityDelegate.onMenuItem(:menuActivityPause)");
      App.getApp().pauseActivity();
    }
    else if (item == :menuActivitySave) {
      //Sys.println("DEBUG: MenuActivityDelegate.onMenuItem(:menuActivitySave)");
      Ui.pushView(new MenuActivitySave(), new MenuActivitySaveDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuActivityDiscard) {
      //Sys.println("DEBUG: MenuActivityDelegate.onMenuItem(:menuActivityDiscard)");
      Ui.pushView(new MenuActivityDiscard(), new MenuActivityDiscardDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
