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

class WalkStep {
	final double? distance;
	final String? relativeDirection;
	final String? streetName;
	final String? absoluteDirection;
	final bool? stayOn;
	final bool? area;
	final bool? bogusName;
	final double? lon;
	final double? lat;
	final String? elevation;
	final bool? walkingBike;

	WalkStep({
		this.distance,
		this.relativeDirection,
		this.streetName,
		this.absoluteDirection,
		this.stayOn,
		this.area,
		this.bogusName,
		this.lon,
		this.lat,
		this.elevation,
		this.walkingBike,
	});

	static WalkStep fromMap(Map<String, dynamic> map) => WalkStep(
				distance: map['distance'],
				relativeDirection: map['relativeDirection'],
				streetName: map['streetName'],
				absoluteDirection: map['absoluteDirection'],
				stayOn: map['stayOn'],
				area: map['area'],
				bogusName: map['bogusName'],
				lon: map['lon'],
				lat: map['lat'],
				elevation: map['elevation'],
				walkingBike: map['walkingBike'],
			);

	factory WalkStep.fromJson(String data) {
		return WalkStep.fromMap(json.decode(data) as Map<String, dynamic>);
	}
}
