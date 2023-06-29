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
import 'package:mimosa/business_logic/models/apis/buses_positions/bus_position.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';

class BusInfo {
  final BusPosition busPosition;
  final Trip trip;
  final DateTime updatedAt;
  final String label;
  final String stopId;
  final String licensePlate;
  final int occupancyStatus;
  final int currentStatus;

  BusInfo({
    required this.busPosition,
    required this.updatedAt,
    required this.trip,
    required this.label,
    required this.stopId,
    required this.currentStatus,
    required this.licensePlate,
    required this.occupancyStatus
  });

  static BusInfo fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static BusInfo? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : BusInfo(
              busPosition: BusPosition.fromMap(map),
              trip: Trip.fromMap(map['trip']),
              updatedAt: DateTime.parse(map['updated_at']),
              label: map['label'] ?? '',
              stopId: map['stop_id'] ?? '',
              currentStatus: map['current_status'] ?? -1,
              licensePlate: map['license_plate'] ?? '',
              occupancyStatus: map['occupancy_status'] ?? -1,
            );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'BusPositionInfo');
      return null;
    }
  }

  static BusInfo fromJson(String data) {
    return BusInfo.fromMap(json.decode(data));
  }
}