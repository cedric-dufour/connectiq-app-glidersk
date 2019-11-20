// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2019 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

using Toybox.Lang;
using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;

module LangUtils {

  //
  // FUNCTIONS: data primitives
  //

  // Deep-copy the given object
  function copy(_oObject) {
    var oCopy = null;
    if(_oObject instanceof Lang.Array) {
      var iSize = _oObject.size();
      oCopy = new [iSize];
      for(var i=0; i<iSize; i++) {
        oCopy[i] = LangUtils.copy(_oObject[i]);
      }
    }
    else if(_oObject instanceof Lang.Dictionary) {
      var amKeys = _oObject.keys();
      var iSize = amKeys.size();
      oCopy = {};
      for(var i=0; i<iSize; i++) {
        var mKey = amKeys[i];
        oCopy.put(mKey, LangUtils.copy(_oObject.get(mKey)));
      }
    }
    else if(_oObject instanceof Lang.Exception) {
      throw new Lang.UnexpectedTypeException();
    }
    else if(_oObject instanceof Lang.Method) {
      throw new Lang.UnexpectedTypeException();
    }
    else {
      oCopy = _oObject;
    }
    return oCopy;
  }

  // Sort the given array (in-place) and return its re-ordered indices (array)
  // NOTE: we use Jon Bentley's optimized insertion sort algorithm; https://en.wikipedia.org/wiki/Insertion_sort
  function sort(_amValues) {
    var iSize = _amValues.size();
    var aiIndices = new [iSize];
    for(var n=0; n<iSize; n++) { aiIndices[n] = n; }

    // Sort
    var i = 1;
    while(i<iSize) {
      var mSwap_value = _amValues[i];
      var iSwap_index = aiIndices[i];
      var j = i - 1;
      while(j >= 0 and _amValues[j] > mSwap_value) {
        _amValues[j+1] = _amValues[j];
        aiIndices[j+1] = aiIndices[j];
        j--;
      }
      _amValues[j+1] = mSwap_value;
      aiIndices[j+1] = iSwap_index;
      i++;
    }

    // Done
    return aiIndices;
  }


  //
  // FUNCTIONS: geographical primitives
  //

  // Compute the distance (in meters) between two geographical coordinates, using the rhumb-line formula (constant bearing)
  // INPUT: Position.Location.toRadians() array
  function distance(_adLoc1, _adLoc2) {
    // Formula shamelessly copied from http://www.movable-type.co.uk/scripts/latlong.html
    // NOTE: We MUST use double precision math throughout the calculation to avoid rounding errors
    //       Also, let's avoid (expensive) operations like division or exponentiation as much as possible
    var dLatD = _adLoc2[0] - _adLoc1[0];
    var dLonD = _adLoc2[1] - _adLoc1[1];
    //var dPhiD = Math.ln(Math.tan(0.5d*_adLoc2[0] + 0.25d*Math.PI) / Math.tan(0.5d*_adLoc1[0] + 0.25d*Math.PI));
    var dPhiD = Math.ln(Math.tan(0.5d*_adLoc2[0] + 0.78539816339744830961d) / Math.tan(0.5d*_adLoc1[0] + 0.78539816339744830961d));
    var dQ;
    if(dPhiD != 0.0d) {
      dQ = dLatD/dPhiD;
    }
    else {
      dQ = Math.cos(_adLoc1[0]);
    }
    if(dLonD.abs() > 3.14159265358979323846d) {
      //dLonD = dLonD > 0.0d ? dLonD - 2.0d*Math.PI : 2.0d*Math.PI + dLonD;
      dLonD = dLonD > 0.0d ? dLonD - 6.28318530717958647692d : 6.28318530717958647692d + dLonD;
    }
    // Let's use Earth mean radius (https://en.wikipedia.org/wiki/Earth_radius#Mean_radius)
    var dDistance = 6371007.2d * Math.sqrt(dLatD*dLatD + dLonD*dLonD*dQ*dQ);
    return dDistance.toFloat();
  }

