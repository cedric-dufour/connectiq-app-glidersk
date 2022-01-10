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

using Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;

//
// CLASS
//

// We use Simple Moving Average (SMA) to smoothen the sensor values over
// the user-specified "time constant" or time period.

class MyFilter {

  //
  // CONSTANTS
  //

  // Filter (maximum) size / time constant + 1
  private const MAX_SIZE = 61;

  // Filter "refresh" counter
  private const REFRESH_COUNTER = 300;  // every 5 minutes (if values are fed every second)

  // Filters (<-> sensors)
  public const ALTIMETER = 0;
  public const GROUNDSPEED = 1;
  public const VARIOMETER = 2;
  public const ACCELERATION = 3;
  public const HEADING_X = 4;
  public const HEADING_Y = 5;
  public const RATEOFTURN = 6;
  private const FILTERS = 7;


  //
  // VARIABLES
  //

  // Filters
  private var aoFilters;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Initialze the filters container array
    self.aoFilters = new [self.FILTERS];

    // Loop through each filter
    for(var F=0; F<self.FILTERS; F++) {
      // Create the filter array, containing:
      // [0] refresh counter
      // [1] filter length
      // [2] current value index (starting form 0)
      // [3] sum of all values
      // [4+] values history
      self.aoFilters[F] = new [self.MAX_SIZE+4];
      self.aoFilters[F][0] = Math.rand() % self.REFRESH_COUNTER;  // let's no refresh all filters at the same time
      self.aoFilters[F][1] = 1;
      self.resetFilter(F);
    }
  }

  function importSettings() {
    // Retrieve the new filter length (user-defined time constant + 1)
    var iFilterLength_new = $.oMySettings.iGeneralTimeConstant+1;

    // Loop through each filter
    for(var F=0; F<self.FILTERS; F++) {
      if(self.aoFilters[F][1] != iFilterLength_new) {
        // Store the filter length
        self.aoFilters[F][1] = iFilterLength_new;

        // Reset the filter (values)
        self.resetFilter(F);
      }
    }
  }

  function resetFilter(_F) {
    //Sys.println(Lang.format("DEBUG: MyFilter.resetFilter($1$)", [_F]));

    // Reset the current value index
    self.aoFilters[_F][2] = 0;

    // Reset the sum of all values
    self.aoFilters[_F][3] = 0;

    // Reset the values history
    for(var i=0; i<self.aoFilters[_F][1]; i++) {
      self.aoFilters[_F][4+i] = null;
    }
  }

  function filterValue(_F, _mValue) {
    //Sys.println(Lang.format("DEBUG: MyFilter.filterValue($1$, $2$)", [_F, _mValue]));

    // Check the refresh counter
    if(self.aoFilters[_F][0] == 0) {
      // Re-compute the sum of all values, which may diverge over time (given numeric imprecisions)
      //Sys.println(Lang.format("DEBUG: (Filter[$1$]) Refreshing", [_F]));
      self.aoFilters[_F][3] = 0;
      for(var i=0; i<self.aoFilters[_F][1]; i++) {
        if(self.aoFilters[_F][4+i] == null) {
          break;
        }
        self.aoFilters[_F][3] += self.aoFilters[_F][4+i];
      }

      // Reset the refresh counter
      self.aoFilters[_F][0] = self.REFRESH_COUNTER;
    }
    else {
      // Decrease the refresh counter
      self.aoFilters[_F][0] -= 1;
    }

    // Retrieve the previous "current" value and store the new one in its place
    var mValue_previous = self.aoFilters[_F][4+self.aoFilters[_F][2]];
    self.aoFilters[_F][4+self.aoFilters[_F][2]] = _mValue;

    // Update the sum of all values, by:
    // 1. adding the new (current) value
    // 2. substracting the previous "current" value (if available)
    // WARNING: numeric imprecisions will creep in and make the sum diverge over time!
    var iValues_quantity;
    self.aoFilters[_F][3] += _mValue;
    if(mValue_previous != null) {
      self.aoFilters[_F][3] -= mValue_previous;
      iValues_quantity = self.aoFilters[_F][1];
    }
    else {
      iValues_quantity = self.aoFilters[_F][2] + 1;
    }
    //Sys.println(Lang.format("DEBUG: (Filter[$1$]) Sum/Length = $2$/$3$", [_F, self.aoFilters[_F][3], iValues_quantity]));

    // Increase the current value index
    self.aoFilters[_F][2] = (self.aoFilters[_F][2] + 1) % self.aoFilters[_F][1];

    // Return the SMA-filtered value (sum of all values divided by quantity of values)
    return self.aoFilters[_F][3]/iValues_quantity;
  }

}
