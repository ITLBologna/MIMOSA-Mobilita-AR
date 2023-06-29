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
import 'package:mimosa/business_logic/models/apis/next_runs/run.dart';

class Runs {
  final List<Run> runs;
  final DateTime? expiresAt;

  Runs({
    this.runs = const [],
    this.expiresAt,
  });

  static Runs fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static Runs? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : Runs(
              expiresAt: DateTime.parse(map['expires_at']),
              runs: listFromMap(map, key: 'data', fromMap: (map) => Run.fromMap(map)),
          );
    }
    catch(e) {
      rethrowJsonToModelMappingError(e, 'Runs');
      return null;
    }
  }

  static Runs fromJson(String data) {
    return Runs.fromMap(json.decode(data));
  }
}