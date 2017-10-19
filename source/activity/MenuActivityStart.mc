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

using Toybox.ActivityRecording as AR;
using Toybox.Attention as Attn;
using Toybox.FitContributor as FC;
using Toybox.WatchUi as Ui;

// NOTE: Since Ui.Confirmation does not allow to pre-select "Yes" as an answer,
//       let's us our own "confirmation" menu and save one key press
class MenuActivityStart extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize() {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.menuConfirm));
    Menu.addItem(Lang.format("$1$ ?", [Ui.loadResource(Rez.Strings.menuActivityStart)]), :confirm);
  }

}

class MenuDelegateActivityStart extends Ui.MenuInputDelegate {

  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize() {
    MenuInputDelegate.initialize();
  }

  function onMenuItem(item) {
    if (item == :confirm) {
      if($.GSK_ActivitySession == null) {
        // NOTE: "Flying" activity number is 20 (cf. https://www.thisisant.com/resources/fit -> Profiles.xlsx)
        $.GSK_ActivitySession = AR.createSession({ :name=>"GliderSK", :sport=>20, :subSport=>AR.SUB_SPORT_GENERIC });
        $.GSK_FitField_VerticalSpeed = $.GSK_ActivitySession.createField("VerticalSpeed", $.GSK_FITFIELD_VERTICALSPEED, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.GSK_Settings.sUnitVerticalSpeed });
        $.GSK_FitField_VerticalSpeed_UnitConstant = $.GSK_Settings.fUnitVerticalSpeedConstant;
        $.GSK_FitField_RateOfTurn = $.GSK_ActivitySession.createField("RateOfTurn", $.GSK_FITFIELD_RATEOFTURN, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>$.GSK_Settings.sUnitRateOfTurn });
        $.GSK_FitField_RateOfTurn_UnitConstant = $.GSK_Settings.fUnitRateOfTurnConstant;
        $.GSK_FitField_Acceleration = $.GSK_ActivitySession.createField("Acceleration", $.GSK_FITFIELD_ACCELERATION, FC.DATA_TYPE_FLOAT, { :mesgType=>FC.MESG_TYPE_RECORD, :units=>"g" });
      }
      $.GSK_ActivitySession.start();
      if(Attn has :playTone) {
        Attn.playTone(Attn.TONE_START);
      }
    }
  }

}
