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

class AutocompletePlace {
  final String description;

  final String layer;
  final double latitude;
  final double longitude;
  final String name;
  final String? locality;
  final String? province;
  final String? provinceShort;
  final String? region;
  final String? street;
  final String? housenumber;

  AutocompletePlace(
      {required this.description,
      required this.latitude,
      required this.longitude,
      required this.name,
      this.locality,
      this.province,
      this.provinceShort,
      this.region,
      this.street,
      this.housenumber,
      this.layer = 'street'});

  static AutocompletePlace fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static AutocompletePlace? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : AutocompletePlace(
              description: map['properties']['label'],
              locality: map['properties']['locality'],
              name: map['properties']['name'],
              province: map['properties']['region'],
              provinceShort: map['properties']['region_a'],
              region: map['properties']['macroregion'],
              street: map['properties']['street'],
              housenumber: map['properties']['housenumber'],
              latitude: map['geometry']['coordinates'][1],
              longitude: map['geometry']['coordinates'][0],
              layer: map['properties']['layer'],
            );
    } catch (e) {
      rethrowJsonToModelMappingError(e, 'AutocompletePlace');
      return null;
    }
  }

  static AutocompletePlace fromJson(String data) {
    return AutocompletePlace.fromMap(json.decode(data));
  }
}
