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

class MimosaRoute {
  final String id;
  final String agencyId;
  final String shortName;
  final String longName;
  final String type;
  final int hexColor;
  final int hexTextColor;

  MimosaRoute({
    required this.id,
    required this.agencyId,
    required this.shortName,
    required this.longName,
    required this.type,
    required this.hexColor,
    required this.hexTextColor
  });

  Map<String, dynamic> toMap() {
    return {
      'route_id': id,
      'agency_id': agencyId,
      'route_short_name': shortName,
      'route_long_name': longName,
      'route_type': type,
      'route_color': hexColor,
      'route_text_color': hexTextColor,
    };
  }

  static MimosaRoute fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static MimosaRoute? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : MimosaRoute(
        id: map['route_id'],
        agencyId: map['agency_id'],
        shortName: map['route_short_name'] ?? '',
        longName: map['route_long_name'] ?? '',
        type: map['route_type'],
        hexColor: hexToInt(map['route_color']) ?? hexToInt('#FFFFFF')!,
        hexTextColor: hexToInt(map['route_text_color']) ?? hexToInt('#000000')!,
      );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'Route');
      return null;
    }
  }

  static MimosaRoute fromJson(String data) {
    return MimosaRoute.fromMap(json.decode(data));
  }
}