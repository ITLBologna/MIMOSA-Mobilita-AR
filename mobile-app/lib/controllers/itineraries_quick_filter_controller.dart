/*
 * Copyright 2022-2023 bitApp S.r.l.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Mimosa APP
 *
 *
 * Contact: info@bitapp.it
 *
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/itineraries_controller.dart';

class IntinerariesQuickFilterController extends GetxController {
  final _showWalkPath = false.obs;
  final _maxNChanges = 1.obs;
  final _minutesAhead = 20.obs;
  final _minutesAheadStep = 10.obs;
  final _minMinutesAhead = 20.obs;
  final _maxMinutesAhead = 60.obs;

  int get maxBus => _maxNChanges.value + 1;
  bool get showWalkPath => _showWalkPath.value;
  int get minutesAhead => _minutesAhead.value;
  int get maxMinutesAhead => _maxMinutesAhead.value;

  void toggleShowWalkPath() {
    _showWalkPath.value = !_showWalkPath.value;
  }

  int _nextMaxNChanges(int curChanges) {
    if(curChanges == 3) {
      return 0;
    }
    else {
      return ++ curChanges;
    }
  }
  void nextMaxNChanges() {
    _maxNChanges.value = _nextMaxNChanges(_maxNChanges.value);
  }

  bool showAtLeastOneResult(ItinerariesController itinerariesController) {
    if(itinerariesController.itineraries?.isEmpty == true) {
      return false;
    }

    if(itinerariesController.onlyOnFootIntinerariesAvailables()) {
      if(!showWalkPath) {
        WidgetsBinding
            .instance
            .addPostFrameCallback((timeStamp) => toggleShowWalkPath());
      }
      return true;
    }

    var maxChanges = _maxNChanges.value;
    var minutes = minutesAhead;

    var itineraries = itinerariesController
        .getItineraries(
        nMaxBus: maxBus,
        showWalkPath: false,
        maxMinutesAhead: minutesAhead
    );

    if(itineraries.isNotEmpty || maxChanges == 3) {
      return itineraries.isNotEmpty;
    }

    while(itineraries.isEmpty) {
      if(maxChanges < 3) {
        maxChanges ++;
        itineraries = itinerariesController
            .getItineraries(
            nMaxBus: maxChanges + 1,
            showWalkPath: false,
            maxMinutesAhead: minutes
        );
      }
      else {
        itineraries = itinerariesController
            .getItineraries(
            nMaxBus: maxChanges + 1,
            showWalkPath: false,
            maxMinutesAhead: null
        );

        if(itineraries.isEmpty) {
          WidgetsBinding
              .instance
              .addPostFrameCallback((timeStamp) {
            _maxNChanges.value = maxChanges;
          });
          return false;
        }

        final nextDepartureInMinutes = itinerariesController
                  .getItineraryBusDeparture(itineraries.first.itinerary)
                  ?.difference(DateTime.now()).inMinutes;

        if(nextDepartureInMinutes != null && nextDepartureInMinutes > _minMinutesAhead.value) {
          var minutesReminder = nextDepartureInMinutes % 10;

          WidgetsBinding
              .instance
              .addPostFrameCallback((timeStamp) {
                _maxNChanges.value = maxChanges;
                _minMinutesAhead.value = nextDepartureInMinutes - 10 - minutesReminder;
                _minutesAhead.value = nextDepartureInMinutes + (10 - minutesReminder) + 10;
                _maxMinutesAhead.value = _minutesAhead.value + 60;
              });
        }

        return true;
      }
    }

    WidgetsBinding
        .instance
        .addPostFrameCallback((timeStamp) {
          _maxNChanges.value = maxChanges;
        });

    return true;
  }

  void nextMaxMinutesAhead() {
    final curMinutes = _minutesAhead.value;
    if(curMinutes == _maxMinutesAhead.value) {
      _minutesAhead.value = _minMinutesAhead.value;
    }
    else {
      _minutesAhead.value += _minutesAheadStep.value;
    }
  }
}