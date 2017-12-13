// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017 Cedric Dufour <http://cedric.dufour.name>
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
using Toybox.Attention as Attn;
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var GSK_ViewVarioplot_PanZoom = 0;
var GSK_ViewVarioplot_OffsetX = 0;
var GSK_ViewVarioplot_OffsetY = 0;

class ViewVarioplot extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow;
  private var iPanZoom;

  // Resources
  // ... drawable
  private var oRezDrawableHeader;
  // ... header
  private var oRezValueBatteryLevel;
  private var oRezValueActivityStatus;
  // ... footer
  private var oRezValueTime;
  // ... buttons
  private var oRezButtonKeyUp;
  private var oRezButtonKeyDown;
  // ... fonts
  private var oRezFontPlot;
  // ... string
  private var sValueActivityStandby;
  private var sValueActivityRecording;
  private var sValueActivityPaused;

  // Screen center coordinates
  private var iCenterX;
  private var iCenterY;

  // Color scale
  private var aiScale;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();

    // Display mode
    // ... internal
    self.bShow = false;
    self.iPanZoom = 0;
  }

  function onLayout(_oDC) {
    // Layout
    View.setLayout(Rez.Layouts.LayoutVarioplot(_oDC));

    // Load resources
    // ... drawable
    self.oRezDrawableHeader = View.findDrawableById("DrawableHeader");
    // ... header
    self.oRezValueBatteryLevel = View.findDrawableById("valueBatteryLevel");
    self.oRezValueActivityStatus = View.findDrawableById("valueActivityStatus");
    // ... footer
    self.oRezValueTime = View.findDrawableById("valueTime");

    // Screen center coordinates
    self.iCenterX = (_oDC.getWidth()/2).toNumber();
    self.iCenterY = (_oDC.getHeight()/2).toNumber();

    // Done
    return true;
  }

  function onShow() {
    //Sys.println("DEBUG: ViewVarioplot.onShow()");

    // Load resources
    // ... fonts
    self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlot);
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby);
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording);
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused);

    // Reload settings (which may have been changed by user)
    App.getApp().loadSettings();

    // Set colors
    var iColorText = $.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    // ... background
    self.oRezDrawableHeader.setColorBackground($.GSK_Settings.iBackgroundColor);
    // ... battery level
    self.oRezValueBatteryLevel.setColor(iColorText);
    // ... time
    self.oRezValueTime.setColor(iColorText);

    // Color scale
    switch($.GSK_Settings.iVariometerRange) {
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
    App.getApp().unmuteTones(GskApp.TONES_SAFETY | GskApp.TONES_VARIOMETER);

    // Done
    self.bShow = true;
    $.GSK_CurrentView = self;
    return true;
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: ViewVarioplot.onUpdate()");

    // Update layout
    self.updateLayout();
    View.onUpdate(_oDC);
    self.drawPlot(_oDC);
    self.drawValues(_oDC);

    // Draw buttons
    if($.GSK_ViewVarioplot_PanZoom) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null
         or self.iPanZoom != $.GSK_ViewVarioplot_PanZoom) {
        if($.GSK_ViewVarioplot_PanZoom == 1) {  // ... zoom in/out
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonPlus();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonMinus();
        }
        else if($.GSK_ViewVarioplot_PanZoom == 2) {  // ... pan up/down
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonUp();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonDown();
        }
        else if($.GSK_ViewVarioplot_PanZoom == 3) {  // ... pan left/right
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonLeft();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonRight();
        }
        self.iPanZoom = $.GSK_ViewVarioplot_PanZoom;
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

  function onHide() {
    //Sys.println("DEBUG: ViewVarioplot.onHide()");
    $.GSK_CurrentView = null;
    self.bShow = false;
    $.GSK_ViewVarioplot_PanZoom = 0;
    $.GSK_ViewVarioplot_OffsetX = 0;
    $.GSK_ViewVarioplot_OffsetY = 0;

    // Mute tones
    App.getApp().muteTones();

    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
    // ... fonts
    self.oRezFontPlot = null;
    // ... strings
    self.sValueActivityStandby = null;
    self.sValueActivityRecording = null;
    self.sValueActivityPaused = null;
  }


  //
  // FUNCTIONS: self
  //

  function updateUi() {
    //Sys.println("DEBUG: ViewVarioplot.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout() {
    //Sys.println("DEBUG: ViewVarioplot.updateLayout()");

    // Set header/footer values
    var sValue;

    // ... position accuracy
    self.oRezDrawableHeader.setPositionAccuracy($.GSK_Processing.iAccuracy);

    // ... battery level
    self.oRezValueBatteryLevel.setText(Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]));

    // ... activity status
    if($.GSK_ActivitySession == null) {  // ... stand-by
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_LT_GRAY);
      sValue = self.sValueActivityStandby;
    }
    else if($.GSK_ActivitySession.isRecording()) {  // ... recording
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_RED);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      self.oRezValueActivityStatus.setColor(Gfx.COLOR_YELLOW);
      sValue = self.sValueActivityPaused;
    }
    self.oRezValueActivityStatus.setText(sValue);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.GSK_Settings.bTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    self.oRezValueTime.setText(Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.GSK_Settings.sUnitTime]));
  }

  (:layout_240x240)
  function clipPlot(_oDC) {
    _oDC.setClip(0, 31, 240, 178);
  }

  function drawPlot(_oDC) {
    //Sys.println("DEBUG: ViewVarioplot.drawPlot()");
    var iNowEpoch = Time.now().value();

    // Draw plot
    _oDC.setPenWidth(3);
    var iPlotIndex = $.GSK_Processing.iPlotIndex;
    var iPlotRange = $.GSK_Settings.iPlotRange * 60;
    if(iPlotIndex < 0) {
      // No data
      return;
    }

    // ... end (center) location
    var iEndIndex = iPlotIndex;
    var iEndEpoch = $.GSK_Processing.aiPlotEpoch[iEndIndex];
    if(iEndEpoch == null or iNowEpoch-iEndEpoch > iPlotRange) {
      // No data or data too old
      return;
    }
    var iEndLatitude = $.GSK_Processing.aiPlotLatitude[iEndIndex];
    var iEndLongitude = $.GSK_Processing.aiPlotLongitude[iEndIndex];

    // ... start location
    var iStartEpoch = iNowEpoch-iPlotRange;

    // ... plot
    self.clipPlot(_oDC);
    var iCurrentIndex = (iEndIndex-iPlotRange+1+GskProcessing.PLOTBUFFER_SIZE) % GskProcessing.PLOTBUFFER_SIZE;
    //var fZoomX = $.GSK_Settings.fPlotZoom * Math.cos(iEndLatitude / 1555200000.0d*Math.PI);
    var fZoomX = $.GSK_Settings.fPlotZoom * Math.cos(iEndLatitude / 495035534.9930312523f);
    var fZoomY = $.GSK_Settings.fPlotZoom;
    var iMaxDeltaEpoch = $.GSK_Settings.iTimeConstant+1;
    var iLastEpoch = iEndEpoch;  //
    var iLastX = 0;
    var iLastY = 0;
    var iLastColor = 0;
    var bDraw = false;
    for(var i=iPlotRange; i>0; i--) {
      var iCurrentEpoch = $.GSK_Processing.aiPlotEpoch[iCurrentIndex];
      if(iCurrentEpoch != null and iCurrentEpoch >= iStartEpoch) {
        if(iCurrentEpoch-iLastEpoch <= iMaxDeltaEpoch) {
          var iCurrentX = self.iCenterX+$.GSK_ViewVarioplot_OffsetX+(($.GSK_Processing.aiPlotLongitude[iCurrentIndex]-iEndLongitude)*fZoomX).toNumber();
          var iCurrentY = self.iCenterY+$.GSK_ViewVarioplot_OffsetY-(($.GSK_Processing.aiPlotLatitude[iCurrentIndex]-iEndLatitude)*fZoomY).toNumber();
          var iCurrentVariometer = $.GSK_Processing.aiPlotVariometer[iCurrentIndex];
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
      iCurrentIndex = (iCurrentIndex+1) % GskProcessing.PLOTBUFFER_SIZE;
    }
    _oDC.clearClip();
  }

  (:layout_240x240)
  function drawValues(_oDC) {
    self.drawValues_positioned(_oDC, 40, 200, 30, 193);
  }

  function drawValues_positioned(_oDC, _iXleft, _iXright, _iYtop, _iYbottom) {
    //Sys.println("DEBUG: ViewVarioplot.drawValues()");

    // Draw position values
    var fValue;
    var sValue;
    _oDC.setColor($.GSK_Settings.iBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);  // DUMMY

    // ... altitude
    if($.GSK_Processing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_Processing.fAltitude != null) {
      fValue = $.GSK_Processing.fAltitude * $.GSK_Settings.fUnitElevationConstant;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(_iXleft, _iYtop, self.oRezFontPlot, Lang.format("$1$ $2$", [sValue, $.GSK_Settings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... variometer
    if($.GSK_Processing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_Processing.fVariometer != null) {
      fValue = $.GSK_Processing.fVariometer * $.GSK_Settings.fUnitVerticalSpeedConstant;
      if($.GSK_Settings.fUnitVerticalSpeedConstant < 100.0f) {
        sValue = fValue.format("%+.01f");
      }
      else {
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(_iXright, _iYtop, self.oRezFontPlot, Lang.format("$1$ $2$", [sValue, $.GSK_Settings.sUnitVerticalSpeed]), Gfx.TEXT_JUSTIFY_RIGHT);

    // ... ground speed
    if($.GSK_Processing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and $.GSK_Processing.fGroundSpeed != null) {
      fValue = $.GSK_Processing.fGroundSpeed * $.GSK_Settings.fUnitHorizontalSpeedConstant;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN3;
    }
    _oDC.drawText(_iXleft, _iYbottom, self.oRezFontPlot, Lang.format("$1$ $2$", [sValue, $.GSK_Settings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... finesse
    if($.GSK_Processing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.GSK_Processing.bAscent and $.GSK_Processing.fFinesse != null) {
      fValue = $.GSK_Processing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.GSK_NOVALUE_LEN2;
    }
    _oDC.drawText(_iXright, _iYbottom, self.oRezFontPlot, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  }

}

class ViewDelegateVarioplot extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: ViewDelegateVarioplot.onMenu()");
    Ui.pushView(new Rez.Menus.menuVarioplot(), new MenuDelegateVarioplot(), Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: ViewDelegateVarioplot.onSelect()");
    if($.GSK_ViewVarioplot_PanZoom) {
      $.GSK_ViewVarioplot_PanZoom = ($.GSK_ViewVarioplot_PanZoom+1) % 4;
      if($.GSK_ViewVarioplot_PanZoom == 0) {
        $.GSK_ViewVarioplot_PanZoom = 1;
      }
      Ui.requestUpdate();
    }
    else if($.GSK_ActivitySession == null) {
      Ui.pushView(new MenuActivityStart(), new MenuDelegateActivityStart(), Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new Rez.Menus.menuActivity(), new MenuDelegateActivity(), Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: ViewDelegateVarioplot.onBack()");
    if($.GSK_ViewVarioplot_PanZoom) {  // ... cancel pan/zoom
      $.GSK_ViewVarioplot_PanZoom = 0;
      $.GSK_ViewVarioplot_OffsetX = 0;
      $.GSK_ViewVarioplot_OffsetY = 0;
      Ui.requestUpdate();
      return true;
    }
    else if($.GSK_Settings.bLapKey and $.GSK_ActivitySession != null) {
      if($.GSK_ActivitySession.isRecording()) {
        $.GSK_ActivitySession.addLap();
        if(Attn has :playTone) {
          Attn.playTone(Attn.TONE_LAP);
        }
      }
      else {
        Ui.pushView(new Rez.Menus.menuActivity(), new MenuDelegateActivity(), Ui.SLIDE_IMMEDIATE);
      }
      return true;
    }
    return false;
  }

  function onKey(oEvent) {
    //Sys.println("DEBUG: ViewDelegateVarioplot.onKey()");
    var iKey = oEvent.getKey();
    if(iKey == Ui.KEY_UP) {
      if($.GSK_ViewVarioplot_PanZoom == 0) {
        Ui.switchToView(new ViewRateOfTurn(), new ViewDelegateRateOfTurn(), Ui.SLIDE_IMMEDIATE);
      }
      else if($.GSK_ViewVarioplot_PanZoom == 1) {  // ... zoom in
        var fPlotZoom_previous = $.GSK_Settings.fPlotZoom;
        $.GSK_Settings.setPlotZoom($.GSK_Settings.iPlotZoom+1);
        var fPlotZoom_ratio = $.GSK_Settings.fPlotZoom/fPlotZoom_previous;
        $.GSK_ViewVarioplot_OffsetY = ($.GSK_ViewVarioplot_OffsetY*fPlotZoom_ratio).toNumber();
        $.GSK_ViewVarioplot_OffsetX = ($.GSK_ViewVarioplot_OffsetX*fPlotZoom_ratio).toNumber();
        App.getApp().setProperty("userPlotZoom", $.GSK_Settings.iPlotZoom);
        Ui.requestUpdate();
      }
      else if($.GSK_ViewVarioplot_PanZoom == 2) {  // ... pan up
        $.GSK_ViewVarioplot_OffsetY += 10;
        Ui.requestUpdate();
      }
      else if($.GSK_ViewVarioplot_PanZoom == 3) {  // ... pan left
        $.GSK_ViewVarioplot_OffsetX += 10;
        Ui.requestUpdate();
      }
      return true;
    }
    if(iKey == Ui.KEY_DOWN) {
      if($.GSK_ViewVarioplot_PanZoom == 0) {
        Ui.switchToView(new ViewVariometer(), new ViewDelegateVariometer(), Ui.SLIDE_IMMEDIATE);
      }
      else if($.GSK_ViewVarioplot_PanZoom == 1) {  // ... zoom out
        var fPlotZoom_previous = $.GSK_Settings.fPlotZoom;
        $.GSK_Settings.setPlotZoom($.GSK_Settings.iPlotZoom-1);
        var fPlotZoom_ratio = $.GSK_Settings.fPlotZoom/fPlotZoom_previous;
        $.GSK_ViewVarioplot_OffsetY = ($.GSK_ViewVarioplot_OffsetY*fPlotZoom_ratio).toNumber();
        $.GSK_ViewVarioplot_OffsetX = ($.GSK_ViewVarioplot_OffsetX*fPlotZoom_ratio).toNumber();
        App.getApp().setProperty("userPlotZoom", $.GSK_Settings.iPlotZoom);
        Ui.requestUpdate();
      }
      else if($.GSK_ViewVarioplot_PanZoom == 2) {  // ... pan down
        $.GSK_ViewVarioplot_OffsetY -= 10;
        Ui.requestUpdate();
      }
      else if($.GSK_ViewVarioplot_PanZoom == 3) {  // ... pan right
        $.GSK_ViewVarioplot_OffsetX -= 10;
        Ui.requestUpdate();
      }
      return true;
    }
    return false;
  }

}
