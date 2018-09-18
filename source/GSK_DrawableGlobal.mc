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

using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class GSK_DrawableGlobal extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezContentBackground;
  private var oRezAlertLeft;
  private var oRezAlertCenter;
  private var oRezAlertRight;

  // Colors
  private var iColorContentBackground;
  private var iColorAlertLeft;
  private var iColorAlertCenter;
  private var iColorAlertRight;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({ :identifier => "GSK_DrawableGlobal" });

    // Resources
    self.oRezContentBackground = new Rez.Drawables.drawContentBackground();
    self.oRezAlertLeft = new Rez.Drawables.drawGlobalAlertLeft();
    self.oRezAlertCenter = new Rez.Drawables.drawGlobalAlertCenter();
    self.oRezAlertRight = new Rez.Drawables.drawGlobalAlertRight();

    // Colors
    self.iColorContentBackground = Gfx.COLOR_TRANSPARENT;
    self.iColorAlertLeft = Gfx.COLOR_TRANSPARENT;
    self.iColorAlertCenter = Gfx.COLOR_TRANSPARENT;
    self.iColorAlertRight = Gfx.COLOR_TRANSPARENT;
  }

  function draw(_oDC) {
    // Draw

    // ... fields
    _oDC.setColor(self.iColorContentBackground, Gfx.COLOR_TRANSPARENT);
    self.oRezContentBackground.draw(_oDC);

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

  function setColorContentBackground(_iColor) {
    self.iColorContentBackground = _iColor;
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
