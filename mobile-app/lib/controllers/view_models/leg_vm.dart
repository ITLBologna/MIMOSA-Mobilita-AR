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

import 'package:mimosa/business_logic/constants/constants.dart';
import 'package:mimosa/business_logic/extensions_and_utils/date_time_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/route/from_to.dart';
import 'package:mimosa/business_logic/models/apis/route/leg.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';

extension LegVM on Leg {

  MimosaRoute toMimosaRoute() {
    return MimosaRoute(
      id: routeId ?? unknownIdStringValue,
      agencyId: agencyId ?? unknownStringValue,
      shortName: tripShortName ?? unknownIdStringValue,
      longName: route ?? unknownStringValue,
      type: routeType?.toString() ?? unknownIdStringValue,
      hexColor: routeColor ?? whiteColorInt(),
      hexTextColor: routeTextColor ?? blackColorInt(),
    );
  }

  Trip toTrip() {
    return Trip(
        id: tripId ?? unknownIdStringValue,
        routeId: routeId ?? unknownIdStringValue,
        headsign: headsign,
        shortName: tripShortName ?? unknownIdStringValue,
        directionId: -1,
        shapeId: unknownIdStringValue,
        shapePolyline: legGeometry?.points ?? '',
        stops: getTripStops()
    );
  }

  List<TripStop> getTripStops() {
      return _getStops().map((s) => TripStop(
          stopId: s.stopId ?? unknownStringValue,
          stopCode: s.stopCode ?? unknownStringValue,
          stopName: s.name ?? unknownStringValue,
          stopLat: s.lat ?? 0,
          stopLon: s.lon ?? 0,
          arrivalTime: s.arrival?.toTimeString(),
          departureTime: s.departure?.toTimeString(),
          stopSequence: s.stopSequence)
      ).toList();
  }

  List<LegFromTo> _getStops() {
    final fromTos = <LegFromTo>[];
    if(from != null) {
      fromTos.add(from!);
    }

    fromTos.addAll(intermediateStops);

    if(to != null) {
      fromTos.add(to!);
    }

    return fromTos;
  }
}