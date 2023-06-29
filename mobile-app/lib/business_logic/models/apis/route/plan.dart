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
import 'package:mimosa/business_logic/models/apis/route/intermediate_stop.dart';
import 'from_to.dart';
import 'itinerary.dart';


class Plan {
	final DateTime? date;
	final PlanFromTo? from;
	final PlanFromTo? to;
	final List<Itinerary> itineraries;

	Plan({
		this.date,
		this.from,
		this.to,
		required this.itineraries
	});

	static Plan fromMap(Map<String, dynamic> map) =>
			Plan(
				date: getDateTimeFromMilliseconds(map['date']),
				from: PlanFromTo.fromNullableMap(map['from']),
				to: PlanFromTo.fromNullableMap(map['to']),
				itineraries: listFromMap(map, key: 'itineraries', fromMap: (m) => Itinerary.fromMap(m)),
			);

	static Plan fromJson(String data) {
		return Plan.fromMap(json.decode(data) as Map<String, dynamic>);
	}
}
