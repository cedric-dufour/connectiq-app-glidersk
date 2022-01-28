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
using Toybox.WatchUi as Ui;

class MyPickerGenericSettings extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextVariometer) {
      if(_item == :itemRange) {
        var iVariometerRange = $.oMySettings.loadVariometerRange();
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [format("$1$\n$2$", [(3.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(6.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(9.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerRange) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerRange)]});
      }
      else if(_item == :itemMode) {
        var iVariometerMode = $.oMySettings.loadVariometerMode();
        var oFactory = new PickerFactoryDictionary([0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueVariometerModeAltitude),
                                                    Ui.loadResource(Rez.Strings.valueVariometerModeEnergy)],
                                                   {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerMode) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerMode)]});
      }
      else if(_item == :itemEnergyEfficiency) {
        var iVariometerEnergyEfficiency = $.oMySettings.loadVariometerEnergyEfficiency();
        var oFactory = new PickerFactoryNumber(0, 100, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [%]", [Ui.loadResource(Rez.Strings.titleVariometerEnergyEfficiency)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iVariometerEnergyEfficiency)]});
      }
      else if(_item == :itemPlotRange) {
        var iVariometerPlotRange = $.oMySettings.loadVariometerPlotRange();
        var oFactory = new PickerFactoryNumber(1, 5, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [min]", [Ui.loadResource(Rez.Strings.titleVariometerPlotRange)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iVariometerPlotRange)]});
      }
    }
    else if(_context == :contextSafety) {
      if(_item == :itemFinesse) {
        var iSafetyFinesse = $.oMySettings.loadSafetyFinesse();
        var oFactory = new PickerFactoryNumber(1, 99, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleSafetyFinesse) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iSafetyFinesse)]});
      }
      else if(_item == :itemHeadingBug) {
        var iSafetyHeadingBug = $.oMySettings.loadSafetyHeadingBug();
        var oFactory = new PickerFactoryDictionary([0, 1 ,2],
                                                   [Ui.loadResource(Rez.Strings.valueOff),
                                                    Ui.loadResource(Rez.Strings.valueAuto),
                                                    Ui.loadResource(Rez.Strings.valueOn)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleSafetyHeadingBug) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iSafetyHeadingBug)]});
      }
      else if(_item == :itemGraceDuration) {
        var iSafetyGraceDuration = $.oMySettings.loadSafetyGraceDuration();
        var oFactory = new PickerFactoryDictionary([0, 300, 600, 900, 1200, 1500, 1800, 2700, 3600],
                                                   ["0", "5", "10", "15", "20", "25", "30", "45", "60"],
                                                   null);
        var iIndex = oFactory.indexOfKey(iSafetyGraceDuration);
        if(iIndex < 0) {
          iIndex = 0;
        }
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [min]", [Ui.loadResource(Rez.Strings.titleSafetyGraceDuration)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [iIndex]});
      }
    }
    else if(_context == :contextGeneral) {
      if(_item == :itemTimeConstant) {
        var iGeneralTimeConstant = $.oMySettings.loadGeneralTimeConstant();
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 45, 60],
                                                   ["0", "1", "2", "3", "4", "5", "10", "15", "20", "25", "30", "45", "60"],
                                                   null);
        var iIndex = oFactory.indexOfKey(iGeneralTimeConstant);
        if(iIndex < 0) {
          iIndex = 5;
        }
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [s]", [Ui.loadResource(Rez.Strings.titleGeneralTimeConstant)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [iIndex]});
      }
      else if(_item == :itemDisplayFilter) {
        var iGeneralDisplayFilter = $.oMySettings.loadGeneralDisplayFilter();
        var oFactory = new PickerFactoryDictionary([0, 1, 2],
                                                   [Ui.loadResource(Rez.Strings.valueOff),
                                                    Ui.loadResource(Rez.Strings.valueGeneralDisplayFilterTimeDerived),
                                                    Ui.loadResource(Rez.Strings.valueAll)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$", [Ui.loadResource(Rez.Strings.titleGeneralDisplayFilter)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iGeneralDisplayFilter)]});
      }
      else if(_item == :itemBackgroundColor) {
        var iColor = $.oMySettings.loadGeneralBackgroundColor();
        var oFactory = new PickerFactoryDictionary([Gfx.COLOR_WHITE, Gfx.COLOR_BLACK],
                                                   [Ui.loadResource(Rez.Strings.valueColorWhite),
                                                    Ui.loadResource(Rez.Strings.valueColorBlack)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleGeneralBackgroundColor) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iColor)]});
      }
    }
    else if(_context == :contextUnit) {
      if(_item == :itemDistance) {
        var iUnitDistance = $.oMySettings.loadUnitDistance();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1 ,2],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "km", "sm", "nm"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitDistance) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitDistance)]});
      }
      else if(_item == :itemElevation) {
        var iUnitElevation = $.oMySettings.loadUnitElevation();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "m", "ft"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitElevation) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitElevation)]});
      }
      else if(_item == :itemPressure) {
        var iUnitPressure = $.oMySettings.loadUnitPressure();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "mb", "inHg"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitPressure) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitPressure)]});
      }
      else if(_item == :itemRateOfTurn) {
        var iUnitRateOfTurn = $.oMySettings.loadUnitRateOfTurn();
        var oFactory = new PickerFactoryDictionary([0, 1],
                                                   ["°/s", "rpm"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitRateOfTurn) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitRateOfTurn)]});
      }
      else if(_item == :itemTimeUTC) {
        var bUnitTimeUTC = $.oMySettings.loadUnitTimeUTC();
        var oFactory = new PickerFactoryDictionary([false, true],
                                                   [Ui.loadResource(Rez.Strings.valueUnitTimeLT),
                                                    Ui.loadResource(Rez.Strings.valueUnitTimeUTC)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitTimeUTC) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(bUnitTimeUTC)]});
      }
    }
  }

}

class MyPickerGenericSettingsDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    if(self.context == :contextVariometer) {
      if(self.item == :itemRange) {
        $.oMySettings.saveVariometerRange(_amValues[0] as Number);
      }
      else if(self.item == :itemMode) {
        $.oMySettings.saveVariometerMode(_amValues[0] as Number);
      }
      else if(self.item == :itemEnergyEfficiency) {
        $.oMySettings.saveVariometerEnergyEfficiency(_amValues[0] as Number);
      }
      else if(self.item == :itemPlotRange) {
        $.oMySettings.saveVariometerPlotRange(_amValues[0] as Number);
      }
    }
    else if(self.context == :contextSafety) {
      if(self.item == :itemFinesse) {
        $.oMySettings.saveSafetyFinesse(_amValues[0] as Number);
      }
      else if(self.item == :itemHeadingBug) {
        $.oMySettings.saveSafetyHeadingBug(_amValues[0] as Number);
      }
      else if(self.item == :itemGraceDuration) {
        $.oMySettings.saveSafetyGraceDuration(_amValues[0] as Number);
        // Reset the grace period
        $.oMySettings.load();
        $.oMyProcessing.bGrace = false;
        $.oMyProcessing.iGraceEpoch = -1;
      }
    }
    else if(self.context == :contextGeneral) {
      if(self.item == :itemTimeConstant) {
        $.oMySettings.saveGeneralTimeConstant(_amValues[0] as Number);
      }
      else if(self.item == :itemDisplayFilter) {
        $.oMySettings.saveGeneralDisplayFilter(_amValues[0] as Number);
      }
      if(self.item == :itemBackgroundColor) {
        $.oMySettings.saveGeneralBackgroundColor(_amValues[0] as Number);
      }
    }
    else if(self.context == :contextUnit) {
      if(self.item == :itemDistance) {
        $.oMySettings.saveUnitDistance(_amValues[0] as Number);
      }
      else if(self.item == :itemElevation) {
        $.oMySettings.saveUnitElevation(_amValues[0] as Number);
      }
      else if(self.item == :itemPressure) {
        $.oMySettings.saveUnitPressure(_amValues[0] as Number);
      }
      else if(self.item == :itemRateOfTurn) {
        $.oMySettings.saveUnitRateOfTurn(_amValues[0] as Number);
      }
      else if(self.item == :itemTimeUTC) {
        $.oMySettings.saveUnitTimeUTC(_amValues[0] as Boolean);
      }
      $.oMySettings.load();  // ... use proper units in settings
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
