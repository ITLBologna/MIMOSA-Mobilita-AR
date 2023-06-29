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

class UserAccessResponse {
  String? showablePoll;
  bool? gamificationEnabled;

  UserAccessResponse({this.showablePoll, this.gamificationEnabled});

  static UserAccessResponse fromMap(Map<String, dynamic>? map) {
    return fromNullableMap(map)!;
  }

  Map<String, dynamic> toJson() => {
    'showable_poll': showablePoll,
    'gamification_enabled': gamificationEnabled
  };

  static UserAccessResponse? fromNullableMap(Map<String, dynamic>? map) {
    return map == null
        ? null
        : UserAccessResponse(
            showablePoll: map['showable_poll'],
            gamificationEnabled: map['gamification_enabled']
          );
  }

  static UserAccessResponse? fromJson(String data) {
    return UserAccessResponse.fromNullableMap(json.decode(data) as Map<String, dynamic>);
  }
}