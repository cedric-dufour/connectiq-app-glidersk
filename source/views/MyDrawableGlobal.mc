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

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyDrawableGlobal extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezFieldsBackground;
  private var oRezAlertLeft;
  private var oRezAlertCenter;
  private var oRezAlertRight;

  // Colors
  private var iColorFieldsBackground;
  private var iColorAlertLeft;
  private var iColorAlertCenter;
  private var iColorAlertRight;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({ :identifier => "MyDrawableGlobal" });

    // Resources
    self.oRezFieldsBackground = new Rez.Drawables.drawFieldsBackground();
    self.oRezAlertLeft = new Rez.Drawables.drawGlobalAlertLeft();
    self.oRezAlertCenter = new Rez.Drawables.drawGlobalAlertCenter();
    self.oRezAlertRight = new Rez.Drawables.drawGlobalAlertRight();

    // Colors
    self.iColorFieldsBackground = Gfx.COLOR_TRANSPARENT;
    self.iColorAlertLeft = Gfx.COLOR_TRANSPARENT;
    self.iColorAlertCenter = Gfx.COLOR_TRANSPARENT;
    self.iColorAlertRight = Gfx.COLOR_TRANSPARENT;
  }

  function draw(_oDC) {
    // Draw

    // ... fields
    _oDC.setColor(self.iColorFieldsBackground, Gfx.COLOR_TRANSPARENT);
    self.oRezFieldsBackground.draw(_oDC);

    // ... alerts
    if(self.iColorAlertLeft != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertLeft, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertLeft.draw(_oDC);
    }
    if(self.iColorAlertCenter != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertCenter, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertCenter.draw(_oDC);
    }
    if(self.iColorAlertRight != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertRight, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertRight.draw(_oDC);
    }

  }


  //
  // FUNCTIONS: self
  //

  function setColorFieldsBackground(_iColor) {
    self.iColorFieldsBackground = _iColor;
  }

  function setColorAlertLeft(_iColor) {
    self.iColorAlertLeft = _iColor;
  }

  function setColorAlertCenter(_iColor) {
    self.iColorAlertCenter = _iColor;
  }

  function setColorAlertRight(_iColor) {
    self.iColorAlertRight = _iColor;
  }

}
