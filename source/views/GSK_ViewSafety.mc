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

// Display mode (intent)
var GSK_ViewSafety_bShowSettings = false;
var GSK_ViewSafety_bSelectFields = false;
var GSK_ViewSafety_iFieldTopLeft = 0;
var GSK_ViewSafety_iFieldBottomRight = 0;

class GSK_ViewSafety extends GSK_ViewGlobal {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShowSettings;
  private var bSelectFields;
  private var iFieldTopLeft;
  private var iFieldBottomRight;
  private var bProcessingEstimation;

  // Resources
  // ... fields (labels)
  private var oRezLabelLeft;
  private var oRezLabelCenter;
  private var oRezLabelRight;
  // ... fields (units)
  private var oRezUnitLeft;
  private var oRezUnitRight;
  // ... buttons
  private var oRezButtonKeyUp;
  private var oRezButtonKeyDown;
  // ... strings
  private var sTitle;
  private var sValueHeightGround;

  // Layout-specific
  private var fLayoutCenter;
  private var fLayoutBugR1;
  private var fLayoutBugR2;
  private var fLayoutBugR3;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() {
    self.fLayoutCenter = 120.0f;
    self.fLayoutBugR1 = 119.0f;
    self.fLayoutBugR2 = 100.0f;
    self.fLayoutBugR3 = 103.0f;
  }

  (:layout_260x260)
  function initLayout() {
    self.fLayoutCenter = 130.0f;
    self.fLayoutBugR1 = 129.0f;
    self.fLayoutBugR2 = 108.0f;
    self.fLayoutBugR3 = 112.0f;
  }

  (:layout_280x280)
  function initLayout() {
    self.fLayoutCenter = 140.0f;
    self.fLayoutBugR1 = 139.0f;
    self.fLayoutBugR2 = 117.0f;
    self.fLayoutBugR3 = 120.0f;
  }


  //
  // FUNCTIONS: GSK_ViewGlobal (override/implement)
  //

  function initialize() {
    GSK_ViewGlobal.initialize();

    // Layout-specific initialization
    self.initLayout();

    // Display mode
    // ... internal
    self.bShowSettings = false;
    self.bSelectFields = false;
    self.iFieldTopLeft = 0;
    self.iFieldBottomRight = 0;
    self.bProcessingEstimation = true;
  }

  function onLayout(_oDC) {
    if(!GSK_ViewGlobal.onLayout(_oDC)) {
      return false;
    }

    // Load resources
    // ... fields (labels)
    self.oRezLabelLeft = View.findDrawableById("labelLeft");
    self.oRezLabelCenter = View.findDrawableById("labelCenter");
    self.oRezLabelRight = View.findDrawableById("labelRight");
    // ... fields (units)
    self.oRezUnitLeft = View.findDrawableById("unitLeft");
    self.oRezUnitRight = View.findDrawableById("unitRight");

    // Done
    return true;
  }

  function prepare() {
    //Sys.println("DEBUG: GSK_ViewSafety.prepare()");
    GSK_ViewGlobal.prepare();

    // Load resources
    // ... strings
    self.sTitle = Ui.loadResource(Rez.Strings.titleViewSafety);
    self.sValueHeightGround = Ui.loadResource(Rez.Strings.valueHeightGround);

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY);

    // Internal state
    self.bShowSettings = !$.GSK_ViewSafety_bShowSettings;  // ... force adaptLayout()
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewSafety.onUpdate()");

    // Update layout
    if(!$.GSK_ViewSafety_bShowSettings) {
      self.updateLayoutSafety();
    }
    else {
      self.updateLayoutSettings();
    }
    View.onUpdate(_oDC);

