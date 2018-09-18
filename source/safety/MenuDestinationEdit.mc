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

using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MenuDestinationEdit extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleDestinationEdit));
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationName), :menuDestinationName);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationLatitude), :menuDestinationLatitude);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationLongitude), :menuDestinationLongitude);
    Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationElevation), :menuDestinationElevation);
    if($.GSK_oPositionLocation != null and $.GSK_oPositionAltitude != null) {
      Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationFromCurrent), :menuDestinationFromCurrent);
    }
  }

}

class MenuDestinationEditDelegate extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuDestinationName) {
      //Sys.println("DEBUG: MenuDestinationEditDelegate.onMenuItem(:menuDestinationName)");
      Ui.pushView(new PickerDestinationEditName(), new PickerDestinationEditNameDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationLatitude) {
      //Sys.println("DEBUG: MenuDestinationEditDelegate.onMenuItem(:menuDestinationLatitude)");
      Ui.pushView(new PickerDestinationEditLatitude(), new PickerDestinationEditLatitudeDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationLongitude) {
      //Sys.println("DEBUG: MenuDestinationEditDelegate.onMenuItem(:menuDestinationLongitude)");
      Ui.pushView(new PickerDestinationEditLongitude(), new PickerDestinationEditLongitudeDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationElevation) {
      //Sys.println("DEBUG: MenuDestinationEditDelegate.onMenuItem(:menuDestinationElevation)");
      Ui.pushView(new PickerDestinationEditElevation(), new PickerDestinationEditElevationDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuDestinationFromCurrent) {
      //Sys.println("DEBUG: MenuDestinationEditDelegate.onMenuItem(:menuDestinationFromCurrent)");
      Ui.pushView(new MenuDestinationEditFromCurrent(), new MenuDestinationEditFromCurrentDelegate(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
