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

import 'dart:convert';

import 'package:mimosa/business_logic/extensions_and_utils/errors_utils.dart';

class BusPosition {
  double latitude;
  double longitude;
  final double bearing;
  final double speedInMetersPerSecond;

  BusPosition({
    required this.latitude,
    required this.longitude,
    required this.bearing,
    required this.speedInMetersPerSecond
  });

  static BusPosition fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static BusPosition? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : BusPosition(
        latitude: map['latitude'],
        longitude: map['longitude'],
        bearing: map['bearing'].toDouble(),
        speedInMetersPerSecond: map['speed'].toDouble(),
      );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'BusPosition');
      return null;
    }
  }

  static BusPosition fromJson(String data) {
    return BusPosition.fromMap(json.decode(data));
  }
}