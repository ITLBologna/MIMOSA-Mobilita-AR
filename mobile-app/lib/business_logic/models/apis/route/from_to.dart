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
import 'package:mimosa/business_logic/extensions_and_utils/otp_string_extensions.dart';

class PlanFromTo {
	final String? name;
	final double? lon;
	final double? lat;
	final String? vertexType;

	const PlanFromTo({
		this.name,
		this.lon,
		this.lat,
		this.vertexType});

	static PlanFromTo? fromNullableMap(Map<String, dynamic>? map) {
		return map == null
			? null
			: PlanFromTo(
					name: map['name'],
					lon: map['lon'],
					lat: map['lat'],
					vertexType: map['vertexType'],
				);
	}

	static PlanFromTo? fromJson(String data) {
		return PlanFromTo.fromNullableMap(json.decode(data) as Map<String, dynamic>);
	}
}

class LegFromTo extends PlanFromTo {
	final DateTime? departure;
	final DateTime? arrival;
	final String? stopId;
	final String? stopCode;
	final String? zoneId;
	final int? stopIndex;
	final int? stopSequence;


	LegFromTo({
		PlanFromTo? planFrom,
		this.arrival,
		this.stopId,
		this.stopCode,
		this.departure,
		this.zoneId,
		this.stopIndex,
		this.stopSequence,
	}) : super(name: planFrom?.name, lon: planFrom?.lon, lat: planFrom?.lat, vertexType: planFrom?.vertexType);


	static LegFromTo? fromNullableMap(Map<String, dynamic>? map) {
		try {
			return map == null
					? null
					: LegFromTo(
				planFrom: PlanFromTo.fromNullableMap(map),
				arrival: getDateTimeFromMilliseconds(map['arrival']),
				stopId: purgeIdFromIndex(map['stopId']),
				stopCode: map['stopCode'],
				departure: getDateTimeFromMilliseconds(map['departure']),
				zoneId: map['zoneId'],
				stopIndex: map['stopIndex'],
				stopSequence: map['stopSequence'],
			);
		}
		catch(e) {
			rethrowJsonToModelMappingError(e, 'LegFromTo');
			return null;
		}
	}

	static LegFromTo? fromJson(String data) {
		return LegFromTo.fromNullableMap(json.decode(data) as Map<String, dynamic>);
	}
}
