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

using Toybox.WatchUi as Ui;

class GSK_MenuGeneric extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize(_menu) {
    Menu.initialize();

    if(_menu == :menuSettings) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettings));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsAltimeter), :menuSettingsAltimeter);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsVariometer), :menuSettingsVariometer);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsSafety), :menuSettingsSafety);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsSounds), :menuSettingsSounds);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsGeneral), :menuSettingsGeneral);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsUnits), :menuSettingsUnits);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorage), :menuStorage);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleAbout), :menuAbout);
    }

    else if(_menu == :menuSettingsAltimeter) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsAltimeter));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCalibration), :menuAltimeterCalibration);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCorrection), :menuAltimeterCorrection);
    }
    else if(_menu == :menuAltimeterCalibration) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleAltimeterCalibration));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCalibrationQNH), :menuAltimeterCalibrationQNH);
      if($.GSK_oAltimeter.fAltitudeActual != null) {
        Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCalibrationElevation), :menuAltimeterCalibrationElevation);
      }
    }
    else if(_menu == :menuAltimeterCorrection) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleAltimeterCorrection));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCorrectionAbsolute), :menuAltimeterCorrectionAbsolute);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleAltimeterCorrectionRelative), :menuAltimeterCorrectionRelative);
    }

    else if(_menu == :menuSettingsVariometer) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsVariometer));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerRange), :menuVariometerRange);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerMode), :menuVariometerMode);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerEnergyEfficiency), :menuVariometerEnergyEfficiency);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleVariometerPlotRange), :menuVariometerPlotRange);
    }

    else if(_menu == :menuSettingsSafety) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsSafety));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyFinesse), :menuSafetyFinesse);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightDecision), :menuSafetyHeightDecision);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightWarning), :menuSafetyHeightWarning);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightCritical), :menuSafetyHeightCritical);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeadingBug), :menuSafetyHeadingBug);
    }

    else if(_menu == :menuSettingsSounds) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsSounds));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSoundsVariometerTones), :menuSoundsVariometerTones);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSoundsSafetyTones), :menuSoundsSafetyTones);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSoundsMuteDistance), :menuSoundsMuteDistance);
    }

    else if(_menu == :menuSettingsGeneral) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsGeneral));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleGeneralTimeConstant), :menuGeneralTimeConstant);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleGeneralDisplayFilter), :menuGeneralDisplayFilter);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleGeneralBackgroundColor), :menuGeneralBackgroundColor);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleGeneralLapKey), :menuGeneralLapKey);
    }

    else if(_menu == :menuSettingsUnits) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleSettingsUnits));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitDistance), :menuUnitDistance);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitElevation), :menuUnitElevation);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitPressure), :menuUnitPressure);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitRateOfTurn), :menuUnitRateOfTurn);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleUnitTimeUTC), :menuUnitTimeUTC);
    }

    else if(_menu == :menuStorage) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleStorage));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorageImportData), :menuStorageImportData);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorageClear), :menuStorageClear);
    }

    else if(_menu == :menuDestination) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleDestination));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorageLoad), :menuDestinationLoad);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorageEdit), :menuDestinationEdit);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorageSave), :menuDestinationSave);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleStorageDelete), :menuDestinationDelete);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettingsSafety), :menuSettingsSafety);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSettings), :menuSettings);
    }
    else if(_menu == :menuDestinationEdit) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleStorageEdit));
      Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationName), :menuDestinationName);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationLatitude), :menuDestinationLatitude);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationLongitude), :menuDestinationLongitude);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationElevation), :menuDestinationElevation);
      if($.GSK_oPositionLocation != null and $.GSK_oPositionAltitude != null) {
        Menu.addItem(Ui.loadResource(Rez.Strings.titleDestinationFromCurrent), :menuDestinationFromCurrent);
      }
    }

    else if(_menu == :menuAbout) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleAbout));
      Menu.addItem(Lang.format("$1$: $2$", [Ui.loadResource(Rez.Strings.titleVersion), Ui.loadResource(Rez.Strings.AppVersion)]), :aboutVersion);
      Menu.addItem(Lang.format("$1$: GPL 3.0", [Ui.loadResource(Rez.Strings.titleLicense)]), :aboutLicense);
      Menu.addItem(Lang.format("$1$: Cédric Dufour", [Ui.loadResource(Rez.Strings.titleAuthor)]), :aboutAuthor);
    }

    else if(_menu == :menuActivity) {
      Menu.setTitle(Ui.loadResource(Rez.Strings.titleActivity));
      if($.GSK_oActivity != null) {
        if($.GSK_oActivity.isRecording()) {
          Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityPause), :menuActivityPause);
        }
        else {
          Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityResume), :menuActivityResume);
        }
        Menu.addItem(Ui.loadResource(Rez.Strings.titleActivitySave), :menuActivitySave);
        Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityDiscard), :menuActivityDiscard);
      }
    }

  }

}

class GSK_MenuGenericDelegate extends Ui.MenuInputDelegate {

  //
  // VARIABLES
  //

