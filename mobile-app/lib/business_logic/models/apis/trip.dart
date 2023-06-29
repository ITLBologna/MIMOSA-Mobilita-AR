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
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';

class Trip {
  final String id;
  final String routeId;
  final String? headsign;
  final String? shortName;
  final int directionId;
  final String shapeId;
  final String shapePolyline;
  final List<TripStop> stops;

  Trip({required this.id,
    required this.routeId,
    required this.headsign,
    required this.shortName,
    required this.directionId,
    required this.shapeId,
    required this.shapePolyline,
    required this.stops});

  static Trip fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static Trip? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : Trip(
        id: map['trip_id'],
        routeId: map['route_id'],
        headsign: map['trip_headsign'],
        shortName: map['trip_short_name'],
        directionId: map['direction_id'],
        shapeId: map['shape_id'],
        shapePolyline: map['shape_polyline'] ?? '',
        stops: listFromMap(map, key: 'stops', fromMap: (map) => TripStop.fromMap(map)),
      );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'Trip');
      return null;
    }
  }

  static Trip fromJson(String data) {
    return Trip.fromMap(json.decode(data));
  }
}