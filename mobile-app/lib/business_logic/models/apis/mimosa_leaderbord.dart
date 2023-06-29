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
import 'package:mimosa/business_logic/models/apis/mimosa_rank.dart';

class MimosaLeaderboard {
  final List<MimosaRank> mimosaRanks;
  final MimosaRank? userRank;

  MimosaLeaderboard({required this.mimosaRanks, required this.userRank});

  static MimosaLeaderboard fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static MimosaLeaderboard? fromNullableMap(Map<String, dynamic>? map) {
    try {
      if (map == null) return null;
      List<MimosaRank> ranks = map['leaderboard'].map<MimosaRank>((e) {
        var mimosaRank = MimosaRank.fromMap(e);
        return mimosaRank;
      }).toList();

      MimosaLeaderboard mimosaLeaderboard = MimosaLeaderboard(
        mimosaRanks: ranks,
        userRank: MimosaRank.fromMap(map['user'] ?? Map),
      );
      return mimosaLeaderboard;
    } catch (e) {
      rethrowJsonToModelMappingError(e, 'MimosaLeaderboard');
      return null;
    }
  }

  static MimosaLeaderboard fromJson(String data) {
    return MimosaLeaderboard.fromMap(json.decode(data));
  }
}
