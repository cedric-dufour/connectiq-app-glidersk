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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.Position as Pos;
using Toybox.WatchUi as Ui;

// NOTE: Since Ui.Confirmation does not allow to pre-select "Yes" as an answer,
//       let's us our own "confirmation" menu and save one key press
class MyMenuGenericConfirm extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize(_context as Symbol, _action as Symbol) {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleConfirm) as String);
    if(_context == :contextActivity) {
      if(_action == :actionStart) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityStart)]), :menuNone);
      }
      else if(_action == :actionSave) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivitySave)]), :menuNone);
      }
      else if(_action == :actionDiscard) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityDiscard)]), :menuNone);
      }
      else if(_action == :actionLap) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityLap)]), :menuNone);
      }
    }
    else if(_context == :contextDestination) {
      if(_action == :actionFromCurrent) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleDestinationFromCurrent)]), :menuNone);
      }
    }
    else if(_context == :contextStorage) {
      if(_action == :actionClear) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleStorageClear)]), :menuNone);
      }
    }
  }

}

class MyMenuGenericConfirmDelegate extends Ui.MenuInputDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var action as Symbol = :actionNone;
  private var popout as Boolean = false;


  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize(_context as Symbol, _action as Symbol, _popout as Boolean) {
    MenuInputDelegate.initialize();
    self.context = _context;
    self.action = _action;
    self.popout = _popout;
  }

  function onMenuItem(_item as Symbol) {
    if(self.context == :contextActivity) {
      if(self.action == :actionStart) {
        if($.oMyActivity == null) {
          $.oMyActivity = new MyActivity();
          ($.oMyActivity as MyActivity).start();
        }
      }
      else if(self.action == :actionSave) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).stop(true);
          $.oMyActivity = null;
        }
      }
      else if(self.action == :actionDiscard) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).stop(false);
          $.oMyActivity = null;
        }
      }
      else if(self.action == :actionLap) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).addLap();
        }
      }
    }
    else if(self.context == :contextDestination) {
      if(self.action == :actionFromCurrent) {
        if ($.oMyPositionLocation != null and LangUtils.notNaN($.fMyPositionAltitude)) {
          var d = {
            "name" => "????",
            "latitude" => ($.oMyPositionLocation as Pos.Location).toDegrees()[0],
            "longitude" => ($.oMyPositionLocation as Pos.Location).toDegrees()[1],
            "elevation" => $.fMyPositionAltitude
          };
          App.Storage.setValue("storDestInUse", d as App.PropertyValueType);
        }
      }
    }
    else if(self.context == :contextStorage) {
      if(self.action == :actionClear) {
        (App.getApp() as MyApp).clearStorageData();
      }
    }
    if(self.popout) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
  }

}
