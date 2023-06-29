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

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/constants/constants.dart';
import 'package:mimosa/business_logic/enums/trip_modes.dart';
import 'package:mimosa/business_logic/extensions_and_utils/date_time_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/turf_extensions.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/route/itinerary.dart';
import 'package:mimosa/business_logic/models/apis/route/leg.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/i_directions_service.dart';
import 'package:mimosa/controllers/view_models/irtinerary_preview.dart';
import 'package:mimosa/controllers/view_models/itinerary_preview_step.dart';
import 'package:mimosa/controllers/view_models/leg_vm.dart';
import 'package:mimosa/controllers/view_models/route_with_trip.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mimosa/business_logic/extensions_and_utils/polyline_extension.dart';

class ItineraryVM implements IDirectionService {
  final Itinerary itinerary;
  Map<String, List<PolylinedWalkStep>> _calculatedDirections = {};

  ItineraryVM(this.itinerary);

  String getItineraryStartTime({required BuildContext context}) {
    final leg = itinerary.legs.getFirst();
    return _getTime(leg?.startTime, 0, context: context);
  }

  DateTime? getItineraryStartDateTime() {
    return itinerary.legs.getFirst()?.startTime;
  }

  String getItineraryEndTime({required BuildContext context}) {
    final leg = itinerary.legs.getLast();
    return _getTime(leg?.endTime, 0, context: context);
  }

  String _getTime(DateTime? legTime, int? timezoneOffset, {required BuildContext context}) {
    String time = '__';
    if(legTime != null) {
      time = legTime
              .add(Duration(milliseconds: timezoneOffset ?? 0))
              .format(AppLocalizations.of(context)!.time_format, context);
    }

    return time;
  }

  String getItineraryDuration({required BuildContext context}) {
    return _getTotalTime(
        start: itinerary.legs.getFirst()?.startTime,
        end: itinerary.legs.getLast()?.endTime,
        context: context
    );
  }

  String _getTotalTime({DateTime? start, DateTime? end, required BuildContext context}) {
    final duration = end?.getDifference(start);

    if(duration != null) {
      final seconds = duration.inSeconds.remainder(60).abs();
      var minutes = duration.inMinutes.remainder(60).abs();
      if(seconds > 15) {
         minutes ++;
      }

      String result;
      if(duration.inHours == 0) {
        result = '$minutes ${AppLocalizations.of(context)!.minute_placemark}';
      }
      else {
        result = '${duration.inHours} ${AppLocalizations.of(context)!.hour_placemark} $minutes ${AppLocalizations.of(context)!.minute_placemark}';
      }

      if(duration.isNegative) {
        result += ' ${AppLocalizations.of(context)!.ago_placemark}';
      }
      return result;
    }
    else {
      return '__ ${AppLocalizations.of(context)!.hour_placemark} __ ${AppLocalizations.of(context)!.minute_placemark}';
    }
  }

  String getLegTime(Leg? leg, {required BuildContext context}) {
    return _getTotalTime(
      start: leg?.startTime,
      end: leg?.endTime,
      context: context
    );
  }

  String? getFirstBusStopName() {
    return itinerary
        .legs
        .getFirstWhere((l) => l.mode == TripMode.bus)
        ?.from
        ?.name;
  }

  String? getBusDepartureInfos({required BuildContext context}) {
    final stop = itinerary
        .legs
        .getFirstWhere((l) => l.mode == TripMode.bus);
    final stopName = stop
        ?.from
        ?.name;

    String? result;
    if(stopName != null) {
      result =  _getTotalTime(start: DateTime.now(), end: stop?.startTime, context: context);
      result += ' ${AppLocalizations.of(context)!.departure_from_placemark} $stopName';
    }

    return result;
  }

  ItineraryPreview getItineraryPreviewInfos(BuildContext context) {
    final steps = itinerary.legs.map((l)
                    => ItineraryPreviewStep(
                        color: l.mode == TripMode.walk
                                  ? hexToInt('#000')!
                                  : l.routeColor ?? hexToInt('#fff')!,
                        textColor: l.routeTextColor ?? hexToInt('#000')!,
                        tripMode: l.mode,
                        tripShortName: l.tripShortName,
                        duration: getLegTime(l, context: context))
                  )
                  .toList();

    return ItineraryPreview(
        duration: getItineraryDuration(context: context),
        startTime: getItineraryStartTime(context: context),
        endTime: getItineraryEndTime(context: context),
        firstBusStopName: getFirstBusStopName(),
        steps: steps
    );
  }

  List<RouteWithTrip> getRoutesWithTrips() {
    return itinerary
            .legs
            .map((l) => RouteWithTrip(route: l.toMimosaRoute(), trip: l.toTrip()))
            .toList();
  }

  List<TripStop> getDistinctStops() {
    return itinerary
        .legs.expand((l) => l.getTripStops())
        .where((tripStop) => tripStop.stopId != unknownStringValue )
        .toSet()
        .toList();
  }

  RouteWithTrip getRouteWithTripFrom(String stopId, {bool busTrip = false}) {
    final routesWithTrips = getRoutesWithTrips();
    return routesWithTrips
        .getFirstWhere(
            (rwt) => rwt.trip.stops.where((s) => s.stopId == stopId).isNotEmpty &&
                (!busTrip || rwt.trip.id != unknownIdStringValue)
            )
        ??
        routesWithTrips.first;
  }

  MimosaRoute getRoute(String stopId) {
    final routesWithTrips = getRoutesWithTrips();
    return routesWithTrips
        .getFirstWhere((rwt) => rwt.trip.stops.where((s) => s.stopId == stopId).isNotEmpty)?.route
        ??
        routesWithTrips.first.route;
  }

  @override
  List<PolylinedWalkStep> getDirectionsTo({required LatLng destinationPosition}) {
    final leg = _getWalkLegTo(destinationPosition);

    if(leg == null) {
      return <PolylinedWalkStep>[];
    }

    var steps = leg.steps;
    final polyline = leg.legGeometry?.points?.toPolyLine();
    if(polyline != null) {
      if(_calculatedDirections[leg.legGeometry!.points!] != null) {
        return _calculatedDirections[leg.legGeometry!.points!]!;
      }

      _calculatedDirections[leg.legGeometry!.points!] = steps.map((s) {
        final projected = polyline.projectLatLon(s.lat!, s.lon!);
        final info = calcDirectionPointPolylineInfo(polyline, projected);
        return PolylinedWalkStep(
          step: s,
          projectedLatLng: projected,
          info: info,
        );
      })
      .toList();

      return _calculatedDirections[leg.legGeometry!.points!]!;
    }

    return <PolylinedWalkStep>[];
  }

  bool knowsWalkDirectionsTo(LatLng destinationPosition) {
    return _getWalkLegTo(destinationPosition) != null;

  }

  Leg? _getWalkLegTo(LatLng destinationPosition) {
    return itinerary
        .legs
        .getFirstWhere((l) {
      if(l.mode != TripMode.walk) {
        return false;
      }
      final distance = Geolocator.distanceBetween(
          l.to!.lat!,
          l.to!.lon!,
          destinationPosition.latitude,
          destinationPosition.longitude);
      return distance <= 1;
    });
  }

  List<LatLng> walkDirectionsToPolyline(LatLng destinationPosition) {
    return _getWalkLegTo(destinationPosition)
        ?.legGeometry
        ?.points
        ?.toPolyLine() ?? [];
  }
}