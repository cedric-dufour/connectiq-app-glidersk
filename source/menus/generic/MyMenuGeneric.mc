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

class MyMenuGeneric extends Ui.Menu {

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
      if($.oMyAltimeter.fAltitudeActual != null) {
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
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeightReference), :menuSafetyHeightReference);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyHeadingBug), :menuSafetyHeadingBug);
      Menu.addItem(Ui.loadResource(Rez.Strings.titleSafetyGraceDuration), :menuSafetyGraceDuration);
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
      Menu.addItem(Ui.loadResource(Rez.Strings.titleGeneralAutoActivity), :menuGeneralAutoActivity);
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
      if($.oMyPositionLocation != null and $.oMyPositionAltitude != null) {
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
      if($.oMyActivity != null) {
        if($.oMyActivity.isRecording()) {
          Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityPause), :menuActivityPause);
        }
        else {
          Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityResume), :menuActivityResume);
        }
        Menu.addItem(Ui.loadResource(Rez.Strings.titleActivitySave), :menuActivitySave);
        Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityDiscard), :menuActivityDiscard);
        if(!$.oMySettings.bGeneralLapKey) {
          Menu.addItem(Ui.loadResource(Rez.Strings.titleActivityLap), :menuActivityLap);
        }
      }
    }

  }

}

