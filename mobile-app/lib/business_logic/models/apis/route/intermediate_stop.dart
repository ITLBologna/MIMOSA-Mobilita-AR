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

import 'package:collection/collection.dart';
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/otp_string_extensions.dart';
import 'package:mimosa/business_logic/models/apis/route/from_to.dart';

class IntermediateStop extends LegFromTo {
	IntermediateStop({
		super.planFrom,
		super.stopId,
		super.stopCode,
		super.arrival,
		super.departure,
		super.zoneId,
		super.stopIndex,
		super.stopSequence,
	});

	static IntermediateStop fromMap(Map<String, dynamic> map) {
		return IntermediateStop(
			planFrom: PlanFromTo.fromNullableMap(map),
			stopId: purgeIdFromIndex(map['stopId']),
			stopCode: map['stopCode'],
			arrival: getDateTimeFromMilliseconds(map['arrival']),
			departure: getDateTimeFromMilliseconds(map['departure']),
			zoneId: map['zoneId'],
			stopIndex: map['stopIndex'],
			stopSequence: map['stopSequence'],
		);
	}

	static IntermediateStop fromJson(String data) {
		return IntermediateStop.fromMap(json.decode(data) as Map<String, dynamic>);
	}
}
