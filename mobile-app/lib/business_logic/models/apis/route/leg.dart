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

import 'package:mimosa/business_logic/enums/trip_modes.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/otp_string_extensions.dart';
import 'package:mimosa/business_logic/models/apis/route/intermediate_stop.dart';

import 'from_to.dart';
import 'leg_geometry.dart';
import 'walk_step.dart';

class Leg {
	final DateTime? startTime;
	final DateTime? endTime;
	final int? departureDelay;
	final int? arrivalDelay;
	final bool? realTime;
	final double? distanceInMeters;
	final int? generalizedCost;
	final bool? pathway;
	final TripMode mode;
	final bool? transitLeg;
	final String? route;
	final int? agencyTimeZoneOffsetInMilliseconds;
	final bool? interlineWithPreviousLeg;
	final LegFromTo? from;
	final LegFromTo? to;
	final LegGeometry? legGeometry;
	final List<WalkStep> steps;
	final double? durationInSeconds;
	final bool? rentedBike;
	final bool? walkingBike;
	final List<IntermediateStop> intermediateStops;
	final String? tripShortName;
	final String? agencyId;
	final String? agencyName;
	final String? agencyUrl;
	final int? routeColor;
	final int? routeType;
	final String? routeId;
	final String? routeShortName;
	final String? routeLongName;
	final String? headsign;
	final int? routeTextColor;
	final String? tripId;
	final String? serviceDate;

	const Leg({
		this.startTime,
		this.endTime,
		this.departureDelay,
		this.arrivalDelay,
		this.realTime,
		this.distanceInMeters,
		this.generalizedCost,
		this.pathway,
		required this.mode,
		this.transitLeg,
		this.route,
		this.agencyTimeZoneOffsetInMilliseconds,
		this.interlineWithPreviousLeg,
		this.from,
		this.to,
		this.legGeometry,
		this.steps = const [],
		this.durationInSeconds,
		this.rentedBike,
		this.walkingBike,
		this.intermediateStops = const [],
		this.tripShortName,
		this.agencyId,
		this.agencyName,
		this.agencyUrl,
		this.routeColor,
		this.routeType,
		this.routeId,
		this.routeShortName,
		this.routeLongName,
		this.headsign,
		this.routeTextColor,
		this.tripId,
		this.serviceDate
	});

	static Leg fromMap(Map<String, dynamic> map) => Leg(
		startTime: getDateTimeFromMilliseconds(map['startTime']),
		endTime: getDateTimeFromMilliseconds(map['endTime']),
		departureDelay: map['departureDelay'],
		arrivalDelay: map['arrivalDelay'],
		realTime: map['realTime'],
		distanceInMeters: map['distance'],
		generalizedCost: map['generalizedCost'],
		pathway: map['pathway'],
		mode: TripMode.values.getMatchOnValue(map['mode'], orElse: () => TripMode.unknown)!,
		transitLeg: map['transitLeg'],
		route: map['route'],
		agencyName: map['agencyName'],
		agencyUrl: map['agencyUrl'],
		agencyTimeZoneOffsetInMilliseconds: map['agencyTimeZoneOffset'],
		routeColor: hexToInt(map['routeColor']),
		routeType: map['routeType'],
		routeId: purgeIdFromIndex(map['routeId']),
		routeTextColor: hexToInt(map['routeTextColor']),
		interlineWithPreviousLeg: map['interlineWithPreviousLeg'],
		tripShortName: map['tripShortName'] ?? map['routeShortName'],
		headsign: map['headsign'],
		agencyId: purgeIdFromIndex(map['agencyId']),
		tripId: purgeIdFromIndex(map['tripId']),
		serviceDate: map['serviceDate'],
		from: LegFromTo.fromNullableMap(map['from']),
		to: LegFromTo.fromNullableMap(map['to']),
		intermediateStops: listFromMap(map, key: 'intermediateStops', fromMap: (m) => IntermediateStop.fromMap(m)),
		legGeometry: LegGeometry.fromNullableMap(map['legGeometry']),
		steps: listFromMap(map, key: 'steps', fromMap: (m) => WalkStep.fromMap(m)),
		routeShortName: map['routeShortName'],
		routeLongName: map['routeLongName'],
		durationInSeconds: map['duration'],
	);

	factory Leg.fromJson(String data) {
		return Leg.fromMap(json.decode(data) as Map<String, dynamic>);
	}
}

