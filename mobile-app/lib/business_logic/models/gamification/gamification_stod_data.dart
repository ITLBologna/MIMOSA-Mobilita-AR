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

class GamificationStopData {
  final String id;
  final String name;
  final String code;
  final double lat;
  final double lon;

  GamificationStopData({
    required this.id,
    required this.name,
    required this.code,
    required this.lat,
    required this.lon}
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'lat': lat,
      'lon': lon,
    };
  }

  static GamificationStopData fromMap(Map map) {
    return fromNullableMap(map)!;
  }

  static GamificationStopData? fromNullableMap(Map? map) {
    try {
      return map == null
          ? null
          : GamificationStopData(
              id: map['id'],
              name: map['name'],
              code: map['code'],
              lat: map['lat'],
              lon: map['lon'],
            );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'GamificationStopData');
      return null;
    }
  }

  static GamificationStopData fromJson(String data) {
    return GamificationStopData.fromMap(json.decode(data));
  }
}