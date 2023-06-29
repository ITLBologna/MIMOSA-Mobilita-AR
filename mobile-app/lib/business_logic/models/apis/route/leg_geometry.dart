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

class LegGeometry {
	String? points;
	int? length;
	LegGeometry({this.points, this.length});

	static LegGeometry? fromNullableMap(Map<String, dynamic>? map) {
		return map == null
				? null
				: LegGeometry(
						points: map['points'],
						length: map['length'],
					);
	}


	static LegGeometry? fromJson(String data) {
		return LegGeometry.fromNullableMap(json.decode(data) as Map<String, dynamic>);
	}
}
