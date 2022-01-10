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
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewGeneral extends MyViewGlobal {

  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGeneral.prepare()");
    MyViewGlobal.prepare();

    // Set colors (value-independent), labels and units
    // ... acceleration
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelAcceleration));
    View.findDrawableById("unitTopLeft").setText("[g]");
    // ... rate of turn
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelRateOfTurn));
    View.findDrawableById("unitTopRight").setText(Lang.format("[$1$]", [$.oMySettings.sUnitRateOfTurn]));
    // ... altitude
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelAltitude));
    View.findDrawableById("unitLeft").setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... finesse
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... heading
    View.findDrawableById("labelRight").setText(Ui.loadResource(Rez.Strings.labelHeading));
    View.findDrawableById("unitRight").setText("[°]");
    // ... vertical speed
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed));
    View.findDrawableById("unitBottomLeft").setText(Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]));
    // ... ground speed
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    View.findDrawableById("unitBottomRight").setText(Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]));

    // Unmute tones
    App.getApp().unmuteTones(MyApp.TONES_SAFETY);
  }

  function updateLayout() {
    //Sys.println("DEBUG: MyViewGeneral.updateLayout()");
    MyViewGlobal.updateLayout(true);

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.oRezValueTopLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueTopRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopRight.setText($.MY_NOVALUE_LEN3);
      self.oRezValueLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setText($.MY_NOVALUE_LEN2);
      self.oRezValueRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueRight.setText($.MY_NOVALUE_LEN3);
      self.oRezValueBottomLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueBottomRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomRight.setText($.MY_NOVALUE_LEN3);
      return;
    }
    else if($.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values (and dependent colors)
    var fValue;
    var sValue;

    // ... acceleration
    self.oRezValueTopLeft.setColor(self.iColorText);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 2 ? $.oMyProcessing.fAcceleration_filtered : $.oMyProcessing.fAcceleration;
    if(fValue != null) {
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... rate of turn
    self.oRezValueTopRight.setColor(self.iColorText);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 1 ? $.oMyProcessing.fRateOfTurn_filtered : $.oMyProcessing.fRateOfTurn;
    if(fValue != null) {
      fValue *= $.oMySettings.fUnitRateOfTurnCoefficient;
      if($.oMySettings.iUnitRateOfTurn == 1) {
        sValue = fValue.format("%+.1f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue <= -0.05f) {
            self.oRezValueTopRight.setColor(Gfx.COLOR_RED);
          }
          else if(fValue >= 0.05f) {
            self.oRezValueTopRight.setColor(Gfx.COLOR_DK_GREEN);
          }
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue <= -0.5f) {
            self.oRezValueTopRight.setColor(Gfx.COLOR_RED);
          }
          else if(fValue >= 0.5f) {
            self.oRezValueTopRight.setColor(Gfx.COLOR_DK_GREEN);
          }
        }
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezValueLeft.setColor(self.iColorText);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 2 ? $.oMyProcessing.fAltitude_filtered : $.oMyProcessing.fAltitude;
    if(fValue != null) {
      fValue *= $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezValueCenter.setColor(self.iColorText);
    if($.oMyProcessing.fFinesse != null and !$.oMyProcessing.bAscent) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... heading
    self.oRezValueRight.setColor(self.iColorText);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 2 ? $.oMyProcessing.fHeading_filtered : $.oMyProcessing.fHeading;
    if(fValue != null) {
      //fValue = ((fValue * 180.0f/Math.PI).toNumber()) % 360;
      fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
      sValue = fValue.format("%d");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... variometer
    self.oRezValueBottomLeft.setColor(self.iColorText);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 1 ? $.oMyProcessing.fVariometer_filtered : $.oMyProcessing.fVariometer;
    if(fValue != null) {
      fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.05f) {
            self.oRezValueBottomLeft.setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.05f) {
            self.oRezValueBottomLeft.setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            self.oRezValueBottomLeft.setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.5f) {
            self.oRezValueBottomLeft.setColor(Gfx.COLOR_RED);
          }
        }
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... ground speed
    self.oRezValueBottomRight.setColor(self.iColorText);
    fValue = $.oMySettings.iGeneralDisplayFilter >= 1 ? $.oMyProcessing.fGroundSpeed_filtered : $.oMyProcessing.fGroundSpeed;
    if(fValue != null) {
      fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGeneral.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    App.getApp().muteTones();
  }

}

class MyViewGeneralDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewGeneralDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewTimers(),
                    new MyViewTimersDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewGeneralDelegate.onNextPage()");
    Ui.switchToView(new MyViewSafety(),
                    new MyViewSafetyDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
