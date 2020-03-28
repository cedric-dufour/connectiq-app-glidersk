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
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var GSK_ViewVarioplot_iPanZoom = 0;
var GSK_ViewVarioplot_iOffsetX = 0;
var GSK_ViewVarioplot_iOffsetY = 0;

class GSK_ViewVarioplot extends GSK_ViewHeader {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;
  private var iPanZoom;

  // Resources
  // ... buttons
  private var oRezButtonKeyUp;
  private var oRezButtonKeyDown;
  // ... fonts
  private var oRezFontPlot;

  // Layout-specific
  private var iLayoutCenter;
  private var iLayoutClipY;
  private var iLayoutClipW;
  private var iLayoutClipH;
  private var iLayoutValueXleft;
  private var iLayoutValueXright;
  private var iLayoutValueYtop;
  private var iLayoutValueYbottom;

  // Color scale
  private var aiScale;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_240x240)
  function initLayout() {
    self.iLayoutCenter = 120;
    self.iLayoutClipY = 31;
    self.iLayoutClipW = 240;
    self.iLayoutClipH = 178;
    self.iLayoutValueXleft = 40;
    self.iLayoutValueXright = 200;
    self.iLayoutValueYtop = 30;
    self.iLayoutValueYbottom = 193;
  }

  (:layout_260x260)
  function initLayout() {
    self.iLayoutCenter = 130;
    self.iLayoutClipY = 34;
    self.iLayoutClipW = 260;
    self.iLayoutClipH = 192;
    self.iLayoutValueXleft = 43;
    self.iLayoutValueXright = 217;
    self.iLayoutValueYtop = 33;
    self.iLayoutValueYbottom = 209;
  }

  (:layout_280x280)
  function initLayout() {
    self.iLayoutCenter = 140;
    self.iLayoutClipY = 36;
    self.iLayoutClipW = 280;
    self.iLayoutClipH = 208;
    self.iLayoutValueXleft = 47;
    self.iLayoutValueXright = 233;
    self.iLayoutValueYtop = 35;
    self.iLayoutValueYbottom = 225;
  }


  //
  // FUNCTIONS: GSK_ViewHeader (override/implement)
  //

  function initialize() {
    GSK_ViewHeader.initialize();

    // Layout-specific initialization
    self.initLayout();

    // Display mode
    // ... internal
    self.iPanZoom = 0;
  }

  function onLayout(_oDC) {
    //Sys.println("DEBUG: GSK_ViewVarioplot.onLayout()");
    if(!GSK_ViewHeader.onLayout(_oDC)) {
      return false;
    }

    // Done
    return true;
  }

  function prepare() {
    //Sys.println("DEBUG: GSK_ViewVarioplot.prepare()");
    GSK_ViewHeader.prepare();

    // Load resources
    // ... fonts
    self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlot);

    // Color scale
    switch($.GSK_oSettings.iVariometerRange) {
    default:
    case 0:
      self.aiScale = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000];
      break;
    case 1:
      self.aiScale = [-6000, -4000, -2000, -100, 100, 2000, 4000, 6000];
      break;
    case 2:
      self.aiScale = [-9000, -6000, -3000, -150, 150, 3000, 6000, 9000];
      break;
    }

    // Unmute tones
    App.getApp().unmuteTones(GSK_App.TONES_SAFETY | GSK_App.TONES_VARIOMETER);
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: GSK_ViewVarioplot.onUpdate()");

    // Update layout
    GSK_ViewHeader.updateLayout(true);
    View.onUpdate(_oDC);
    self.drawPlot(_oDC);
    self.drawValues(_oDC);

    // Draw buttons
    if($.GSK_ViewVarioplot_iPanZoom) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null
         or self.iPanZoom != $.GSK_ViewVarioplot_iPanZoom) {
        if($.GSK_ViewVarioplot_iPanZoom == 1) {  // ... zoom in/out
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonPlus();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonMinus();
        }
        else if($.GSK_ViewVarioplot_iPanZoom == 2) {  // ... pan up/down
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonUp();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonDown();
        }
        else if($.GSK_ViewVarioplot_iPanZoom == 3) {  // ... pan left/right
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonLeft();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonRight();
        }
        self.iPanZoom = $.GSK_ViewVarioplot_iPanZoom;
      }
      self.oRezButtonKeyUp.draw(_oDC);
      self.oRezButtonKeyDown.draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }

    // Done
    return true;
  }

  function drawPlot(_oDC) {
    //Sys.println("DEBUG: GSK_ViewVarioplot.drawPlot()");
    var iNowEpoch = Time.now().value();

    // Draw plot
    _oDC.setPenWidth(3);
    var iPlotIndex = $.GSK_oProcessing.iPlotIndex;
    var iVariometerPlotRange = $.GSK_oSettings.iVariometerPlotRange * 60;
    if(iPlotIndex < 0) {
      // No data
      return;
    }

    // ... end (center) location
    var iEndIndex = iPlotIndex;
    var iEndEpoch = $.GSK_oProcessing.aiPlotEpoch[iEndIndex];
    if(iEndEpoch == null or iNowEpoch-iEndEpoch > iVariometerPlotRange) {
      // No data or data too old
      return;
    }
    var iEndLatitude = $.GSK_oProcessing.aiPlotLatitude[iEndIndex];
    var iEndLongitude = $.GSK_oProcessing.aiPlotLongitude[iEndIndex];

    // ... start location
    var iStartEpoch = iNowEpoch-iVariometerPlotRange;

    // ... plot
    _oDC.setClip(0, self.iLayoutClipY, self.iLayoutClipW, self.iLayoutClipH);
    var iCurrentIndex = (iEndIndex-iVariometerPlotRange+1+GSK_Processing.PLOTBUFFER_SIZE) % GSK_Processing.PLOTBUFFER_SIZE;
    var fZoomX = $.GSK_oSettings.fVariometerPlotZoom * Math.cos(iEndLatitude / 495035534.9930312523f);
    var fZoomY = $.GSK_oSettings.fVariometerPlotZoom;
    var iMaxDeltaEpoch = $.GSK_oSettings.iGeneralTimeConstant+1;
    var iLastEpoch = iEndEpoch;  //
    var iLastX = 0;
    var iLastY = 0;
    var iLastColor = 0;
    var bDraw = false;
    for(var i=iVariometerPlotRange; i>0; i--) {
      var iCurrentEpoch = $.GSK_oProcessing.aiPlotEpoch[iCurrentIndex];
      if(iCurrentEpoch != null and iCurrentEpoch >= iStartEpoch) {
        if(iCurrentEpoch-iLastEpoch <= iMaxDeltaEpoch) {
          var iCurrentX = self.iLayoutCenter+$.GSK_ViewVarioplot_iOffsetX+(($.GSK_oProcessing.aiPlotLongitude[iCurrentIndex]-iEndLongitude)*fZoomX).toNumber();
          var iCurrentY = self.iLayoutCenter+$.GSK_ViewVarioplot_iOffsetY-(($.GSK_oProcessing.aiPlotLatitude[iCurrentIndex]-iEndLatitude)*fZoomY).toNumber();
          var iCurrentVariometer = $.GSK_oProcessing.aiPlotVariometer[iCurrentIndex];
          if(bDraw) {
            var iCurrentColor;
            if(iCurrentVariometer > self.aiScale[7]) {
              iCurrentColor = 0xAAFFAA;
            }
            else if(iCurrentVariometer > self.aiScale[6]) {
              iCurrentColor = 0x00FF00;
            }
            else if(iCurrentVariometer > self.aiScale[5]) {
              iCurrentColor = 0x00AA00;
            }
            else if(iCurrentVariometer > self.aiScale[4]) {
              iCurrentColor = 0x55AA55;
            }
            else if(iCurrentVariometer < self.aiScale[0]) {
              iCurrentColor = 0xFFAAAA;
            }
            else if(iCurrentVariometer < self.aiScale[1]) {
              iCurrentColor = 0xFF0000;
            }
            else if(iCurrentVariometer < self.aiScale[2]) {
              iCurrentColor = 0xAA0000;
            }
            else if(iCurrentVariometer < self.aiScale[3]) {
              iCurrentColor = 0xAA5555;
            }
            else {
              iCurrentColor = 0xAAAAAA;
            }
            if(iCurrentX != iLastX or iCurrentY != iLastY or iCurrentColor != iLastColor) {  // ... better a few comparison than drawLine() for nothing
              _oDC.setColor(iCurrentColor, Gfx.COLOR_TRANSPARENT);
              _oDC.drawLine(iLastX, iLastY, iCurrentX, iCurrentY);
            }
            iLastColor = iCurrentColor;
          }
          else {
            iLastColor = -1;
          }
          iLastX = iCurrentX;
          iLastY = iCurrentY;
          bDraw = true;
        }
        else {
          bDraw = false;
        }
        iLastEpoch = iCurrentEpoch;
      }
      else {
        bDraw = false;
      }
      iCurrentIndex = (iCurrentIndex+1) % GSK_Processing.PLOTBUFFER_SIZE;
    }
    _oDC.clearClip();
  }

  function drawValues(_oDC) {
    //Sys.println("DEBUG: GSK_ViewVarioplot.drawValues()");

    // Draw values
    var fValue;
    var sValue;
    _oDC.setColor($.GSK_oSettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    // ... altitude
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_oProcessing.fAltitude != null) {
      fValue = $.GSK_oProcessing.fAltitude * $.GSK_oSettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop, self.oRezFontPlot, Lang.format("$1$ $2$", [sValue, $.GSK_oSettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... variometer
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_oProcessing.fVariometer != null) {
      fValue = $.GSK_oProcessing.fVariometer * $.GSK_oSettings.fUnitVerticalSpeedCoefficient;
      if($.GSK_oSettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
      }
      else {
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYtop, self.oRezFontPlot, Lang.format("$1$ $2$", [sValue, $.GSK_oSettings.sUnitVerticalSpeed]), Gfx.TEXT_JUSTIFY_RIGHT);

    // ... ground speed
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_oProcessing.fGroundSpeed != null) {
      fValue = $.GSK_oProcessing.fGroundSpeed * $.GSK_oSettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYbottom, self.oRezFontPlot, Lang.format("$1$ $2$", [sValue, $.GSK_oSettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... finesse
    if($.GSK_oProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.GSK_oProcessing.bAscent and $.GSK_oProcessing.fFinesse != null) {
      fValue = $.GSK_oProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYbottom, self.oRezFontPlot, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  }

  function onHide() {
    GSK_ViewHeader.onHide();

    //Sys.println("DEBUG: GSK_ViewVarioplot.onHide()");
    $.GSK_ViewVarioplot_iPanZoom = 0;
    $.GSK_ViewVarioplot_iOffsetX = 0;
    $.GSK_ViewVarioplot_iOffsetY = 0;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
  }

}

class GSK_ViewVarioplotDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: GSK_ViewVarioplotDelegate.onMenu()");
    if($.GSK_ViewVarioplot_iPanZoom) {
      $.GSK_ViewVarioplot_iPanZoom = 0;  // ... cancel pan/zoom
      $.GSK_ViewVarioplot_iOffsetX = 0;
      $.GSK_ViewVarioplot_iOffsetY = 0;
      Ui.pushView(new GSK_MenuGeneric(:menuSettings), new GSK_MenuGenericDelegate(:menuSettings), Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.GSK_ViewVarioplot_iPanZoom = 1;  // ... enter pan/zoom
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: GSK_ViewVarioplotDelegate.onSelect()");
    if($.GSK_ViewVarioplot_iPanZoom) {
      $.GSK_ViewVarioplot_iPanZoom = ($.GSK_ViewVarioplot_iPanZoom+1) % 4;
      if($.GSK_ViewVarioplot_iPanZoom == 0) {
        $.GSK_ViewVarioplot_iPanZoom = 1;
      }
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
    //Sys.println("DEBUG: GSK_ViewVarioplotDelegate.onBack()");
    if($.GSK_ViewVarioplot_iPanZoom) {
      $.GSK_ViewVarioplot_iPanZoom = 0;  // ... cancel pan/zoom
      $.GSK_ViewVarioplot_iOffsetX = 0;
      $.GSK_ViewVarioplot_iOffsetY = 0;
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
    //Sys.println("DEBUG: GSK_ViewVarioplotDelegate.onPreviousPage()");
    if($.GSK_ViewVarioplot_iPanZoom == 0) {
      Ui.switchToView(new GSK_ViewVariometer(), new GSK_ViewVariometerDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if($.GSK_ViewVarioplot_iPanZoom == 1) {  // ... zoom in
      var fPlotZoom_previous = $.GSK_oSettings.fVariometerPlotZoom;
      $.GSK_oSettings.setVariometerPlotZoom($.GSK_oSettings.iVariometerPlotZoom+1);
      var fPlotZoom_ratio = $.GSK_oSettings.fVariometerPlotZoom/fPlotZoom_previous;
      $.GSK_ViewVarioplot_iOffsetY = ($.GSK_ViewVarioplot_iOffsetY*fPlotZoom_ratio).toNumber();
      $.GSK_ViewVarioplot_iOffsetX = ($.GSK_ViewVarioplot_iOffsetX*fPlotZoom_ratio).toNumber();
      App.Properties.setValue("userVariometerPlotZoom", $.GSK_oSettings.iVariometerPlotZoom);
      Ui.requestUpdate();
    }
    else if($.GSK_ViewVarioplot_iPanZoom == 2) {  // ... pan up
      $.GSK_ViewVarioplot_iOffsetY += 10;
      Ui.requestUpdate();
    }
    else if($.GSK_ViewVarioplot_iPanZoom == 3) {  // ... pan left
      $.GSK_ViewVarioplot_iOffsetX += 10;
      Ui.requestUpdate();
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: GSK_ViewVarioplotDelegate.onNextPage()");
    if($.GSK_ViewVarioplot_iPanZoom == 0) {
      Ui.switchToView(new GSK_ViewLog(), new GSK_ViewLogDelegate(), Ui.SLIDE_IMMEDIATE);
    }
    else if($.GSK_ViewVarioplot_iPanZoom == 1) {  // ... zoom out
      var fPlotZoom_previous = $.GSK_oSettings.fVariometerPlotZoom;
      $.GSK_oSettings.setVariometerPlotZoom($.GSK_oSettings.iVariometerPlotZoom-1);
      var fPlotZoom_ratio = $.GSK_oSettings.fVariometerPlotZoom/fPlotZoom_previous;
      $.GSK_ViewVarioplot_iOffsetY = ($.GSK_ViewVarioplot_iOffsetY*fPlotZoom_ratio).toNumber();
      $.GSK_ViewVarioplot_iOffsetX = ($.GSK_ViewVarioplot_iOffsetX*fPlotZoom_ratio).toNumber();
      App.Properties.setValue("userVariometerPlotZoom", $.GSK_oSettings.iVariometerPlotZoom);
      Ui.requestUpdate();
    }
    else if($.GSK_ViewVarioplot_iPanZoom == 2) {  // ... pan down
      $.GSK_ViewVarioplot_iOffsetY -= 10;
      Ui.requestUpdate();
    }
    else if($.GSK_ViewVarioplot_iPanZoom == 3) {  // ... pan right
      $.GSK_ViewVarioplot_iOffsetX -= 10;
      Ui.requestUpdate();
    }
    return true;
  }

}
