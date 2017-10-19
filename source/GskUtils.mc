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

using Toybox.Lang;
using Toybox.Math;

module GskUtils {

  // Deep-copy the given object
  function copy(_oObject) {
    var oCopy = null;
    if(_oObject instanceof Lang.Array) {
      var iSize = _oObject.size();
      oCopy = new [iSize];
      for(var i=0; i<iSize; i++) {
        oCopy[i] = GskUtils.copy(_oObject[i]);
      }
    }
    else if(_oObject instanceof Lang.Dictionary) {
      var amKeys = _oObject.keys();
      var iSize = amKeys.size();
      oCopy = {};
      for(var i=0; i<iSize; i++) {
        var mKey = amKeys[i];
        oCopy.put(mKey, GskUtils.copy(_oObject.get(mKey)));
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

  // Compute the distance (in meters) between two geographical coordinates, using the rhumb-line formula (constant bearing)
  // INPUT: Position.Location.toRadians() array
  function distance(_adLoc1, _adLoc2) {
    // Formula shamelessly copied from http://www.movable-type.co.uk/scripts/latlong.html
    // NOTE: We MUST use double precision math throughout the calculation to avoid rounding errors
    //       Also, let's avoid (expensive) operations like division or exponentiation as much as possible
    var dLatD = _adLoc2[0] - _adLoc1[0];
    var dLonD = _adLoc2[1] - _adLoc1[1];
    var dPhiD = Math.ln(Math.tan(0.5d*_adLoc2[0] + 0.25d*Math.PI) / Math.tan(0.5d*_adLoc1[0] + 0.25d*Math.PI));
    var dQ;
    if(dPhiD != 0.0d) {
      dQ = dLatD/dPhiD;
    }
    else {
      dQ = Math.cos(dLat1);
    }
    if(dLonD.abs() > Math.PI) {
      dLonD = dLonD > 0.0d ? dLonD - 2.0d*Math.PI : 2.0d*Math.PI + dLonD;
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
    var dPhiD = Math.ln(Math.tan(0.5d*_adLoc2[0] + 0.25d*Math.PI) / Math.tan(0.5d*_adLoc1[0] + 0.25d*Math.PI));
    if(dLonD.abs() > Math.PI) {
      dLonD = dLonD > 0.0d ? dLonD - 2.0d*Math.PI : 2.0d*Math.PI + dLonD;
    }
    var dBearing = Math.atan2(dLonD, dPhiD);
    return dBearing.toFloat();
  }

}
