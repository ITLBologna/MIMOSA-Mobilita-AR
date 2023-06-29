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
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';

import 'leg.dart';

class Itinerary {
	final int? durationInSeconds;
	final DateTime? startTime;
	final DateTime? endTime;
	final int? walkTimeInSeconds;
	final int? transitTimeInSeconds;
	final int? waitingTimeInSeconds;
	final double? walkDistanceInMeters;
	final bool? walkLimitExceeded;
	final int? generalizedCost;
	final double? elevationLost;
	final double? elevationGained;
	final int? transfers;
	final List<Leg> legs;
	final bool? tooSloped;
	final bool? arrivedAtDestinationWithRentedBicycle;

	Itinerary({
		this.durationInSeconds,
		this.startTime,
		this.endTime,
		this.walkTimeInSeconds,
		this.transitTimeInSeconds,
		this.waitingTimeInSeconds,
		this.walkDistanceInMeters,
		this.walkLimitExceeded,
		this.generalizedCost,
		this.elevationLost,
		this.elevationGained,
		this.transfers,
		this.legs = const [],
		this.tooSloped,
		this.arrivedAtDestinationWithRentedBicycle,
	});

	static Itinerary fromMap(Map<String, dynamic> map) => Itinerary(
				durationInSeconds: map['duration'],
				startTime: getDateTimeFromMilliseconds(map['startTime']),
				endTime: getDateTimeFromMilliseconds(map['endTime']),
				walkTimeInSeconds: map['walkTime'],
				transitTimeInSeconds: map['transitTime'],
				waitingTimeInSeconds: map['waitingTime'],
				walkDistanceInMeters: map['walkDistance'],
				walkLimitExceeded: map['walkLimitExceeded'],
				generalizedCost: map['generalizedCost'],
				elevationLost: map['elevationLost'],
				elevationGained: map['elevationGained'],
				transfers: map['transfers'],
				legs: listFromMap(map, key: 'legs', fromMap: (m) => Leg.fromMap(m)),
				tooSloped: map['tooSloped'],
				arrivedAtDestinationWithRentedBicycle: map['arrivedAtDestinationWithRentedBicycle'],
			);


	static Itinerary fromJson(String data) {
		return Itinerary.fromMap(json.decode(data) as Map<String, dynamic>);
	}
}