  private var menu;


  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize(_menu) {
    MenuInputDelegate.initialize();
    self.menu = _menu;
  }

  function onMenuItem(_item) {

    if(self.menu == :menuSettings) {
      if(_item == :menuSettingsAltimeter) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsAltimeter), new GSK_MenuGenericDelegate(:menuSettingsAltimeter), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsVariometer) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsVariometer), new GSK_MenuGenericDelegate(:menuSettingsVariometer), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsSafety) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsSafety), new GSK_MenuGenericDelegate(:menuSettingsSafety), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsSounds) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsSounds), new GSK_MenuGenericDelegate(:menuSettingsSounds), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsGeneral) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsGeneral), new GSK_MenuGenericDelegate(:menuSettingsGeneral), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsUnits) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsUnits), new GSK_MenuGenericDelegate(:menuSettingsUnits), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuStorage) {
        Ui.pushView(new GSK_MenuGeneric(:menuStorage), new GSK_MenuGenericDelegate(:menuStorage), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAbout) {
        Ui.pushView(new GSK_MenuGeneric(:menuAbout), new GSK_MenuGenericDelegate(:menuAbout), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsAltimeter) {
      if(_item == :menuAltimeterCalibration) {
        Ui.pushView(new GSK_MenuGeneric(:menuAltimeterCalibration), new GSK_MenuGenericDelegate(:menuAltimeterCalibration), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAltimeterCorrection) {
        Ui.pushView(new GSK_MenuGeneric(:menuAltimeterCorrection), new GSK_MenuGenericDelegate(:menuAltimeterCorrection), Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuAltimeterCalibration) {
      if(_item == :menuAltimeterCalibrationQNH) {
        Ui.pushView(new GSK_PickerGenericPressure(:contextSettings, :itemAltimeterCalibration), new GSK_PickerGenericPressureDelegate(:contextSettings, :itemAltimeterCalibration), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAltimeterCalibrationElevation) {
        Ui.pushView(new GSK_PickerGenericElevation(:contextSettings, :itemAltimeterCalibration), new GSK_PickerGenericElevationDelegate(:contextSettings, :itemAltimeterCalibration), Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuAltimeterCorrection) {
      if(_item == :menuAltimeterCorrectionAbsolute) {
        Ui.pushView(new GSK_PickerGenericPressure(:contextSettings, :itemAltimeterCorrection), new GSK_PickerGenericPressureDelegate(:contextSettings, :itemAltimeterCorrection), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAltimeterCorrectionRelative) {
        Ui.pushView(new GSK_PickerAltimeterCorrectionRelative(), new GSK_PickerAltimeterCorrectionRelativeDelegate(), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsVariometer) {
      if(_item == :menuVariometerRange) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextVariometer, :itemRange), new GSK_PickerGenericSettingsDelegate(:contextVariometer, :itemRange), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuVariometerMode) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextVariometer, :itemMode), new GSK_PickerGenericSettingsDelegate(:contextVariometer, :itemMode), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuVariometerEnergyEfficiency) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextVariometer, :itemEnergyEfficiency), new GSK_PickerGenericSettingsDelegate(:contextVariometer, :itemEnergyEfficiency), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuVariometerPlotRange) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextVariometer, :itemPlotRange), new GSK_PickerGenericSettingsDelegate(:contextVariometer, :itemPlotRange), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsSafety) {
      if(_item == :menuSafetyFinesse) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextSafety, :itemFinesse), new GSK_PickerGenericSettingsDelegate(:contextSafety, :itemFinesse), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightDecision) {
        Ui.pushView(new GSK_PickerGenericElevation(:contextSettings, :itemSafetyHeightDecision), new GSK_PickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightDecision), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightWarning) {
        Ui.pushView(new GSK_PickerGenericElevation(:contextSettings, :itemSafetyHeightWarning), new GSK_PickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightWarning), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightCritical) {
        Ui.pushView(new GSK_PickerGenericElevation(:contextSettings, :itemSafetyHeightCritical), new GSK_PickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightCritical), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeadingBug) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextSafety, :itemHeadingBug), new GSK_PickerGenericSettingsDelegate(:contextSafety, :itemHeadingBug), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsSounds) {
      if(_item == :menuSoundsVariometerTones) {
        Ui.pushView(new GSK_PickerGenericOnOff(:contextSettings, :itemSoundsVariometerTones), new GSK_PickerGenericOnOffDelegate(:contextSettings, :itemSoundsVariometerTones), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSoundsSafetyTones) {
        Ui.pushView(new GSK_PickerGenericOnOff(:contextSettings, :itemSoundsSafetyTones), new GSK_PickerGenericOnOffDelegate(:contextSettings, :itemSoundsSafetyTones), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSoundsMuteDistance) {
        Ui.pushView(new GSK_PickerGenericDistance(:contextSettings, :itemSoundsMuteDistance), new GSK_PickerGenericDistanceDelegate(:contextSettings, :itemSoundsMuteDistance), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsGeneral) {
      if(_item == :menuGeneralTimeConstant) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextGeneral, :itemTimeConstant), new GSK_PickerGenericSettingsDelegate(:contextGeneral, :itemTimeConstant), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralDisplayFilter) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextGeneral, :itemDisplayFilter), new GSK_PickerGenericSettingsDelegate(:contextGeneral, :itemDisplayFilter), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralBackgroundColor) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextGeneral, :itemBackgroundColor), new GSK_PickerGenericSettingsDelegate(:contextGeneral, :itemBackgroundColor), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralLapKey) {
        Ui.pushView(new GSK_PickerGenericOnOff(:contextSettings, :itemGeneralLapKey), new GSK_PickerGenericOnOffDelegate(:contextSettings, :itemGeneralLapKey), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsUnits) {
      if(_item == :menuUnitDistance) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextUnit, :itemDistance), new GSK_PickerGenericSettingsDelegate(:contextUnit, :itemDistance), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitElevation) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextUnit, :itemElevation), new GSK_PickerGenericSettingsDelegate(:contextUnit, :itemElevation), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitPressure) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextUnit, :itemPressure), new GSK_PickerGenericSettingsDelegate(:contextUnit, :itemPressure), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitRateOfTurn) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextUnit, :itemRateOfTurn), new GSK_PickerGenericSettingsDelegate(:contextUnit, :itemRateOfTurn), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitTimeUTC) {
        Ui.pushView(new GSK_PickerGenericSettings(:contextUnit, :itemTimeUTC), new GSK_PickerGenericSettingsDelegate(:contextUnit, :itemTimeUTC), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuStorage) {
      if(_item == :menuStorageImportData) {
        Ui.pushView(new GSK_PickerGenericText(:contextStorage, :itemImportData), new GSK_PickerGenericTextDelegate(:contextStorage, :itemImportData), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuStorageClear) {
        Ui.pushView(new GSK_MenuGenericConfirm(:contextStorage, :actionClear), new GSK_MenuGenericConfirmDelegate(:contextStorage, :actionClear, true), Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuDestination) {
      if(_item == :menuDestinationLoad) {
        Ui.pushView(new GSK_PickerGenericStorage(:storageDestination, :actionLoad), new GSK_PickerGenericStorageDelegate(:storageDestination, :actionLoad), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationEdit) {
        Ui.pushView(new GSK_MenuGeneric(:menuDestinationEdit), new GSK_MenuGenericDelegate(:menuDestinationEdit), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationSave) {
        Ui.pushView(new GSK_PickerGenericStorage(:storageDestination, :actionSave), new GSK_PickerGenericStorageDelegate(:storageDestination, :actionSave), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationDelete) {
        Ui.pushView(new GSK_PickerGenericStorage(:storageDestination, :actionDelete), new GSK_PickerGenericStorageDelegate(:storageDestination, :actionDelete), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsSafety) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettingsSafety), new GSK_MenuGenericDelegate(:menuSettingsSafety), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettings) {
        Ui.pushView(new GSK_MenuGeneric(:menuSettings), new GSK_MenuGenericDelegate(:menuSettings), Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuDestinationEdit) {
      if(_item == :menuDestinationName) {
        Ui.pushView(new GSK_PickerGenericText(:contextDestination, :itemName), new GSK_PickerGenericTextDelegate(:contextDestination, :itemName), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationLatitude) {
        Ui.pushView(new GSK_PickerGenericLatitude(:contextDestination, :itemPosition), new GSK_PickerGenericLatitudeDelegate(:contextDestination, :itemPosition), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationLongitude) {
        Ui.pushView(new GSK_PickerGenericLongitude(:contextDestination, :itemPosition), new GSK_PickerGenericLongitudeDelegate(:contextDestination, :itemPosition), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationElevation) {
        Ui.pushView(new GSK_PickerGenericElevation(:contextDestination, :itemPosition), new GSK_PickerGenericElevationDelegate(:contextDestination, :itemPosition), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationFromCurrent) {
        Ui.pushView(new GSK_MenuGenericConfirm(:contextDestination, :actionFromCurrent), new GSK_MenuGenericConfirmDelegate(:contextDestination, :actionFromCurrent, false), Ui.SLIDE_IMMEDIATE);
      }
    }

    //else if(self.menu == :menuAbout) {
    //  // Nothing to do here
    //}

    else if(self.menu == :menuActivity) {
      if(_item == :menuActivityResume) {
        if($.GSK_oActivity != null) {
          $.GSK_oActivity.resume();
        }
      }
      else if(_item == :menuActivityPause) {
        if($.GSK_oActivity != null) {
          $.GSK_oActivity.pause();
        }
      }
      else if(_item == :menuActivitySave) {
        Ui.pushView(new GSK_MenuGenericConfirm(:contextActivity, :actionSave), new GSK_MenuGenericConfirmDelegate(:contextActivity, :actionSave, true), Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuActivityDiscard) {
        Ui.pushView(new GSK_MenuGenericConfirm(:contextActivity, :actionDiscard), new GSK_MenuGenericConfirmDelegate(:contextActivity, :actionDiscard, true), Ui.SLIDE_IMMEDIATE);
      }
    }

  }

}
