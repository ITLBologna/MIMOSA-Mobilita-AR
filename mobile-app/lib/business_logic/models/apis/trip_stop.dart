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
import 'package:mimosa/business_logic/extensions_and_utils/otp_string_extensions.dart';

class TripStop {
  String stopId;
  String stopName;
  String stopCode;
  double stopLat;
  double stopLon;
  double? distanceFromPosition;
  String? arrivalTime;
  String? departureTime;
  int? stopSequence;

  TripStop({
    required this.stopId,
    required this.stopName,
    required this.stopCode,
    required this.stopLat,
    required this.stopLon,
    this.distanceFromPosition,
    this.arrivalTime,
    this.departureTime,
    this.stopSequence
  });

  static TripStop fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static TripStop? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : TripStop(
        stopId: purgeIdFromIndex(map['stop_id'])!,
        stopName: map['stop_name'],
        stopCode: map['stop_code'] ?? purgeIdFromIndex(map['stop_id']),
        stopLat: map['stop_lat'],
        stopLon: map['stop_lon'],
        distanceFromPosition: map['distance_from_position'],
        arrivalTime: map['arrival_time'],
        departureTime: map['departure_time'],
        stopSequence: map['stop_sequence'],
      );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'Stop');
      return null;
    }
  }

  static TripStop fromJson(String data) {
    return TripStop.fromMap(json.decode(data));
  }

  @override
  bool operator ==(Object other) {
    return other is TripStop && other.hashCode == hashCode;
  }

  @override
  int get hashCode => stopId.hashCode;
}
