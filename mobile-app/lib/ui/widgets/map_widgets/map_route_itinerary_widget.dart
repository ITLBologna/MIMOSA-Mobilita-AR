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
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/services/fixed_stops_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_stops_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/business_logic/services/services_constants.dart';
import 'package:mimosa/controllers/view_models/itinerary_vm.dart';
import 'package:mimosa/controllers/view_models/route_with_trip.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_routes_builder_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/tooltip_marker.dart';
import 'package:mimosa/ui/widgets/planned_trip/itinerary_preview_widget.dart';

class MapRouteItineraryWidget extends MapRoutesBuilderWidget {
  final ItineraryVM itinerary;

  MapRouteItineraryWidget({required this.itinerary, super.key});

  @override
  List<RouteWithTrip> getRoutesWithTrips() {
    return itinerary.getRoutesWithTrips();
  }

  @override
  MimosaRoute getRoute(String stopId) {
    return itinerary.getRouteWithTripFrom(stopId, busTrip: true).route;
  }

  @override
  Trip getTrip(String stopId) {
    return itinerary.getRouteWithTripFrom(stopId, busTrip: true).trip;
  }

  @override
  Widget getHeadsignMarker(String stopName) {
    return TooltipMarker(
      stopName: stopName,
      icon: Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: lightMimosaYellow),
          child: const Icon(
            Icons.exit_to_app,
            size: 20,
          )),
    );
  }

  @override
  Widget getStartMarker(String tripShortName, String stopName) {
    return TooltipMarker(
      stopName: stopName,
      icon: Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: lightMimosaYellow),
          child: Center(
              child: Text(
            tripShortName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixedStopsService = serviceLocator.get<IStopsService>(
        instanceName: fixedStopsServiceInstanceName) as FixedStopsService;
    fixedStopsService.setStops(itinerary.getDistinctStops());

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final routesWithTrips = getRoutesWithTrips();
      drawTripsPolylineAndStops?.call(routesWithTrips);
    });
    return BottomAppBar(
      child: SafeArea(
        child: Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).primaryColor, width: 5)),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(15),
            child: ItineraryPreviewWidget(
              itinerary: itinerary,
              canTrackBuses: true,
            )),
      ),
    );
  }

  @override
  Stream<Trip>? selectedTripStream() {
    return null;
  }
}