  // Compute the bearing (in radians) between two geographical coordinates, using the rhumb-line formula (constant bearing)
  // INPUT: Position.Location.toRadians() array
  function bearing(_adLoc1, _adLoc2) {
    // Formula shamelessly copied from http://www.movable-type.co.uk/scripts/latlong.html
    // NOTE: We MUST use double precision math throughout the calculation to avoid rounding errors
    //       Also, let's avoid (expensive) operations like division or exponentiation as much as possible
    var dLonD = _adLoc2[1] - _adLoc1[1];
    //var dPhiD = Math.ln(Math.tan(0.5d*_adLoc2[0] + 0.25d*Math.PI) / Math.tan(0.5d*_adLoc1[0] + 0.25d*Math.PI));
    var dPhiD = Math.ln(Math.tan(0.5d*_adLoc2[0] + 0.78539816339744830961d) / Math.tan(0.5d*_adLoc1[0] + 0.78539816339744830961d));
    if(dLonD.abs() > 3.14159265358979323846d) {
      //dLonD = dLonD > 0.0d ? dLonD - 2.0d*Math.PI : 2.0d*Math.PI + dLonD;
      dLonD = dLonD > 0.0d ? dLonD - 6.28318530717958647692d : 6.28318530717958647692d + dLonD;
    }
    var dBearing = Math.atan2(dLonD, dPhiD);
    if(dBearing < 0.0d) {
      dBearing += 6.28318530717958647692d;
    }
    return dBearing.toFloat();
  }

  // Estimate the distance (in meters) between two geographical coordinates, using the equirectangular rhumb-line estimation
  // INPUT: Position.Location.toRadians() array
  function distanceEstimate(_adLoc1, _adLoc2) {
    // Formula shamelessly copied from http://www.movable-type.co.uk/scripts/latlong.html
    var x = (_adLoc2[1] - _adLoc1[1]) * Math.cos((_adLoc2[0] + _adLoc1[0]) / 2.0d);
    var y = (_adLoc2[0] - _adLoc1[0]);
    // Let's use Earth mean radius (https://en.wikipedia.org/wiki/Earth_radius#Mean_radius)
    var dDistance = Math.sqrt(x*x + y*y) * 6371007.2d;
    return dDistance.toFloat();
  }


  //
  // FUNCTIONS: time formatting
  //

  function formatTime(_oTime, _bUTC, _bSecond) {
    if(_oTime != null) {
      var oTimeInfo = _bUTC ? Gregorian.utcInfo(_oTime, Time.FORMAT_SHORT) : Gregorian.info(_oTime, Time.FORMAT_SHORT);
      if(_bSecond) {
        return Lang.format("$1$:$2$:$3$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d"), oTimeInfo.sec.format("%02d")]);
      }
      else {
        return Lang.format("$1$:$2$", [oTimeInfo.hour.format("%02d"), oTimeInfo.min.format("%02d")]);
      }
    }
    else {
      return _bSecond ? "--:--:--" : "--:--";
    }
  }

  function formatElapsedTime(_oTimeFrom, _oTimeTo, _bSecond) {
    if(_oTimeFrom != null and _oTimeTo != null) {
      if(_bSecond) {
        var oTimeInfo = Gregorian.utcInfo(new Time.Moment(_oTimeTo.subtract(_oTimeFrom).value()), Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$:$3$", [oTimeInfo.hour.format("%01d"), oTimeInfo.min.format("%02d"), oTimeInfo.sec.format("%02d")]);
      }
      else {
        var oTimeInfo_from = Gregorian.utcInfo(_oTimeFrom, Time.FORMAT_SHORT);
        var oTimeInfo_to = Gregorian.utcInfo(_oTimeTo, Time.FORMAT_SHORT);
        var oTimeInfo = Gregorian.utcInfo(new Time.Moment((3600*oTimeInfo_to.hour+60*oTimeInfo_to.min) - (3600*oTimeInfo_from.hour+60*oTimeInfo_from.min)), Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$", [oTimeInfo.hour.format("%01d"), oTimeInfo.min.format("%02d")]);
      }
    }
    else {
      return _bSecond ? "-:--:--" : "-:--";
    }
  }

  function formatElapsed(_iElapsed, _bSecond) {
    if(_iElapsed != null) {
      var oTimeInfo = Gregorian.utcInfo(new Time.Moment(_iElapsed), Time.FORMAT_SHORT);
      if(_bSecond) {
        return Lang.format("$1$:$2$:$3$", [oTimeInfo.hour.format("%01d"), oTimeInfo.min.format("%02d"), oTimeInfo.sec.format("%02d")]);
      }
      else {
        return Lang.format("$1$:$2$", [oTimeInfo.hour.format("%01d"), oTimeInfo.min.format("%02d")]);
      }
    }
    else {
      return _bSecond ? "-:--:--" : "-:--";
    }
  }

}
