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

using Toybox.Position as Pos;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class GSK_DrawableHeader extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezHeaderAccuracy1;
  private var oRezHeaderAccuracy2;
  private var oRezHeaderAccuracy3;
  private var oRezHeaderAccuracy4;

  // Background color
  private var iColorBackground;

  // Position accuracy
  private var iPositionAccuracy;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({ :identifier => "GSK_DrawableHeader" });

    // Resources
    self.oRezHeaderAccuracy1 = new Rez.Drawables.drawHeaderAccuracy1();
    self.oRezHeaderAccuracy2 = new Rez.Drawables.drawHeaderAccuracy2();
    self.oRezHeaderAccuracy3 = new Rez.Drawables.drawHeaderAccuracy3();
    self.oRezHeaderAccuracy4 = new Rez.Drawables.drawHeaderAccuracy4();

    // Background color
    self.iColorBackground = Gfx.COLOR_TRANSPARENT;

    // Position accuracy
    self.iPositionAccuracy = null;
  }

  function draw(_oDC) {
    // Draw
    // ... background
    _oDC.setColor(self.iColorBackground, self.iColorBackground);
    _oDC.clear();

    // ... positioning accuracy
    if(self.iPositionAccuracy != null) {
      switch(self.iPositionAccuracy) {

      case Pos.QUALITY_NOT_AVAILABLE:
        _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy1.draw(_oDC);
        self.oRezHeaderAccuracy2.draw(_oDC);
        self.oRezHeaderAccuracy3.draw(_oDC);
        self.oRezHeaderAccuracy4.draw(_oDC);
        break;

      case Pos.QUALITY_LAST_KNOWN:
        _oDC.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy1.draw(_oDC);
        _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy2.draw(_oDC);
        self.oRezHeaderAccuracy3.draw(_oDC);
        self.oRezHeaderAccuracy4.draw(_oDC);
        break;

      case Pos.QUALITY_POOR:
        _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy1.draw(_oDC);
        self.oRezHeaderAccuracy2.draw(_oDC);
        _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy3.draw(_oDC);
        self.oRezHeaderAccuracy4.draw(_oDC);
        break;

      case Pos.QUALITY_USABLE:
        _oDC.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy1.draw(_oDC);
        self.oRezHeaderAccuracy2.draw(_oDC);
        self.oRezHeaderAccuracy3.draw(_oDC);
        _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy4.draw(_oDC);
        break;

      case Pos.QUALITY_GOOD:
        _oDC.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
        self.oRezHeaderAccuracy1.draw(_oDC);
        self.oRezHeaderAccuracy2.draw(_oDC);
        self.oRezHeaderAccuracy3.draw(_oDC);
        self.oRezHeaderAccuracy4.draw(_oDC);
        break;
      }
    }
  }


  //
  // FUNCTIONS: self
  //

  function setColorBackground(_iColorBackground) {
    self.iColorBackground = _iColorBackground;
  }

  function setPositionAccuracy(_iPositionAccuracy) {
    self.iPositionAccuracy = _iPositionAccuracy;
  }

}