    // Draw buttons
    if($.GSK_ViewSafety_bSelectFields) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null) {
        self.oRezButtonKeyUp = new Rez.Drawables.drawButtonTopLeft();
        self.oRezButtonKeyDown = new Rez.Drawables.drawButtonBottomRight();
      }
      self.oRezButtonKeyUp.draw(_oDC);
      self.oRezButtonKeyDown.draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }

    // Draw heading bug
    if(!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings
       and ($.GSK_oSettings.iSafetyHeadingBug == 2 or ($.GSK_oSettings.iSafetyHeadingBug == 1 and !$.GSK_oProcessing.bEstimation))
       and $.GSK_oProcessing.iAccuracy >= Pos.QUALITY_LAST_KNOWN
       and $.GSK_oProcessing.fBearingToDestination != null
       and $.GSK_oProcessing.fHeading != null) {
      self.drawHeadingBug(_oDC);
    }

    // Done
    return true;
  }

  function adaptLayoutSafety() {
    //Sys.println("DEBUG: GSK_ViewSafety.adaptLayoutSafety()");

    // Set colors (value-independent), labels and units
    // ... destination (name) / elevation at destination / bearing to destination
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldTopLeft == 2) {  // ... bearing to destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelBearingToDestination));
      View.findDrawableById("unitTopLeft").setText("[°]");
    }
    else if($.GSK_ViewSafety_iFieldTopLeft == 1) {  // ... elevation at destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
      View.findDrawableById("unitTopLeft").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    }
    else {  // ... destination (name)
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
      View.findDrawableById("unitTopLeft").setText(GSK_NOVALUE_BLANK);
    }
    // ... distance to destination
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelDistanceToDestination));
    View.findDrawableById("unitTopRight").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitDistance]));
    // ... altitude
    self.oRezLabelLeft.setText(Ui.loadResource(Rez.Strings.labelAltitude));
    self.oRezUnitLeft.setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    // ... finesse
    self.oRezLabelCenter.setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... height at destination
    self.oRezLabelRight.setText(Ui.loadResource(Rez.Strings.labelHeightAtDestination));
    self.oRezUnitRight.setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    // ... vertical speed
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed));
    View.findDrawableById("unitBottomLeft").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitVerticalSpeed]));
    // ... ground speed / speed-to(wards)-destination
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelSpeedToDestination));
    }
    else {  // ... ground speed
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    }
    View.findDrawableById("unitBottomRight").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitHorizontalSpeed]));
  }

  function updateLayoutSafety() {
    //Sys.println("DEBUG: GSK_ViewSafety.updateLayoutSafety()");
    GSK_ViewGlobal.updateLayout(true);

    // Adapt the layout
    if(self.bShowSettings != $.GSK_ViewSafety_bShowSettings
       or self.bSelectFields != $.GSK_ViewSafety_bSelectFields
       or self.iFieldTopLeft != $.GSK_ViewSafety_iFieldTopLeft
       or self.iFieldBottomRight != $.GSK_ViewSafety_iFieldBottomRight
       or self.bProcessingEstimation != $.GSK_oProcessing.bEstimation
       ) {
      self.adaptLayoutSafety();
      self.bShowSettings = $.GSK_ViewSafety_bShowSettings;
      self.bSelectFields = $.GSK_ViewSafety_bSelectFields;
      self.iFieldTopLeft = $.GSK_ViewSafety_iFieldTopLeft;
      self.iFieldBottomRight = $.GSK_ViewSafety_iFieldBottomRight;
      self.bProcessingEstimation = $.GSK_oProcessing.bEstimation;
    }

    // Colors
    if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.oRezValueTopLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezValueTopRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      self.oRezLabelLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezUnitLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setText($.GSK_NOVALUE_LEN3);
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      self.oRezLabelCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setText($.GSK_NOVALUE_LEN2);
      self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GRAY);
      self.oRezLabelRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezUnitRight.setColor(Gfx.COLOR_LT_GRAY);
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

    // ... destination (name) / elevation at destination / bearing to destination
    self.oRezValueTopLeft.setColor(Gfx.COLOR_BLUE);
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldTopLeft == 2) {  // ... bearing to destination
      if($.GSK_oProcessing.fBearingToDestination != null) {
        //fValue = (($.GSK_oProcessing.fBearingToDestination * 180.0f/Math.PI).toNumber()) % 360;
        fValue = (($.GSK_oProcessing.fBearingToDestination * 57.2957795131f).toNumber()) % 360;
        sValue = fValue.format("%d");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else if($.GSK_ViewSafety_iFieldTopLeft == 1) {  // ... elevation at destination
      if($.GSK_oProcessing.fDestinationElevation != null) {
        fValue = $.GSK_oProcessing.fDestinationElevation * $.GSK_oSettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else {  // ... destination (name)
      if($.GSK_oProcessing.sDestinationName != null) {
        sValue = $.GSK_oProcessing.sDestinationName;
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... distance to destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_BLUE);
    if($.GSK_oProcessing.fDistanceToDestination != null) {
      fValue = $.GSK_oProcessing.fDistanceToDestination * $.GSK_oSettings.fUnitDistanceCoefficient;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezLabelLeft.setColor(self.iColorText);
    self.oRezUnitLeft.setColor(self.iColorText);
    self.oRezValueLeft.setColor(self.iColorText);
    if($.GSK_oProcessing.fAltitude != null) {
      if(!$.GSK_oProcessing.bSafetyStateful) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      }
      else if($.GSK_oProcessing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_RED);
      }
      else if($.GSK_oProcessing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_ORANGE);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GREEN);
      }
      fValue = $.GSK_oProcessing.fAltitude * $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezLabelCenter.setColor(self.iColorText);
    self.oRezValueCenter.setColor(self.iColorText);
    if($.GSK_oProcessing.fFinesse != null) {
      if($.GSK_oProcessing.bAscent) {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GREEN);
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          self.oRezValueCenter.setColor(Gfx.COLOR_DK_GRAY);
        }
      }
      else if($.GSK_oProcessing.fFinesse <= $.GSK_oSettings.iSafetyFinesse) {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_RED);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_ORANGE);
      }
      fValue = $.GSK_oProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... height at destination
    self.oRezLabelRight.setColor(self.iColorText);
    self.oRezUnitRight.setColor(self.iColorText);
    self.oRezValueRight.setColor(self.iColorText);
    if($.GSK_oProcessing.fHeightAtDestination != null) {
      if($.GSK_oProcessing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_RED);
      }
      else if($.GSK_oProcessing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_ORANGE);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GREEN);
      }
      if($.GSK_oProcessing.fHeightAtDestination <= 0.0f) {
        sValue = self.sValueHeightGround;
      }
      else {
        fValue = ($.GSK_oProcessing.fHeightAtDestination - $.GSK_oSettings.fSafetyHeightReference) * $.GSK_oSettings.fUnitElevationCoefficient;
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GRAY);
      sValue = $.GSK_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... variometer
    self.oRezValueBottomLeft.setColor(self.iColorText);
    if($.GSK_oProcessing.fVariometer_filtered != null) {
      fValue = $.GSK_oProcessing.fVariometer_filtered * $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
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

    // ... ground speed / speed-to(wards)-destination
    self.oRezValueBottomRight.setColor(self.iColorText);
    if((!$.GSK_ViewSafety_bSelectFields and !$.GSK_ViewSafety_bShowSettings and !$.GSK_oProcessing.bEstimation)
       or $.GSK_ViewSafety_iFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      if($.GSK_oProcessing.fSpeedToDestination != null) {
        fValue = $.GSK_oProcessing.fSpeedToDestination * $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%+.0f");
        if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            self.oRezValueBottomRight.setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.5f) {
            self.oRezValueBottomRight.setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    else {  // ... ground speed
      if($.GSK_oProcessing.fGroundSpeed_filtered != null) {
        fValue = $.GSK_oProcessing.fGroundSpeed_filtered * $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.GSK_NOVALUE_LEN3;
      }
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function drawHeadingBug(_oDC) {
    // Heading
    var fBearingRelative = $.GSK_oProcessing.fBearingToDestination - $.GSK_oProcessing.fHeading;
    // ... bug
    var iColor = Gfx.COLOR_BLUE;
    var aPoints =
      [[self.fLayoutCenter+self.fLayoutBugR1*Math.sin(fBearingRelative), self.fLayoutCenter-self.fLayoutBugR1*Math.cos(fBearingRelative)],
       [self.fLayoutCenter+self.fLayoutBugR2*Math.sin(fBearingRelative-0.125f), self.fLayoutCenter-self.fLayoutBugR2*Math.cos(fBearingRelative-0.125f)],
       [self.fLayoutCenter+self.fLayoutBugR2*Math.sin(fBearingRelative+0.125f), self.fLayoutCenter-self.fLayoutBugR2*Math.cos(fBearingRelative+0.125f)]];
    _oDC.setColor(iColor, iColor);
    _oDC.fillPolygon(aPoints);
    // ... status
    if($.GSK_oProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      iColor = Gfx.COLOR_LT_GRAY;
    }
    else {
      iColor = $.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }
    aPoints =
      [[self.fLayoutCenter+self.fLayoutBugR1*Math.sin(fBearingRelative), self.fLayoutCenter-self.fLayoutBugR1*Math.cos(fBearingRelative)],
       [self.fLayoutCenter+self.fLayoutBugR3*Math.sin(fBearingRelative-0.035f), self.fLayoutCenter-self.fLayoutBugR3*Math.cos(fBearingRelative-0.035f)],
       [self.fLayoutCenter+self.fLayoutBugR3*Math.sin(fBearingRelative+0.035f), self.fLayoutCenter-self.fLayoutBugR3*Math.cos(fBearingRelative+0.035f)]];
    _oDC.setColor(iColor, iColor);
    _oDC.fillPolygon(aPoints);
  }

  function adaptLayoutSettings() {
    //Sys.println("DEBUG: GSK_ViewSafety.adaptLayoutSettings()");

    // Set colors (value-independent), labels and units
    // ... fields background
    self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    // ... destination (name)
    self.oRezValueTopLeft.setColor(Gfx.COLOR_BLUE);
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
    View.findDrawableById("unitTopLeft").setText(GSK_NOVALUE_BLANK);
    // ... elevation at destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_BLUE);
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
    View.findDrawableById("unitTopRight").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    // ... warning height
    self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_ORANGE);
    self.oRezLabelLeft.setColor(self.iColorText);
    self.oRezLabelLeft.setText(Ui.loadResource(Rez.Strings.labelHeightWarning));
    self.oRezUnitLeft.setColor(self.iColorText);
    self.oRezUnitLeft.setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    self.oRezValueLeft.setColor(self.iColorText);
    // ... reference finesse
    self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GREEN);
    self.oRezLabelCenter.setColor(self.iColorText);
    self.oRezLabelCenter.setText(Ui.loadResource(Rez.Strings.labelFinesse));
    self.oRezValueCenter.setColor(self.iColorText);
    // ... critical height
    self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_RED);
    self.oRezLabelRight.setColor(self.iColorText);
    self.oRezLabelRight.setText(Ui.loadResource(Rez.Strings.labelHeightCritical));
    self.oRezUnitRight.setColor(self.iColorText);
    self.oRezUnitRight.setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    self.oRezValueRight.setColor(self.iColorText);
    // ... decision height
    self.oRezValueBottomLeft.setColor(self.iColorText);
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelHeightDecision));
    View.findDrawableById("unitBottomLeft").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    // ... reference height
    self.oRezValueBottomRight.setColor(self.iColorText);
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelHeightReference));
    View.findDrawableById("unitBottomRight").setText(Lang.format("[$1$]", [$.GSK_oSettings.sUnitElevation]));
    // ... application name
    self.oRezValueFooter.setColor(Gfx.COLOR_DK_GRAY);
  }

  function updateLayoutSettings() {
    //Sys.println("DEBUG: GSK_ViewSafety.updateLayoutSettings()");
    GSK_ViewSafety.updateLayout(false);

    // Adapt the layout
    if(self.bShowSettings != $.GSK_ViewSafety_bShowSettings) {
      self.adaptLayoutSettings();
      self.bShowSettings = $.GSK_ViewSafety_bShowSettings;
    }

    // Set the values
    var fValue;
    // ... destination (name)
    if($.GSK_oProcessing.sDestinationName != null) {
      self.oRezValueTopLeft.setText($.GSK_oProcessing.sDestinationName);
    }
    else {
      self.oRezValueTopLeft.setText($.GSK_NOVALUE_LEN4);
    }
    // ... elevation at destination
    if($.GSK_oProcessing.fDestinationElevation != null) {
      fValue = $.GSK_oProcessing.fDestinationElevation * $.GSK_oSettings.fUnitElevationCoefficient;
      self.oRezValueTopRight.setText(fValue.format("%.0f"));
    }
    else {
      self.oRezValueTopRight.setText($.GSK_NOVALUE_LEN3);
    }
    // ... warning height
    fValue = $.GSK_oSettings.fSafetyHeightWarning * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueLeft.setText(fValue.format("%.0f"));
    // ... reference finesse
    oRezValueCenter.setText($.GSK_oSettings.iSafetyFinesse.format("%d"));
    // ... critical height
    fValue = $.GSK_oSettings.fSafetyHeightCritical * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueRight.setText(fValue.format("%.0f"));
    // ... decision height
    fValue = $.GSK_oSettings.fSafetyHeightDecision * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueBottomLeft.setText(fValue.format("%.0f"));
    // ... reference height
    fValue = $.GSK_oSettings.fSafetyHeightReference * $.GSK_oSettings.fUnitElevationCoefficient;
    self.oRezValueBottomRight.setText(fValue.format("%.0f"));
    // ... application name
    self.oRezValueFooter.setText(self.sTitle);
  }

  function onHide() {
    //Sys.println("DEBUG: GSK_ViewSafety.onHide()");
    GSK_ViewGlobal.onHide();

    // Internal state
    $.GSK_ViewSafety_bShowSettings = false;
    $.GSK_ViewSafety_bSelectFields = false;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
  }

}

