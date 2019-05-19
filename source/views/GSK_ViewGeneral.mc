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
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class GSK_ViewGeneral extends GSK_ViewGlobal {

  //
  // FUNCTIONS: GSK_ViewGlobal (override/implement)
  //

  function initialize() {
    GSK_ViewGlobal.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: GSK_ViewGeneral.prepare()");
    GSK_ViewGlobal.prepare();

    // Set colors (value-independent), labels and units
    // ... acceleration
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelAcceleration));
    View.findDrawableById("unitTopLeft").setText("[g]");
    // ... rate of turn
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelRateOfTurn));
    View.findDrawableById("unitTopRight").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitRateOfTurn]));
    // ... altitude
    View.findDrawableById("labelLeft").setText(Ui.loadResource(Rez.Strings.labelAltitude));
    View.findDrawableById("unitLeft").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    // ... finesse
    View.findDrawableById("labelCenter").setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... heading
    View.findDrawableById("labelRight").setText(Ui.loadResource(Rez.Strings.labelHeading));
    View.findDrawableById("unitRight").setText("[°]");
    // ... vertical speed
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed));
    View.findDrawableById("unitBottomLeft").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitVerticalSpeed]));
    // ... ground speed
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    View.findDrawableById("unitBottomRight").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitHorizontalSpeed]));

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);
  }

  function updateLayout() {
    //Sys.println("DEBUG: GSK_ViewGeneral.updateLayout()");
    GSK_ViewGlobal.updateLayout(true);

    // Colors
    if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.oRezValueTopLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueTopRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setText($.GSK_NOVALUE_LEN2);
      self.oRezValueRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueBottomRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueBottomRight.setText($.GSK_NOVALUE_LEN3);
      return;
    }
    else if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
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
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 2 ? $.GSK_oProcessing.fAcceleration_filtered : $.GSK_oProcessing.fAcceleration;
    if(fValue != null) {
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... rate of turn
    self.oRezValueTopRight.setColor(self.iColorText);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fRateOfTurn_filtered : $.GSK_oProcessing.fRateOfTurn;
    if(fValue != null) {
      fValue *= $.GSK_oSettings.fUnitRateOfTurnCoefficient;
      if($.GSK_oSettings.iUnitRateOfTurn == 1) {
        sValue = fValue.format("%+.1f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
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
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
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
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezValueLeft.setColor(self.iColorText);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 2 ? $.GSK_oProcessing.fAltitude_filtered : $.GSK_oProcessing.fAltitude;
    if(fValue != null) {
      fValue *= $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezValueCenter.setColor(self.iColorText);
    if($.GSK_oProcessing.fFinesse != null and !$.GSK_oProcessing.bAscent) {
      fValue = $.GSK_oProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... heading
    self.oRezValueRight.setColor(self.iColorText);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 2 ? $.GSK_oProcessing.fHeading_filtered : $.GSK_oProcessing.fHeading;
    if(fValue != null) {
      //fValue = ((fValue * 180.0f/Math.PI).toNumber()) % 360;
      fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
      sValue = fValue.format("%d");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... variometer
    self.oRezValueBottomLeft.setColor(self.iColorText);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fVariometer_filtered : $.GSK_oProcessing.fVariometer;
    if(fValue != null) {
      fValue *= $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
      if($.GSK_oSettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
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
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
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
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomLeft.setText(sValue);

    // ... ground speed
    self.oRezValueBottomRight.setColor(self.iColorText);
    fValue = $.GSK_oSettings.iGeneralDisplayFilter >= 1 ? $.GSK_oProcessing.fGroundSpeed_filtered : $.GSK_oProcessing.fGroundSpeed;
    if(fValue != null) {
      fValue *= $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewGeneral.onHide()");
    GSK_ViewGlobal.onHide();

    // Mute tones
    App.getApp().muteTones();
  }

}

class GSK_ViewGeneralDelegate extends GSK_ViewGlobalDelegate {

  function initialize() {
    GSK_ViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewGeneralDelegate.onPreviousPage()");
    Ui.switchToView(new GSK_ViewTimers(), new GSK_ViewTimersDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewGeneralDelegate.onNextPage()");
    Ui.switchToView(new GSK_ViewSafety(), new GSK_ViewSafetyDelegate(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
