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

import 'package:ar_location_view/ar_annotation.dart';
import 'package:enum_flag/enum_flag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum _VisibleAnnotations with EnumFlag {
  buses,
  stops,
  directions,
}


int get visibleAnnotationsDefaultValue => _VisibleAnnotations.buses.value | _VisibleAnnotations.stops.value | _VisibleAnnotations.directions.value;

class VisibleAnnotationsTypesController extends GetxController {
  final _visibleAnnotationsFlag = (visibleAnnotationsDefaultValue).obs;
  int setDefaultValue() {
    _visibleAnnotationsFlag.value = visibleAnnotationsDefaultValue;
    return _visibleAnnotationsFlag.value;
  }

  bool stopsAnnotationsAreVisible() {
    return _visibleAnnotationsFlag.value.hasFlag(_VisibleAnnotations.stops);
  }

  bool directionsAnnotationsAreVisible() {
    return _visibleAnnotationsFlag.value.hasFlag(_VisibleAnnotations.directions);
  }

  bool busesAnnotationsAreVisible() {
    return _visibleAnnotationsFlag.value.hasFlag(_VisibleAnnotations.buses);
  }

  void setStopsAnnotationsVisibility(bool areVisible) {
    if(areVisible) {
      _visibleAnnotationsFlag.value = _visibleAnnotationsFlag.value | _VisibleAnnotations.stops.value;
    }
    else {
      _visibleAnnotationsFlag.value = _visibleAnnotationsFlag.value & ~_VisibleAnnotations.stops.value;
    }
  }

  void setDirectionsAnnotationsVisibility(bool areVisible) {
    if(areVisible) {
      _visibleAnnotationsFlag.value = _visibleAnnotationsFlag.value | _VisibleAnnotations.directions.value;
    }
    else {
      _visibleAnnotationsFlag.value = _visibleAnnotationsFlag.value & ~_VisibleAnnotations.directions.value;
    }
  }

  void setBusesAnnotationsVisibility(bool areVisible) {
    if(areVisible) {
      _visibleAnnotationsFlag.value = _visibleAnnotationsFlag.value | _VisibleAnnotations.buses.value;
    }
    else {
      _visibleAnnotationsFlag.value = _visibleAnnotationsFlag.value & ~_VisibleAnnotations.buses.value;
    }
  }
}