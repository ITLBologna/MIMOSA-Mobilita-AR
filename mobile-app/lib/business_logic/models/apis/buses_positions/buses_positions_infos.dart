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
import 'package:mimosa/business_logic/models/apis/buses_positions/bus_position_info.dart';

class BusesPositionsInfos {
  final List<BusInfo> infos;
  final DateTime expiresAt;

  BusesPositionsInfos({
    required this.infos,
    required this.expiresAt
  });

  static BusesPositionsInfos fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static BusesPositionsInfos? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : BusesPositionsInfos(
              expiresAt: DateTime.parse(map['expires_at']),
              infos: listFromMap(map, key: 'data', fromMap: (map) => BusInfo.fromMap(map))
            );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'BusesPositionsInfos');
      return null;
    }
  }

  static BusesPositionsInfos fromJson(String data) {
    return BusesPositionsInfos.fromMap(json.decode(data));
  }
}