class MyMenuGenericDelegate extends Ui.MenuInputDelegate {

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
        Ui.pushView(new MyMenuGeneric(:menuSettingsAltimeter),
                    new MyMenuGenericDelegate(:menuSettingsAltimeter),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsVariometer) {
        Ui.pushView(new MyMenuGeneric(:menuSettingsVariometer),
                    new MyMenuGenericDelegate(:menuSettingsVariometer),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsSafety) {
        Ui.pushView(new MyMenuGeneric(:menuSettingsSafety),
                    new MyMenuGenericDelegate(:menuSettingsSafety),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsSounds) {
        Ui.pushView(new MyMenuGeneric(:menuSettingsSounds),
                    new MyMenuGenericDelegate(:menuSettingsSounds),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsGeneral) {
        Ui.pushView(new MyMenuGeneric(:menuSettingsGeneral),
                    new MyMenuGenericDelegate(:menuSettingsGeneral),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsUnits) {
        Ui.pushView(new MyMenuGeneric(:menuSettingsUnits),
                    new MyMenuGenericDelegate(:menuSettingsUnits),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuStorage) {
        Ui.pushView(new MyMenuGeneric(:menuStorage),
                    new MyMenuGenericDelegate(:menuStorage),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAbout) {
        Ui.pushView(new MyMenuGeneric(:menuAbout),
                    new MyMenuGenericDelegate(:menuAbout),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsAltimeter) {
      if(_item == :menuAltimeterCalibration) {
        Ui.pushView(new MyMenuGeneric(:menuAltimeterCalibration),
                    new MyMenuGenericDelegate(:menuAltimeterCalibration),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAltimeterCorrection) {
        Ui.pushView(new MyMenuGeneric(:menuAltimeterCorrection),
                    new MyMenuGenericDelegate(:menuAltimeterCorrection),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuAltimeterCalibration) {
      if(_item == :menuAltimeterCalibrationQNH) {
        Ui.pushView(new MyPickerGenericPressure(:contextSettings, :itemAltimeterCalibration),
                    new MyPickerGenericPressureDelegate(:contextSettings, :itemAltimeterCalibration),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAltimeterCalibrationElevation) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :itemAltimeterCalibration),
                    new MyPickerGenericElevationDelegate(:contextSettings, :itemAltimeterCalibration),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuAltimeterCorrection) {
      if(_item == :menuAltimeterCorrectionAbsolute) {
        Ui.pushView(new MyPickerGenericPressure(:contextSettings, :itemAltimeterCorrection),
                    new MyPickerGenericPressureDelegate(:contextSettings, :itemAltimeterCorrection),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuAltimeterCorrectionRelative) {
        Ui.pushView(new MyPickerAltimeterCorrectionRelative(),
                    new MyPickerAltimeterCorrectionRelativeDelegate(),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsVariometer) {
      if(_item == :menuVariometerRange) {
        Ui.pushView(new MyPickerGenericSettings(:contextVariometer, :itemRange),
                    new MyPickerGenericSettingsDelegate(:contextVariometer, :itemRange),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuVariometerMode) {
        Ui.pushView(new MyPickerGenericSettings(:contextVariometer, :itemMode),
                    new MyPickerGenericSettingsDelegate(:contextVariometer, :itemMode),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuVariometerEnergyEfficiency) {
        Ui.pushView(new MyPickerGenericSettings(:contextVariometer, :itemEnergyEfficiency),
                    new MyPickerGenericSettingsDelegate(:contextVariometer, :itemEnergyEfficiency),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuVariometerPlotRange) {
        Ui.pushView(new MyPickerGenericSettings(:contextVariometer, :itemPlotRange),
                    new MyPickerGenericSettingsDelegate(:contextVariometer, :itemPlotRange),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsSafety) {
      if(_item == :menuSafetyFinesse) {
        Ui.pushView(new MyPickerGenericSettings(:contextSafety, :itemFinesse),
                    new MyPickerGenericSettingsDelegate(:contextSafety, :itemFinesse),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightDecision) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :itemSafetyHeightDecision),
                    new MyPickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightDecision),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightWarning) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :itemSafetyHeightWarning),
                    new MyPickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightWarning),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightCritical) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :itemSafetyHeightCritical),
                    new MyPickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightCritical),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeightReference) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :itemSafetyHeightReference),
                    new MyPickerGenericElevationDelegate(:contextSettings, :itemSafetyHeightReference),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyHeadingBug) {
        Ui.pushView(new MyPickerGenericSettings(:contextSafety, :itemHeadingBug),
                    new MyPickerGenericSettingsDelegate(:contextSafety, :itemHeadingBug),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSafetyGraceDuration) {
        Ui.pushView(new MyPickerGenericSettings(:contextSafety, :itemGraceDuration),
                    new MyPickerGenericSettingsDelegate(:contextSafety, :itemGraceDuration),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsSounds) {
      if(_item == :menuSoundsVariometerTones) {
        Ui.pushView(new MyPickerGenericOnOff(:contextSettings, :itemSoundsVariometerTones),
                    new MyPickerGenericOnOffDelegate(:contextSettings, :itemSoundsVariometerTones),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSoundsSafetyTones) {
        Ui.pushView(new MyPickerGenericOnOff(:contextSettings, :itemSoundsSafetyTones),
                    new MyPickerGenericOnOffDelegate(:contextSettings, :itemSoundsSafetyTones),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSoundsMuteDistance) {
        Ui.pushView(new MyPickerGenericDistance(:contextSettings, :itemSoundsMuteDistance),
                    new MyPickerGenericDistanceDelegate(:contextSettings, :itemSoundsMuteDistance),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsGeneral) {
      if(_item == :menuGeneralTimeConstant) {
        Ui.pushView(new MyPickerGenericSettings(:contextGeneral, :itemTimeConstant),
                    new MyPickerGenericSettingsDelegate(:contextGeneral, :itemTimeConstant),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralDisplayFilter) {
        Ui.pushView(new MyPickerGenericSettings(:contextGeneral, :itemDisplayFilter),
                    new MyPickerGenericSettingsDelegate(:contextGeneral, :itemDisplayFilter),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralBackgroundColor) {
        Ui.pushView(new MyPickerGenericSettings(:contextGeneral, :itemBackgroundColor),
                    new MyPickerGenericSettingsDelegate(:contextGeneral, :itemBackgroundColor),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralAutoActivity) {
        Ui.pushView(new MyPickerGenericOnOff(:contextSettings, :itemGeneralAutoActivity),
                    new MyPickerGenericOnOffDelegate(:contextSettings, :itemGeneralAutoActivity),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuGeneralLapKey) {
        Ui.pushView(new MyPickerGenericOnOff(:contextSettings, :itemGeneralLapKey),
                    new MyPickerGenericOnOffDelegate(:contextSettings, :itemGeneralLapKey),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsUnits) {
      if(_item == :menuUnitDistance) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, :itemDistance),
                    new MyPickerGenericSettingsDelegate(:contextUnit, :itemDistance),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitElevation) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, :itemElevation),
                    new MyPickerGenericSettingsDelegate(:contextUnit, :itemElevation),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitPressure) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, :itemPressure),
                    new MyPickerGenericSettingsDelegate(:contextUnit, :itemPressure),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitRateOfTurn) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, :itemRateOfTurn),
                    new MyPickerGenericSettingsDelegate(:contextUnit, :itemRateOfTurn),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuUnitTimeUTC) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, :itemTimeUTC),
                    new MyPickerGenericSettingsDelegate(:contextUnit, :itemTimeUTC),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuStorage) {
      if(_item == :menuStorageImportData) {
        Ui.pushView(new MyPickerGenericText(:contextStorage, :itemImportData),
                    new MyPickerGenericTextDelegate(:contextStorage, :itemImportData),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuStorageClear) {
        Ui.pushView(new MyMenuGenericConfirm(:contextStorage, :actionClear),
                    new MyMenuGenericConfirmDelegate(:contextStorage, :actionClear, true),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuDestination) {
      if(_item == :menuDestinationLoad) {
        Ui.pushView(new MyPickerGenericStorage(:storageDestination, :actionLoad),
                    new MyPickerGenericStorageDelegate(:storageDestination, :actionLoad),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationEdit) {
        Ui.pushView(new MyMenuGeneric(:menuDestinationEdit),
                    new MyMenuGenericDelegate(:menuDestinationEdit),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationSave) {
        Ui.pushView(new MyPickerGenericStorage(:storageDestination, :actionSave),
                    new MyPickerGenericStorageDelegate(:storageDestination, :actionSave),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationDelete) {
        Ui.pushView(new MyPickerGenericStorage(:storageDestination, :actionDelete),
                    new MyPickerGenericStorageDelegate(:storageDestination, :actionDelete),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettingsSafety) {
        Ui.pushView(new MyMenuGeneric(:menuSettingsSafety),
                    new MyMenuGenericDelegate(:menuSettingsSafety),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuSettings) {
        Ui.pushView(new MyMenuGeneric(:menuSettings),
                    new MyMenuGenericDelegate(:menuSettings),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
    else if(self.menu == :menuDestinationEdit) {
      if(_item == :menuDestinationName) {
        Ui.pushView(new MyPickerGenericText(:contextDestination, :itemName),
                    new MyPickerGenericTextDelegate(:contextDestination, :itemName),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationLatitude) {
        Ui.pushView(new MyPickerGenericLatitude(:contextDestination, :itemPosition),
                    new MyPickerGenericLatitudeDelegate(:contextDestination, :itemPosition),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationLongitude) {
        Ui.pushView(new MyPickerGenericLongitude(:contextDestination, :itemPosition),
                    new MyPickerGenericLongitudeDelegate(:contextDestination, :itemPosition),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationElevation) {
        Ui.pushView(new MyPickerGenericElevation(:contextDestination, :itemPosition),
                    new MyPickerGenericElevationDelegate(:contextDestination, :itemPosition),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuDestinationFromCurrent) {
        Ui.pushView(new MyMenuGenericConfirm(:contextDestination, :actionFromCurrent),
                    new MyMenuGenericConfirmDelegate(:contextDestination, :actionFromCurrent, false),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    //else if(self.menu == :menuAbout) {
    //  // Nothing to do here
    //}

    else if(self.menu == :menuActivity) {
      if(_item == :menuActivityResume) {
        if($.oMyActivity != null) {
          $.oMyActivity.resume();
        }
      }
      else if(_item == :menuActivityPause) {
        if($.oMyActivity != null) {
          $.oMyActivity.pause();
        }
      }
      else if(_item == :menuActivitySave) {
        Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionSave),
                    new MyMenuGenericConfirmDelegate(:contextActivity, :actionSave, true),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuActivityDiscard) {
        Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionDiscard),
                    new MyMenuGenericConfirmDelegate(:contextActivity, :actionDiscard, true),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(_item == :menuActivityLap) {
        Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionLap),
                    new MyMenuGenericConfirmDelegate(:contextActivity, :actionLap, true),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

  }

}
