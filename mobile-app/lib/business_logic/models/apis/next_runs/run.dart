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

import 'package:mimosa/business_logic/extensions_and_utils/date_time_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/errors_utils.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';

class Run {
  final String stopId;
  final DateTime? scheduledTime;
  final DateTime? liveTime;
  final MimosaRoute route;
  final Trip trip;

  const Run({
    required this.stopId,
    required this.scheduledTime,
    required this.liveTime,
    required this.route,
    required this.trip
  });

  static Run fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static Run? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : Run(
              stopId: map['stop_id'],
              scheduledTime: (map['scheduled_departure_time'] as String?)?.fromTime(),
              liveTime: (map['live_departure_time'] as String?)?.fromTime(),
              route: MimosaRoute.fromMap(map['route']),
              trip: Trip.fromMap(map['trip'])
            );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'Run');
      return null;
    }
  }

  static Run fromJson(String data) {
    return Run.fromMap(json.decode(data));
  }
}