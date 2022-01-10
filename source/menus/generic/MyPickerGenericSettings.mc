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
using Toybox.WatchUi as Ui;

class MyPickerGenericSettings extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_context, _item) {
    if(_context == :contextVariometer) {
      if(_item == :itemRange) {
        var iVariometerRange = App.Properties.getValue("userVariometerRange");
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [Lang.format("$1$\n$2$", [(3.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            Lang.format("$1$\n$2$", [(6.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            Lang.format("$1$\n$2$", [(9.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerRange),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerRange)]});
      }
      else if(_item == :itemMode) {
        var iVariometerMode = App.Properties.getValue("userVariometerMode");
        var oFactory = new PickerFactoryDictionary([0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueVariometerModeAltitude),
                                                    Ui.loadResource(Rez.Strings.valueVariometerModeEnergy)],
                                                   {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerMode),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerMode)]});
      }
      else if(_item == :itemEnergyEfficiency) {
        var iVariometerEnergyEfficiency = App.Properties.getValue("userVariometerEnergyEfficiency");
        var oFactory = new PickerFactoryNumber(0, 100, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Lang.format("$1$ [%]", [Ui.loadResource(Rez.Strings.titleVariometerEnergyEfficiency)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iVariometerEnergyEfficiency)]});
      }
      else if(_item == :itemPlotRange) {
        var iVariometerPlotRange = App.Properties.getValue("userVariometerPlotRange");
        var oFactory = new PickerFactoryNumber(1, 5, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Lang.format("$1$ [min]", [Ui.loadResource(Rez.Strings.titleVariometerPlotRange)]),
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
        var iSafetyFinesse = App.Properties.getValue("userSafetyFinesse");
        var oFactory = new PickerFactoryNumber(1, 99, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleSafetyFinesse),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iSafetyFinesse)]});
      }
      else if(_item == :itemHeadingBug) {
        var iSafetyHeadingBug = App.Properties.getValue("userSafetyHeadingBug");
        var oFactory = new PickerFactoryDictionary([0, 1 ,2],
                                                   [Ui.loadResource(Rez.Strings.valueOff),
                                                    Ui.loadResource(Rez.Strings.valueAuto),
                                                    Ui.loadResource(Rez.Strings.valueOn)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleSafetyHeadingBug),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iSafetyHeadingBug)]});
      }
      else if(_item == :itemGraceDuration) {
        var iSafetyGraceDuration = App.Properties.getValue("userSafetyGraceDuration");
        var oFactory = new PickerFactoryDictionary([0, 300, 600, 900, 1200, 1500, 1800, 2700, 3600],
                                                   ["0", "5", "10", "15", "20", "25", "30", "45", "60"],
                                                   null);
        var iIndex = oFactory.indexOfKey(iSafetyGraceDuration);
        if(iIndex < 0) {
          iIndex = 0;
        }
        Picker.initialize({
            :title => new Ui.Text({
                :text => Lang.format("$1$ [min]", [Ui.loadResource(Rez.Strings.titleSafetyGraceDuration)]),
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
        var iGeneralTimeConstant = App.Properties.getValue("userGeneralTimeConstant");
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 45, 60],
                                                   ["0", "1", "2", "3", "4", "5", "10", "15", "20", "25", "30", "45", "60"],
                                                   null);
        var iIndex = oFactory.indexOfKey(iGeneralTimeConstant);
        if(iIndex < 0) {
          iIndex = 5;
        }
        Picker.initialize({
            :title => new Ui.Text({
                :text => Lang.format("$1$ [s]", [Ui.loadResource(Rez.Strings.titleGeneralTimeConstant)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [iIndex]});
      }
      else if(_item == :itemDisplayFilter) {
        var iGeneralDisplayFilter = App.Properties.getValue("userGeneralDisplayFilter");
        var oFactory = new PickerFactoryDictionary([0, 1, 2],
                                                   [Ui.loadResource(Rez.Strings.valueOff),
                                                    Ui.loadResource(Rez.Strings.valueGeneralDisplayFilterTimeDerived),
                                                    Ui.loadResource(Rez.Strings.valueAll)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Lang.format("$1$", [Ui.loadResource(Rez.Strings.titleGeneralDisplayFilter)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iGeneralDisplayFilter)]});
      }
      else if(_item == :itemBackgroundColor) {
        var iColor = App.Properties.getValue("userGeneralBackgroundColor");
        var oFactory = new PickerFactoryDictionary([Gfx.COLOR_WHITE, Gfx.COLOR_BLACK],
                                                   [Ui.loadResource(Rez.Strings.valueColorWhite),
                                                    Ui.loadResource(Rez.Strings.valueColorBlack)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleGeneralBackgroundColor),
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
        var iUnitDistance = App.Properties.getValue("userUnitDistance");
        var oFactory = new PickerFactoryDictionary([-1, 0, 1 ,2],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "km", "sm", "nm"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitDistance),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitDistance)]});
      }
      else if(_item == :itemElevation) {
        var iUnitElevation = App.Properties.getValue("userUnitElevation");
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "m", "ft"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitElevation),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitElevation)]});
      }
      else if(_item == :itemPressure) {
        var iUnitPressure = App.Properties.getValue("userUnitPressure");
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "mb", "inHg"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitPressure),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitPressure)]});
      }
      else if(_item == :itemRateOfTurn) {
        var iUnitRateOfTurn = App.Properties.getValue("userUnitRateOfTurn");
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "°/s", "rpm"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitRateOfTurn),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitRateOfTurn)]});
      }
      else if(_item == :itemTimeUTC) {
        var bUnitTimeUTC = App.Properties.getValue("userUnitTimeUTC");
        var oFactory = new PickerFactoryDictionary([false, true],
                                                   [Ui.loadResource(Rez.Strings.valueUnitTimeLT),
                                                    Ui.loadResource(Rez.Strings.valueUnitTimeUTC)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitTimeUTC),
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

  private var context;
  private var item;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context, _item) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    if(self.context == :contextVariometer) {
      if(self.item == :itemRange) {
        App.Properties.setValue("userVariometerRange", _amValues[0]);
      }
      else if(self.item == :itemMode) {
        App.Properties.setValue("userVariometerMode", _amValues[0]);
      }
      else if(self.item == :itemEnergyEfficiency) {
        App.Properties.setValue("userVariometerEnergyEfficiency", _amValues[0]);
      }
      else if(self.item == :itemPlotRange) {
        App.Properties.setValue("userVariometerPlotRange", _amValues[0]);
      }
    }
    else if(self.context == :contextSafety) {
      if(self.item == :itemFinesse) {
        App.Properties.setValue("userSafetyFinesse", _amValues[0]);
      }
      else if(self.item == :itemHeadingBug) {
        App.Properties.setValue("userSafetyHeadingBug", _amValues[0]);
      }
      else if(self.item == :itemGraceDuration) {
        App.Properties.setValue("userSafetyGraceDuration", _amValues[0]);
        // Reset the grace period
        $.oMySettings.load();
        $.oMyProcessing.bGrace = false;
        $.oMyProcessing.iGraceEpoch = null;
      }
    }
    else if(self.context == :contextGeneral) {
      if(self.item == :itemTimeConstant) {
        App.Properties.setValue("userGeneralTimeConstant", _amValues[0]);
      }
      else if(self.item == :itemDisplayFilter) {
        App.Properties.setValue("userGeneralDisplayFilter", _amValues[0]);
      }
      if(self.item == :itemBackgroundColor) {
        App.Properties.setValue("userGeneralBackgroundColor", _amValues[0]);
      }
    }
    else if(self.context == :contextUnit) {
      if(self.item == :itemDistance) {
        App.Properties.setValue("userUnitDistance", _amValues[0]);
      }
      else if(self.item == :itemElevation) {
        App.Properties.setValue("userUnitElevation", _amValues[0]);
      }
      else if(self.item == :itemPressure) {
        App.Properties.setValue("userUnitPressure", _amValues[0]);
      }
      else if(self.item == :itemRateOfTurn) {
        App.Properties.setValue("userUnitRateOfTurn", _amValues[0]);
      }
      else if(self.item == :itemTimeUTC) {
        App.Properties.setValue("userUnitTimeUTC", _amValues[0]);
      }
      $.oMySettings.load();  // ... use proper units in settings
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

}
