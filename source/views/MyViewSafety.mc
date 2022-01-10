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
var bMyViewSafetyShowSettings = false;
var bMyViewSafetySelectFields = false;
var iMyViewSafetyFieldTopLeft = 0;
var iMyViewSafetyFieldBottomRight = 0;

class MyViewSafety extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShowSettings;
  private var bSelectFields;
  private var iFieldTopLeft;
  private var iFieldBottomRight;
  private var bProcessingDecision;

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
  private var sValueHeightInvalid;

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
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();

    // Layout-specific initialization
    self.initLayout();

    // Display mode
    // ... internal
    self.bShowSettings = false;
    self.bSelectFields = false;
    self.iFieldTopLeft = 0;
    self.iFieldBottomRight = 0;
    self.bProcessingDecision = false;
  }

  function onLayout(_oDC) {
    if(!MyViewGlobal.onLayout(_oDC)) {
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
    //Sys.println("DEBUG: MyViewSafety.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... strings
    self.sTitle = Ui.loadResource(Rez.Strings.titleViewSafety);
    self.sValueHeightInvalid = Ui.loadResource(Rez.Strings.valueHeightInvalid);

    // Unmute tones
    App.getApp().unmuteTones(MyApp.TONES_SAFETY);

    // Internal state
    self.bShowSettings = !$.bMyViewSafetyShowSettings;  // ... force adaptLayout()
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyViewSafety.onUpdate()");

    // Update layout
    if(!$.bMyViewSafetyShowSettings) {
      self.updateLayoutSafety();
    }
    else {
      self.updateLayoutSettings();
    }
    View.onUpdate(_oDC);

    // Draw buttons
    if($.bMyViewSafetySelectFields) {
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
    if(!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings
       and ($.oMySettings.iSafetyHeadingBug == 2 or ($.oMySettings.iSafetyHeadingBug == 1 and $.oMyProcessing.bDecision))
       and $.oMyProcessing.iAccuracy >= Pos.QUALITY_LAST_KNOWN
       and $.oMyProcessing.fBearingToDestination != null
       and $.oMyProcessing.fHeading != null) {
      self.drawHeadingBug(_oDC);
    }

    // Done
    return true;
  }

  function adaptLayoutSafety() {
    //Sys.println("DEBUG: MyViewSafety.adaptLayoutSafety()");

    // Set colors (value-independent), labels and units
    // ... destination (name) / elevation at destination / bearing to destination
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldTopLeft == 2) {  // ... bearing to destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelBearingToDestination));
      View.findDrawableById("unitTopLeft").setText("[°]");
    }
    else if($.iMyViewSafetyFieldTopLeft == 1) {  // ... elevation at destination
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
      View.findDrawableById("unitTopLeft").setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    }
    else {  // ... destination (name)
      View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
      View.findDrawableById("unitTopLeft").setText(MY_NOVALUE_BLANK);
    }
    // ... distance to destination
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelDistanceToDestination));
    View.findDrawableById("unitTopRight").setText(Lang.format("[$1$]", [$.oMySettings.sUnitDistance]));
    // ... altitude
    self.oRezLabelLeft.setText(Ui.loadResource(Rez.Strings.labelAltitude));
    self.oRezUnitLeft.setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... finesse
    self.oRezLabelCenter.setText(Ui.loadResource(Rez.Strings.labelFinesse));
    // ... height at destination
    self.oRezLabelRight.setText(Ui.loadResource(Rez.Strings.labelHeightAtDestination));
    self.oRezUnitRight.setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... vertical speed
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed));
    View.findDrawableById("unitBottomLeft").setText(Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]));
    // ... ground speed / speed-to(wards)-destination
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelSpeedToDestination));
    }
    else {  // ... ground speed
      View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelGroundSpeed));
    }
    View.findDrawableById("unitBottomRight").setText(Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]));
  }

  function updateLayoutSafety() {
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
      self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.oRezValueTopLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezValueTopRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueTopRight.setText($.MY_NOVALUE_LEN3);
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      self.oRezLabelLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezUnitLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueLeft.setText($.MY_NOVALUE_LEN3);
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      self.oRezLabelCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezValueCenter.setText($.MY_NOVALUE_LEN2);
      self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GRAY);
      self.oRezLabelRight.setColor(Gfx.COLOR_LT_GRAY);
      self.oRezUnitRight.setColor(Gfx.COLOR_LT_GRAY);
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

    // ... destination (name) / elevation at destination / bearing to destination
    self.oRezValueTopLeft.setColor(Gfx.COLOR_BLUE);
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldTopLeft == 2) {  // ... bearing to destination
      if($.oMyProcessing.bDecision and $.oMyProcessing.bGrace) {
        self.oRezValueTopLeft.setColor(Gfx.COLOR_PURPLE);
      }
      if($.oMyProcessing.fBearingToDestination != null) {
        //fValue = (($.oMyProcessing.fBearingToDestination * 180.0f/Math.PI).toNumber()) % 360;
        fValue = (($.oMyProcessing.fBearingToDestination * 57.2957795131f).toNumber()) % 360;
        sValue = fValue.format("%d");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else if($.iMyViewSafetyFieldTopLeft == 1) {  // ... elevation at destination
      if($.oMyProcessing.fDestinationElevation != null) {
        fValue = $.oMyProcessing.fDestinationElevation * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else {  // ... destination (name)
      if($.oMyProcessing.sDestinationName != null) {
        sValue = $.oMyProcessing.sDestinationName;
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    self.oRezValueTopLeft.setText(sValue);

    // ... distance to destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_BLUE);
    if($.oMyProcessing.fDistanceToDestination != null) {
      fValue = $.oMyProcessing.fDistanceToDestination * $.oMySettings.fUnitDistanceCoefficient;
      sValue = fValue.format("%.1f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueTopRight.setText(sValue);

    // ... altitude
    self.oRezLabelLeft.setColor(self.iColorText);
    self.oRezUnitLeft.setColor(self.iColorText);
    self.oRezValueLeft.setColor(self.iColorText);
    if($.oMyProcessing.fAltitude != null) {
      if(!$.oMyProcessing.bSafetyStateful) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      }
      else if($.oMyProcessing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_RED);
      }
      else if($.oMyProcessing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_ORANGE);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GREEN);
      }
      fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_DK_GRAY);
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueLeft.setText(sValue);

    // ... finesse
    self.oRezLabelCenter.setColor(self.iColorText);
    self.oRezValueCenter.setColor(self.iColorText);
    if($.oMyProcessing.fFinesse != null) {
      if($.oMyProcessing.bAscent) {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GREEN);
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          self.oRezValueCenter.setColor(Gfx.COLOR_DK_GRAY);
        }
      }
      else if($.oMyProcessing.fFinesse <= $.oMySettings.iSafetyFinesse) {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_RED);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_ORANGE);
      }
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      self.oRezDrawableGlobal.setColorAlertCenter(Gfx.COLOR_DK_GRAY);
      sValue = $.MY_NOVALUE_LEN2;
    }
    self.oRezValueCenter.setText(sValue);

    // ... height at destination
    self.oRezLabelRight.setColor(self.iColorText);
    self.oRezUnitRight.setColor(self.iColorText);
    self.oRezValueRight.setColor(self.iColorText);
    if($.oMyProcessing.fHeightAtDestination != null) {
      if($.oMyProcessing.bAltitudeCritical) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_RED);
      }
      else if($.oMyProcessing.bAltitudeWarning) {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_ORANGE);
      }
      else {
        self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GREEN);
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
      self.oRezDrawableGlobal.setColorAlertRight(Gfx.COLOR_DK_GRAY);
      sValue = $.MY_NOVALUE_LEN3;
    }
    self.oRezValueRight.setText(sValue);

    // ... variometer
    self.oRezValueBottomLeft.setColor(self.iColorText);
    if($.oMyProcessing.fVariometer_filtered != null) {
      fValue = $.oMyProcessing.fVariometer_filtered * $.oMySettings.fUnitVerticalSpeedCoefficient;
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

    // ... ground speed / speed-to(wards)-destination
    self.oRezValueBottomRight.setColor(self.iColorText);
    if((!$.bMyViewSafetySelectFields and !$.bMyViewSafetyShowSettings and $.oMyProcessing.bDecision)
       or $.iMyViewSafetyFieldBottomRight == 1) {  // ... speed-to(wards)-destination
      if($.oMyProcessing.fSpeedToDestination != null) {
        fValue = $.oMyProcessing.fSpeedToDestination * $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%+.0f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            self.oRezValueBottomRight.setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.5f) {
            self.oRezValueBottomRight.setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    else {  // ... ground speed
      if($.oMyProcessing.fGroundSpeed_filtered != null) {
        fValue = $.oMyProcessing.fGroundSpeed_filtered * $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
    }
    self.oRezValueBottomRight.setText(sValue);
  }

  function drawHeadingBug(_oDC) {
    // Heading
    var fBearingRelative = $.oMyProcessing.fBearingToDestination - $.oMyProcessing.fHeading;
    // ... bug
    var iColor = ($.oMyProcessing.bDecision and $.oMyProcessing.bGrace) ? Gfx.COLOR_PURPLE : Gfx.COLOR_BLUE;
    var aPoints =
      [[self.fLayoutCenter+self.fLayoutBugR1*Math.sin(fBearingRelative), self.fLayoutCenter-self.fLayoutBugR1*Math.cos(fBearingRelative)],
       [self.fLayoutCenter+self.fLayoutBugR2*Math.sin(fBearingRelative-0.125f), self.fLayoutCenter-self.fLayoutBugR2*Math.cos(fBearingRelative-0.125f)],
       [self.fLayoutCenter+self.fLayoutBugR2*Math.sin(fBearingRelative+0.125f), self.fLayoutCenter-self.fLayoutBugR2*Math.cos(fBearingRelative+0.125f)]];
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
      [[self.fLayoutCenter+self.fLayoutBugR1*Math.sin(fBearingRelative), self.fLayoutCenter-self.fLayoutBugR1*Math.cos(fBearingRelative)],
       [self.fLayoutCenter+self.fLayoutBugR3*Math.sin(fBearingRelative-0.035f), self.fLayoutCenter-self.fLayoutBugR3*Math.cos(fBearingRelative-0.035f)],
       [self.fLayoutCenter+self.fLayoutBugR3*Math.sin(fBearingRelative+0.035f), self.fLayoutCenter-self.fLayoutBugR3*Math.cos(fBearingRelative+0.035f)]];
    _oDC.setColor(iColor, iColor);
    _oDC.fillPolygon(aPoints);
  }

  function adaptLayoutSettings() {
    //Sys.println("DEBUG: MyViewSafety.adaptLayoutSettings()");

    // Set colors (value-independent), labels and units
    // ... fields background
    self.oRezDrawableGlobal.setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    // ... destination (name)
    self.oRezValueTopLeft.setColor(Gfx.COLOR_BLUE);
    View.findDrawableById("labelTopLeft").setText(Ui.loadResource(Rez.Strings.labelDestination));
    View.findDrawableById("unitTopLeft").setText(MY_NOVALUE_BLANK);
    // ... elevation at destination
    self.oRezValueTopRight.setColor(Gfx.COLOR_BLUE);
    View.findDrawableById("labelTopRight").setText(Ui.loadResource(Rez.Strings.labelElevationAtDestination));
    View.findDrawableById("unitTopRight").setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... warning height
    self.oRezDrawableGlobal.setColorAlertLeft(Gfx.COLOR_ORANGE);
    self.oRezLabelLeft.setColor(self.iColorText);
    self.oRezLabelLeft.setText(Ui.loadResource(Rez.Strings.labelHeightWarning));
    self.oRezUnitLeft.setColor(self.iColorText);
    self.oRezUnitLeft.setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
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
    self.oRezUnitRight.setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    self.oRezValueRight.setColor(self.iColorText);
    // ... decision height
    self.oRezValueBottomLeft.setColor(self.iColorText);
    View.findDrawableById("labelBottomLeft").setText(Ui.loadResource(Rez.Strings.labelHeightDecision));
    View.findDrawableById("unitBottomLeft").setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... reference height
    self.oRezValueBottomRight.setColor(self.iColorText);
    View.findDrawableById("labelBottomRight").setText(Ui.loadResource(Rez.Strings.labelHeightReference));
    View.findDrawableById("unitBottomRight").setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... application name
    self.oRezValueFooter.setColor(Gfx.COLOR_DK_GRAY);
  }

  function updateLayoutSettings() {
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
    if($.oMyProcessing.sDestinationName != null) {
      self.oRezValueTopLeft.setText($.oMyProcessing.sDestinationName);
    }
    else {
      self.oRezValueTopLeft.setText($.MY_NOVALUE_LEN4);
    }
    // ... elevation at destination
    if($.oMyProcessing.fDestinationElevation != null) {
      fValue = $.oMyProcessing.fDestinationElevation * $.oMySettings.fUnitElevationCoefficient;
      self.oRezValueTopRight.setText(fValue.format("%.0f"));
    }
    else {
      self.oRezValueTopRight.setText($.MY_NOVALUE_LEN3);
    }
    // ... warning height
    fValue = $.oMySettings.fSafetyHeightWarning * $.oMySettings.fUnitElevationCoefficient;
    self.oRezValueLeft.setText(fValue.format("%.0f"));
    // ... reference finesse
    oRezValueCenter.setText($.oMySettings.iSafetyFinesse.format("%d"));
    // ... critical height
    fValue = $.oMySettings.fSafetyHeightCritical * $.oMySettings.fUnitElevationCoefficient;
    self.oRezValueRight.setText(fValue.format("%.0f"));
    // ... decision height
    fValue = $.oMySettings.fSafetyHeightDecision * $.oMySettings.fUnitElevationCoefficient;
    self.oRezValueBottomLeft.setText(fValue.format("%.0f"));
    // ... reference height
    fValue = $.oMySettings.fSafetyHeightReference * $.oMySettings.fUnitElevationCoefficient;
    self.oRezValueBottomRight.setText(fValue.format("%.0f"));
    // ... application name
    self.oRezValueFooter.setText(self.sTitle);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewSafety.onHide()");
    MyViewGlobal.onHide();

    // Internal state
    $.bMyViewSafetyShowSettings = false;
    $.bMyViewSafetySelectFields = false;

    // Mute tones
    App.getApp().muteTones();

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
        $.oMyActivity.addLap();
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
