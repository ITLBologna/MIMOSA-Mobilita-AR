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

class Agency {
  final String id;
  final String name;
  final String? url;
  final String? timezone;
  final String? language;
  final String? phone;
  final String? fareUrl;
  final double? lat;
  final double? lon;

  Agency({
    required this.id,
    required this.name,
    required this.url,
    this.timezone,
    this.language,
    this.phone,
    this.fareUrl,
    this.lat,
    this.lon
  });

  static Agency fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static Agency? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : Agency(
              id: map['agency_id'],
              name: map['agency_name'],
              url: map['agency_url'],
              timezone: map['agency_timezone'],
              language: map['agency_lang'],
              phone: map['agency_phone'],
              fareUrl: map['agency_fare_url'],
              lat: map['agency_lat'],
              lon: map['agency_lon']
            );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'Agency');
      return null;
    }
  }

  static Agency fromJson(String data) {
    return Agency.fromMap(json.decode(data));
  }
}