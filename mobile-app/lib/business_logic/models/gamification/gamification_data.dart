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
import 'package:mimosa/business_logic/models/gamification/gamification_stod_data.dart';

class GamificationData {
  final int checkInTime;
  final int? checkOutTime;
  final int? lastNotificationTime;
  final GamificationStopData checkInStop;
  final GamificationStopData? checkOutStop;
  final GamificationStopData? tripPlannerInitialStop;
  final GamificationStopData? tripPlannerLastStop;

  GamificationData({
    required this.checkInTime,
    this.checkOutTime,
    this.lastNotificationTime,
    required this.checkInStop,
    this.checkOutStop,
    this.tripPlannerInitialStop,
    this.tripPlannerLastStop
  });

  GamificationData copyWith({
    int? checkInTime,
    int? checkOutTime,
    int? lastNotificationTime,
    GamificationStopData? checkInStop,
    GamificationStopData? checkOutStop,
    GamificationStopData? tripPlannerInitialStop,
    GamificationStopData? tripPlannerLastStop,
  })
  {
    return GamificationData(
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      lastNotificationTime: lastNotificationTime ?? this.lastNotificationTime,
      checkInStop: checkInStop ?? this.checkInStop,
      checkOutStop: checkOutStop ?? this.checkOutStop,
      tripPlannerInitialStop: tripPlannerInitialStop ?? this.tripPlannerInitialStop,
      tripPlannerLastStop: tripPlannerLastStop ?? this.tripPlannerLastStop,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'lastNotificationTime': lastNotificationTime,
      'checkInStop': checkInStop.toMap(),
      'checkOutStop': checkOutStop?.toMap(),
      'tripPlannerInitialStop': tripPlannerInitialStop?.toMap(),
      'tripPlannerLastStop': tripPlannerLastStop?.toMap(),
    };
  }

  static GamificationData fromMap(Map map) {
    return fromNullableMap(map)!;
  }

  static GamificationData? fromNullableMap(Map? map) {
    try {
      return map == null
          ? null
          : GamificationData(
              checkInTime: map['checkInTime'],
              checkOutTime: map['checkOutTime'],
              lastNotificationTime: map['lastNotificationTime'],
              checkInStop: GamificationStopData.fromMap(map['checkInStop']),
              checkOutStop: GamificationStopData.fromNullableMap(map['checkOutStop']),
              tripPlannerInitialStop: GamificationStopData.fromNullableMap(map['tripPlannerInitialStop']),
              tripPlannerLastStop: GamificationStopData.fromNullableMap(map['tripPlannerLastStop']),
            );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'GamificationData');
      return null;
    }
  }

  static GamificationData fromJson(String data) {
    return GamificationData.fromMap(json.decode(data));
  }
}