// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2019 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.WatchUi as Ui;

// NOTE: Since Ui.Confirmation does not allow to pre-select "Yes" as an answer,
//       let's us our own "confirmation" menu and save one key press
class GSK_MenuGenericConfirm extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize(_context, _action) {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleConfirm));
    if(_context == :contextActivity) {
      if(_action == :actionStart) {
        Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityStart)]), 0);
      }
      else if(_action == :actionSave) {
        Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivitySave)]), 0);
      }
      else if(_action == :actionDiscard) {
        Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityDiscard)]), 0);
      }
    }
    else if(_context == :contextDestination) {
      if(_action == :actionFromCurrent) {
        Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.titleDestinationFromCurrent)]), 0);
      }
    }
    else if(_context == :contextStorage) {
      if(_action == :actionClear) {
        Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.titleStorageClear)]), 0);
      }
    }
  }

}

class GSK_MenuGenericConfirmDelegate extends Ui.MenuInputDelegate {

  //
  // VARIABLES
  //

  private var context;
  private var action;
  private var popout;


  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize(_context, _action, _popout) {
    MenuInputDelegate.initialize();
    self.context = _context;
    self.action = _action;
    self.popout = _popout;
  }

  function onMenuItem(item) {
    if(self.context == :contextActivity) {
      if(self.action == :actionStart) {
        if($.GSK_oActivity == null) {
          $.GSK_oActivity = new GSK_Activity();
          $.GSK_oActivity.start();
        }
      }
      else if(self.action == :actionSave) {
        if($.GSK_oActivity != null) {
          $.GSK_oActivity.stop(true);
          $.GSK_oActivity = null;
        }
      }
      else if(self.action == :actionDiscard) {
        if($.GSK_oActivity != null) {
          $.GSK_oActivity.stop(false);
          $.GSK_oActivity = null;
        }
      }
    }
    else if(self.context == :contextDestination) {
      if(self.action == :actionFromCurrent) {
        if ($.GSK_oPositionLocation != null and $.GSK_oPositionAltitude != null) {
          var d = {
            "name" => "????",
            "latitude" => $.GSK_oPositionLocation.toDegrees()[0],
            "longitude" => $.GSK_oPositionLocation.toDegrees()[1],
            "elevation" => $.GSK_oPositionAltitude
          };
          App.Storage.setValue("storDestInUse", d);
        }
      }
    }
    else if(self.context == :contextStorage) {
      if(self.action == :actionClear) {
        App.getApp().clearStorageData();
      }
    }
    if(self.popout) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
  }

}
