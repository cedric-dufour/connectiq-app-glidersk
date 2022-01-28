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
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var bMyViewSafetyShowSettings as Boolean = false;
var bMyViewSafetySelectFields as Boolean = false;
var iMyViewSafetyFieldTopLeft as Number = 0;
var iMyViewSafetyFieldBottomRight as Number = 0;

class MyViewSafety extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShowSettings as Boolean = false;
  private var bSelectFields as Boolean = false;
  private var iFieldTopLeft as Number = 0;
  private var iFieldBottomRight as Number = 0;
  private var bProcessingDecision as Boolean = false;

  // Resources
  // ... fields (labels)
  private var oRezLabelLeft as Ui.Text?;
  private var oRezLabelCenter as Ui.Text?;
  private var oRezLabelRight as Ui.Text?;
  // ... fields (units)
  private var oRezUnitLeft as Ui.Text?;
  private var oRezUnitRight as Ui.Text?;
  // ... buttons
  private var oRezButtonKeyUp as Ui.Drawable?;
  private var oRezButtonKeyDown as Ui.Drawable?;
  // ... strings
  private var sTitle as String = "Safety";
  private var sValueHeightInvalid as String = "XXX";

  // Layout-specific
  private var fLayoutCenter as Float = 120.0f;
  private var fLayoutBugR1 as Float = 119.0f;
  private var fLayoutBugR2 as Float = 100.0f;
  private var fLayoutBugR3 as Float = 103.0f;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() as Void {
    self.fLayoutCenter = 120.0f;
    self.fLayoutBugR1 = 119.0f;
    self.fLayoutBugR2 = 100.0f;
    self.fLayoutBugR3 = 103.0f;
  }

  (:layout_260x260)
  function initLayout() as Void {
    self.fLayoutCenter = 130.0f;
    self.fLayoutBugR1 = 129.0f;
    self.fLayoutBugR2 = 108.0f;
    self.fLayoutBugR3 = 112.0f;
  }

  (:layout_280x280)
  function initLayout() as Void {
    self.fLayoutCenter = 140.0f;
    self.fLayoutBugR1 = 139.0f;
    self.fLayoutBugR2 = 117.0f;
    self.fLayoutBugR3 = 120.0f;
  }


  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();

    // Layout-specific initialization
    self.initLayout();
  }

  function onLayout(_oDC as Gfx.Dc) as Void {
    MyViewGlobal.onLayout(_oDC);

    // Load resources
    // ... fields (labels)
    self.oRezLabelLeft = View.findDrawableById("labelLeft") as Ui.Text;
    self.oRezLabelCenter = View.findDrawableById("labelCenter") as Ui.Text;
    self.oRezLabelRight = View.findDrawableById("labelRight") as Ui.Text;
    // ... fields (units)
    self.oRezUnitLeft = View.findDrawableById("unitLeft") as Ui.Text;
    self.oRezUnitRight = View.findDrawableById("unitRight") as Ui.Text;
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewSafety.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... strings
    self.sTitle = Ui.loadResource(Rez.Strings.titleViewSafety) as String;
    self.sValueHeightInvalid = Ui.loadResource(Rez.Strings.valueHeightInvalid) as String;

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones(MyApp.TONES_SAFETY);

    // Internal state
    self.bShowSettings = !$.bMyViewSafetyShowSettings;  // ... force adaptLayout()
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewSafety.onUpdate()");

    // Update layout
    if(!$.bMyViewSafetyShowSettings) {
      self.updateLayoutSafety();
    }
    else {
      self.updateLayoutSettings();
    }
    MyViewGlobal.onUpdate(_oDC);

    // Draw buttons
    if($.bMyViewSafetySelectFields) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null) {
        self.oRezButtonKeyUp = new Rez.Drawables.drawButtonTopLeft();
        self.oRezButtonKeyDown = new Rez.Drawables.drawButtonBottomRight();
      }
      (self.oRezButtonKeyUp as Ui.Drawable).draw(_oDC);
      (self.oRezButtonKeyDown as Ui.Drawable).draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }

    // Draw heading bug
    if(!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings
       and ($.oMySettings.iSafetyHeadingBug == 2 or ($.oMySettings.iSafetyHeadingBug == 1 and $.oMyProcessing.bDecision))
       and $.oMyProcessing.iAccuracy >= Pos.QUALITY_LAST_KNOWN
       and LangUtils.notNaN($.oMyProcessing.fBearingToDestination)
       and LangUtils.notNaN($.oMyProcessing.fHeading)) {
      self.drawHeadingBug(_oDC);
    }
  }

  function adaptLayoutSafety() as Void {
    //Sys.println("DEBUG: MyViewSafety.adaptLayoutSafety()");

    // Set colors (value-independent), labels and units
    // ... destination (name) / elevation at destination / bearing to destination
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldTopLeft == 2) {  // ... bearing to destination
      (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelBearingToDestination) as String);
      (View.findDrawableById("unitTopLeft") as Ui.Text).setText("[°]");
    }
    else if($.iMyViewSafetyFieldTopLeft == 1) {  // ... elevation at destination
      (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination) as String);
      (View.findDrawableById("unitTopLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    }
    else {  // ... destination (name)
      (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelDestination) as String);
      (View.findDrawableById("unitTopLeft") as Ui.Text).setText(MY_NOVALUE_BLANK);
    }
    // ... distance to destination
    (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelDistanceToDestination) as String);
    (View.findDrawableById("unitTopRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitDistance]));
    // ... altitude
    (self.oRezLabelLeft as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAltitude) as String);
    (self.oRezUnitLeft as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... finesse
    (self.oRezLabelCenter as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelFinesse) as String);
    // ... height at destination
    (self.oRezLabelRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeightAtDestination) as String);
    (self.oRezUnitRight as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... vertical speed
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]));
    // ... ground speed / speed-to(wards)-destination
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelSpeedToDestination) as String);
    }
    else {  // ... ground speed
      (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelGroundSpeed) as String);
    }
    (View.findDrawableById("unitBottomRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]));
  }

  function updateLayoutSafety() as Void {
    //Sys.println("DEBUG: MyViewSafety.updateLayoutSafety()");
    MyViewGlobal.updateLayout(true);

    // Adapt the layout
    if(self.bShowSettings != $.bMyViewSafetyShowSettings
       or self.bSelectFields != $.bMyViewSafetySelectFields
       or self.iFieldTopLeft != $.iMyViewSafetyFieldTopLeft
       or self.iFieldBottomRight != $.iMyViewSafetyFieldBottomRight
       or self.bProcessingDecision != $.oMyProcessing.bDecision
       ) {
      self.adaptLayoutSafety();
      self.bShowSettings = $.bMyViewSafetyShowSettings;
      self.bSelectFields = $.bMyViewSafetySelectFields;
      self.iFieldTopLeft = $.iMyViewSafetyFieldTopLeft;
      self.iFieldBottomRight = $.iMyViewSafetyFieldBottomRight;
      self.bProcessingDecision = $.oMyProcessing.bDecision;
    }

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_DK_RED);
      (self.oRezValueTopLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueTopLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueTopRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueTopRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      (self.oRezLabelLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezUnitLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      (self.oRezLabelCenter as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueCenter as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueCenter as Ui.Text).setText($.MY_NOVALUE_LEN2);
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertRight(Gfx.COLOR_DK_GRAY);
      (self.oRezLabelRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezUnitRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueBottomLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueBottomRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      return;
    }
    else if($.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values (and dependent colors)
    var fValue;
    var sValue;

    // ... destination (name) / elevation at destination / bearing to destination
    (self.oRezValueTopLeft as Ui.Text).setColor(Gfx.COLOR_BLUE);
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldTopLeft == 2) {  // ... bearing to destination
      if($.oMyProcessing.bDecision and $.oMyProcessing.bGrace) {
        (self.oRezValueTopLeft as Ui.Text).setColor(Gfx.COLOR_PURPLE);
      }
      if(LangUtils.notNaN($.oMyProcessing.fBearingToDestination)) {
        //fValue = (($.oMyProcessing.fBearingToDestination * 180.0f/Math.PI).toNumber()) % 360;
        fValue = (($.oMyProcessing.fBearingToDestination * 57.2957795131f).toNumber()) % 360;
        sValue = fValue.format("%d");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else if($.iMyViewSafetyFieldTopLeft == 1) {  // ... elevation at destination
      if(LangUtils.notNaN($.oMyProcessing.fDestinationElevation)) {
        fValue = $.oMyProcessing.fDestinationElevation * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else {  // ... destination (name)
      if($.oMyProcessing.sDestinationName.length() > 0) {
        sValue = $.oMyProcessing.sDestinationName;
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    (self.oRezValueTopLeft as Ui.Text).setText(sValue);

    // ... distance to destination
    (self.oRezValueTopRight as Ui.Text).setColor(Gfx.COLOR_BLUE);
    if(LangUtils.notNaN($.oMyProcessing.fDistanceToDestination)) {
      fValue = $.oMyProcessing.fDistanceToDestination * $.oMySettings.fUnitDistanceCoefficient;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopRight as Ui.Text).setText(sValue);

    // ... altitude
    (self.oRezLabelLeft as Ui.Text).setColor(self.iColorText);
    (self.oRezUnitLeft as Ui.Text).setColor(self.iColorText);
    (self.oRezValueLeft as Ui.Text).setColor(self.iColorText);
    if(LangUtils.notNaN($.oMyProcessing.fAltitude)) {
      if(!$.oMyProcessing.bSafetyStateful) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      }
      else if($.oMyProcessing.bAltitudeCritical) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_RED);
      }
      else if($.oMyProcessing.bAltitudeWarning) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_ORANGE);
      }
      else {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_DK_GREEN);
      }
      fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueLeft as Ui.Text).setText(sValue);

    // ... finesse
    (self.oRezLabelCenter as Ui.Text).setColor(self.iColorText);
    (self.oRezValueCenter as Ui.Text).setColor(self.iColorText);
    if(LangUtils.notNaN($.oMyProcessing.fFinesse)) {
      if($.oMyProcessing.bAscent) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertCenter(Gfx.COLOR_DK_GREEN);
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          (self.oRezValueCenter as Ui.Text).setColor(Gfx.COLOR_DK_GRAY);
        }
      }
      else if($.oMyProcessing.fFinesse <= $.oMySettings.iSafetyFinesse) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertCenter(Gfx.COLOR_RED);
      }
      else {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertCenter(Gfx.COLOR_ORANGE);
      }
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      sValue = $.MY_NOVALUE_LEN2;
    }
    (self.oRezValueCenter as Ui.Text).setText(sValue);

    // ... height at destination
    (self.oRezLabelRight as Ui.Text).setColor(self.iColorText);
    (self.oRezUnitRight as Ui.Text).setColor(self.iColorText);
    (self.oRezValueRight as Ui.Text).setColor(self.iColorText);
    if(LangUtils.notNaN($.oMyProcessing.fHeightAtDestination)) {
      if($.oMyProcessing.bAltitudeCritical) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertRight(Gfx.COLOR_RED);
      }
      else if($.oMyProcessing.bAltitudeWarning) {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertRight(Gfx.COLOR_ORANGE);
      }
      else {
        (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertRight(Gfx.COLOR_DK_GREEN);
      }
      if($.oMyProcessing.fHeightAtDestination <= -10000.0f) {
        sValue = self.sValueHeightInvalid;
      }
      else {
        fValue = ($.oMyProcessing.fHeightAtDestination - $.oMySettings.fSafetyHeightReference) * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertRight(Gfx.COLOR_DK_GRAY);
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueRight as Ui.Text).setText(sValue);

    // ... variometer
    (self.oRezValueBottomLeft as Ui.Text).setColor(self.iColorText);
    if(LangUtils.notNaN($.oMyProcessing.fVariometer_filtered)) {
      fValue = $.oMyProcessing.fVariometer_filtered * $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.05f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.05f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.5f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_RED);
          }
        }
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomLeft as Ui.Text).setText(sValue);

    // ... ground speed / speed-to(wards)-destination
    (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorText);
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      if(LangUtils.notNaN($.oMyProcessing.fSpeedToDestination)) {
        fValue = $.oMyProcessing.fSpeedToDestination * $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%+.0f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            (self.oRezValueBottomRight as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.5f) {
            (self.oRezValueBottomRight as Ui.Text).setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else {  // ... ground speed
      if(LangUtils.notNaN($.oMyProcessing.fGroundSpeed_filtered)) {
        fValue = $.oMyProcessing.fGroundSpeed_filtered * $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    (self.oRezValueBottomRight as Ui.Text).setText(sValue);
  }

  function drawHeadingBug(_oDC as Gfx.Dc) as Void {
    // Heading
    var fBearingRelative = $.oMyProcessing.fBearingToDestination - $.oMyProcessing.fHeading;
    // ... bug
    var iColor = ($.oMyProcessing.bDecision and $.oMyProcessing.bGrace) ? Gfx.COLOR_PURPLE : Gfx.COLOR_BLUE;
    var aPoints =
      [[self.fLayoutCenter+self.fLayoutBugR1*Math.sin(fBearingRelative).toFloat(), self.fLayoutCenter-self.fLayoutBugR1*Math.cos(fBearingRelative).toFloat()] as AFloats,
       [self.fLayoutCenter+self.fLayoutBugR2*Math.sin(fBearingRelative-0.125f).toFloat(), self.fLayoutCenter-self.fLayoutBugR2*Math.cos(fBearingRelative-0.125f).toFloat()] as AFloats,
       [self.fLayoutCenter+self.fLayoutBugR2*Math.sin(fBearingRelative+0.125f).toFloat(), self.fLayoutCenter-self.fLayoutBugR2*Math.cos(fBearingRelative+0.125f).toFloat()] as AFloats] as Array<AFloats>;
    _oDC.setColor(iColor, iColor);
    _oDC.fillPolygon(aPoints);
    // ... status
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      iColor = Gfx.COLOR_LT_GRAY;
    }
    else {
      iColor = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    }
    aPoints =
      [[self.fLayoutCenter+self.fLayoutBugR1*Math.sin(fBearingRelative).toFloat(), self.fLayoutCenter-self.fLayoutBugR1*Math.cos(fBearingRelative).toFloat()] as AFloats,
       [self.fLayoutCenter+self.fLayoutBugR3*Math.sin(fBearingRelative-0.035f).toFloat(), self.fLayoutCenter-self.fLayoutBugR3*Math.cos(fBearingRelative-0.035f).toFloat()] as AFloats,
       [self.fLayoutCenter+self.fLayoutBugR3*Math.sin(fBearingRelative+0.035f).toFloat(), self.fLayoutCenter-self.fLayoutBugR3*Math.cos(fBearingRelative+0.035f).toFloat()] as AFloats] as Array<AFloats>;
    _oDC.setColor(iColor, iColor);
    _oDC.fillPolygon(aPoints);
  }

  function adaptLayoutSettings() as Void {
    //Sys.println("DEBUG: MyViewSafety.adaptLayoutSettings()");

    // Set colors (value-independent), labels and units
    // ... fields background
    (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    // ... destination (name)
    (self.oRezValueTopLeft as Ui.Text).setColor(Gfx.COLOR_BLUE);
    (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelDestination) as String);
    (View.findDrawableById("unitTopLeft") as Ui.Text).setText(MY_NOVALUE_BLANK);
    // ... elevation at destination
    (self.oRezValueTopRight as Ui.Text).setColor(Gfx.COLOR_BLUE);
    (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination) as String);
    (View.findDrawableById("unitTopRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... warning height
    (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertLeft(Gfx.COLOR_ORANGE);
    (self.oRezLabelLeft as Ui.Text).setColor(self.iColorText);
    (self.oRezLabelLeft as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeightWarning) as String);
    (self.oRezUnitLeft as Ui.Text).setColor(self.iColorText);
    (self.oRezUnitLeft as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    (self.oRezValueLeft as Ui.Text).setColor(self.iColorText);
    // ... reference finesse
    (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertCenter(Gfx.COLOR_DK_GREEN);
    (self.oRezLabelCenter as Ui.Text).setColor(self.iColorText);
    (self.oRezLabelCenter as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelFinesse) as String);
    (self.oRezValueCenter as Ui.Text).setColor(self.iColorText);
    // ... critical height
    (self.oRezDrawableGlobal as MyDrawableGlobal).setColorAlertRight(Gfx.COLOR_RED);
    (self.oRezLabelRight as Ui.Text).setColor(self.iColorText);
    (self.oRezLabelRight as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeightCritical) as String);
    (self.oRezUnitRight as Ui.Text).setColor(self.iColorText);
    (self.oRezUnitRight as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    (self.oRezValueRight as Ui.Text).setColor(self.iColorText);
    // ... decision height
    (self.oRezValueBottomLeft as Ui.Text).setColor(self.iColorText);
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeightDecision) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... reference height
    (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorText);
    (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeightReference) as String);
    (View.findDrawableById("unitBottomRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... application name
    (self.oRezValueFooter as Ui.Text).setColor(Gfx.COLOR_DK_GRAY);
  }

  function updateLayoutSettings() as Void {
    //Sys.println("DEBUG: MyViewSafety.updateLayoutSettings()");
    MyViewSafety.updateLayout(false);

    // Adapt the layout
    if(self.bShowSettings != $.bMyViewSafetyShowSettings) {
      self.adaptLayoutSettings();
      self.bShowSettings = $.bMyViewSafetyShowSettings;
    }

    // Set the values
    var fValue;
    // ... destination (name)
    if($.oMyProcessing.sDestinationName.length() > 0) {
      (self.oRezValueTopLeft as Ui.Text).setText($.oMyProcessing.sDestinationName);
    }
    else {
      (self.oRezValueTopLeft as Ui.Text).setText($.MY_NOVALUE_LEN4);
    }
    // ... elevation at destination
    if(LangUtils.notNaN($.oMyProcessing.fDestinationElevation)) {
      fValue = $.oMyProcessing.fDestinationElevation * $.oMySettings.fUnitElevationCoefficient;
      (self.oRezValueTopRight as Ui.Text).setText(fValue.format("%.0f"));
    }
    else {
      (self.oRezValueTopRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
    }
    // ... warning height
    fValue = $.oMySettings.fSafetyHeightWarning * $.oMySettings.fUnitElevationCoefficient;
    (self.oRezValueLeft as Ui.Text).setText(fValue.format("%.0f"));
    // ... reference finesse
    (oRezValueCenter as Ui.Text).setText($.oMySettings.iSafetyFinesse.format("%d"));
    // ... critical height
    fValue = $.oMySettings.fSafetyHeightCritical * $.oMySettings.fUnitElevationCoefficient;
    (self.oRezValueRight as Ui.Text).setText(fValue.format("%.0f"));
    // ... decision height
    fValue = $.oMySettings.fSafetyHeightDecision * $.oMySettings.fUnitElevationCoefficient;
    (self.oRezValueBottomLeft as Ui.Text).setText(fValue.format("%.0f"));
    // ... reference height
    fValue = $.oMySettings.fSafetyHeightReference * $.oMySettings.fUnitElevationCoefficient;
    (self.oRezValueBottomRight as Ui.Text).setText(fValue.format("%.0f"));
    // ... application name
    (self.oRezValueFooter as Ui.Text).setText(self.sTitle);
  }

  function onHide() as Void {
    //Sys.println("DEBUG: MyViewSafety.onHide()");
    MyViewGlobal.onHide();

    // Internal state
    $.bMyViewSafetyShowSettings = false;
    $.bMyViewSafetySelectFields = false;

    // Mute tones
    (App.getApp() as MyApp).muteTones();

    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
  }

}

class MyViewSafetyDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: MyViewSafetyDelegate.onMenu()");
    if($.bMyViewSafetyShowSettings or $.bMyViewSafetySelectFields) {
      $.bMyViewSafetyShowSettings = false;
      $.bMyViewSafetySelectFields = false;
      Ui.pushView(new MyMenuGeneric(:menuDestination),
                  new MyMenuGenericDelegate(:menuDestination),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.oMyProcessing.bGrace = false;  // disable the grace period
      $.bMyViewSafetyShowSettings = true;
      $.bMyViewSafetySelectFields = false;
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewSafetyDelegate.onSelect()");
    if($.bMyViewSafetyShowSettings) {
      $.bMyViewSafetyShowSettings = false;
      $.bMyViewSafetySelectFields = true;
      Ui.requestUpdate();
    }
    else if($.bMyViewSafetySelectFields) {
      $.bMyViewSafetyShowSettings = true;
      $.bMyViewSafetySelectFields = false;
      Ui.requestUpdate();
    }
    else if($.oMyActivity == null) {
      Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionStart),
                  new MyMenuGenericConfirmDelegate(:contextActivity, :actionStart, false),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MyMenuGeneric(:menuActivity),
                  new MyMenuGenericDelegate(:menuActivity),
                  Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewSafetyDelegate.onBack()");
    if($.bMyViewSafetyShowSettings or $.bMyViewSafetySelectFields) {
      $.bMyViewSafetyShowSettings = false;
      $.bMyViewSafetySelectFields = false;
      Ui.requestUpdate();
      return true;
    }
    else if($.oMyActivity != null) {
      if($.oMySettings.bGeneralLapKey) {
        ($.oMyActivity as MyActivity).addLap();
      }
      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewSafetyDelegate.onPreviousPage()");
    if($.bMyViewSafetySelectFields) {
      $.iMyViewSafetyFieldTopLeft = ($.iMyViewSafetyFieldTopLeft + 1) % 3;
      Ui.requestUpdate();
    }
    else if(!$.bMyViewSafetyShowSettings) {
      Ui.switchToView(new MyViewGeneral(),
                      new MyViewGeneralDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewSafetyDelegate.onNextPage()");
    if($.bMyViewSafetySelectFields) {
      $.iMyViewSafetyFieldBottomRight = ($.iMyViewSafetyFieldBottomRight + 1) % 2;
      Ui.requestUpdate();
    }
    else if(!$.bMyViewSafetyShowSettings) {
      Ui.switchToView(new MyViewRateOfTurn(),
                      new MyViewRateOfTurnDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

}
