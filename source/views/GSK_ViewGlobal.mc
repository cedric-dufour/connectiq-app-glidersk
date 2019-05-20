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

using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class GSK_ViewGlobal extends GSK_ViewHeader {

  //
  // VARIABLES
  //

  // Resources
  // ... drawable
  protected var oRezDrawableGlobal;
  // ... fields
  protected var oRezValueTopLeft;
  protected var oRezValueTopRight;
  protected var oRezValueLeft;
  protected var oRezValueCenter;
  protected var oRezValueRight;
  protected var oRezValueBottomLeft;
  protected var oRezValueBottomRight;


  //
  // FUNCTIONS: GSK_ViewHeader (override/implement)
  //

  function initialize() {
    GSK_ViewHeader.initialize();

    // Display mode
    // ... internal
    self.bHeaderOnly = false;
  }

  function onLayout(_oDC) {
    if(!GSK_ViewHeader.onLayout(_oDC)) {
      return false;
    }

    // Load resources
    // ... drawable
    self.oRezDrawableGlobal = View.findDrawableById("GSK_DrawableGlobal");
    // ... fields
    self.oRezValueTopLeft = View.findDrawableById("valueTopLeft");
    self.oRezValueTopRight = View.findDrawableById("valueTopRight");
    self.oRezValueLeft = View.findDrawableById("valueLeft");
    self.oRezValueCenter = View.findDrawableById("valueCenter");
    self.oRezValueRight = View.findDrawableById("valueRight");
    self.oRezValueBottomLeft = View.findDrawableById("valueBottomLeft");
    self.oRezValueBottomRight = View.findDrawableById("valueBottomRight");

    // Done
    return true;
  }

}

class GSK_ViewGlobalDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: GSK_ViewHeaderDelegate.onMenu()");
    Ui.pushView(new GSK_MenuGeneric(:menuSettings), new GSK_MenuGenericDelegate(:menuSettings), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: GSK_ViewHeaderDelegate.onSelect()");
    if($.GSK_oActivity == null) {
      Ui.pushView(new GSK_MenuGenericConfirm(:contextActivity, :actionStart), new GSK_MenuGenericConfirmDelegate(:contextActivity, :actionStart, false), Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new GSK_MenuGeneric(:menuActivity), new GSK_MenuGenericDelegate(:menuActivity), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: GSK_ViewHeaderDelegate.onBack()");
    if($.GSK_oActivity != null) {
      if($.GSK_oSettings.bGeneralLapKey) {
        $.GSK_oActivity.addLap();
      }
      return true;
    }
    return false;
  }

}
