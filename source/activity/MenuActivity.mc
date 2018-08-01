// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017 Cedric Dufour <http://cedric.dufour.name>
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

using Toybox.Attention as Attn;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Menu: resources/menus/menuActivity.xml

class MenuDelegateActivity extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :menuActivityResume) {
      //Sys.println("DEBUG: MenuDelegateActivity.onMenuItem(:menuActivityResume)");
      if(!$.GSK_ActivitySession.isRecording()) {
        $.GSK_ActivitySession.start();
        if(Attn has :playTone) {
          Attn.playTone(Attn.TONE_START);
        }
      }
    }
    else if (item == :menuActivityPause) {
      //Sys.println("DEBUG: MenuDelegateActivity.onMenuItem(:menuActivityPause)");
      if($.GSK_ActivitySession.isRecording()) {
        $.GSK_ActivitySession.stop();
        if(Attn has :playTone) {
          Attn.playTone(Attn.TONE_STOP);
        }
      }
    }
    else if (item == :menuActivitySave) {
      //Sys.println("DEBUG: MenuDelegateActivity.onMenuItem(:menuActivitySave)");
      Ui.pushView(new MenuActivitySave(), new MenuDelegateActivitySave(), Ui.SLIDE_IMMEDIATE);
    }
    else if (item == :menuActivityDiscard) {
      //Sys.println("DEBUG: MenuDelegateActivity.onMenuItem(:menuActivityDiscard)");
      Ui.pushView(new MenuActivityDiscard(), new MenuDelegateActivityDiscard(), Ui.SLIDE_IMMEDIATE);
    }
  }

}