class GSK_ViewSafetyDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onMenu()");
    if($.GSK_ViewSafety_bShowSettings or $.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.pushView(new GSK_MenuGeneric(:menuDestination), new GSK_MenuGenericDelegate(:menuDestination), Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.GSK_ViewSafety_bShowSettings = true;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onSelect()");
    if($.GSK_ViewSafety_bShowSettings) {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = true;
      Ui.requestUpdate();
    }
    else if($.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_bShowSettings = true;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.requestUpdate();
    }
    else if($.GSK_oActivity == null) {
      Ui.pushView(new GSK_MenuGenericConfirm(:contextActivity, :actionStart), new GSK_MenuGenericConfirmDelegate(:contextActivity, :actionStart, false), Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new GSK_MenuGeneric(:menuActivity), new GSK_MenuGenericDelegate(:menuActivity), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onBack()");
    if($.GSK_ViewSafety_bShowSettings or $.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_bShowSettings = false;
      $.GSK_ViewSafety_bSelectFields = false;
      Ui.requestUpdate();
      return true;
    }
    else if($.GSK_oActivity != null) {
      if($.GSK_oSettings.bGeneralLapKey) {
        $.GSK_oActivity.addLap();
      }
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onPreviousPage()");
    if($.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_iFieldTopLeft = ($.GSK_ViewSafety_iFieldTopLeft + 1) % 3;
      Ui.requestUpdate();
    }
    else if(!$.GSK_ViewSafety_bShowSettings) {
      Ui.switchToView(new GSK_ViewGeneral(), new GSK_ViewGeneralDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewSafetyDelegate.onNextPage()");
    if($.GSK_ViewSafety_bSelectFields) {
      $.GSK_ViewSafety_iFieldBottomRight = ($.GSK_ViewSafety_iFieldBottomRight + 1) % 2;
      Ui.requestUpdate();
    }
    else if(!$.GSK_ViewSafety_bShowSettings) {
      Ui.switchToView(new GSK_ViewRateOfTurn(), new GSK_ViewRateOfTurnDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

}
