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

class MimosaRank {
  final int points;
  final int rank;

  MimosaRank({
    required this.points,
    required this.rank,
  });

  static MimosaRank fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static MimosaRank? fromNullableMap(Map<String, dynamic>? map) {
    try {
      if (map == null) return null;
      return MimosaRank(points: map['points'], rank: map['rank'] ?? 0);
    } catch (e) {
      rethrowJsonToModelMappingError(e, 'MimosaRank');
      return null;
    }
  }

  static MimosaRank fromJson(String data) {
    return MimosaRank.fromMap(json.decode(data));
  }
}
