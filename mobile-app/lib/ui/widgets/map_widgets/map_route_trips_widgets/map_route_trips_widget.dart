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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/services/fixed_stops_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_stops_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/business_logic/services/services_constants.dart';
import 'package:mimosa/controllers/no_solutions_found_controller.dart';
import 'package:mimosa/controllers/trips_controller.dart';
import 'package:mimosa/controllers/view_models/route_with_trip.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/library_widgets/controller_driven_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_route_trips_widgets/route_trips_list.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_route_trips_widgets/ui_controllers/current_trip_index_controller.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_routes_builder_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/headsign_flag_marker.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/tooltip_marker.dart';

class MapRouteTripsWidget extends MapRoutesBuilderWidget {
  final _currentTripIndexController = Get.put(CurrentTripIndexController());
  final _tripsController = Get.put(TripsController());
  final MimosaRoute route;
  final StreamController<Trip> selectedTripStreamController = StreamController<
      Trip>.broadcast();

  MapRouteTripsWidget({required this.route, super.key});

  @override
  List<RouteWithTrip> getRoutesWithTrips() {
    final index = _currentTripIndexController.tripIndex.value;
    if (_tripsController.trips?.isNotEmpty == true) {
      final routeWithStops = RouteWithTrip(
        route: route,
        trip: _tripsController.trips![index],
      );

      return [routeWithStops];
    }

    return <RouteWithTrip>[];
  }


  @override
  Stream<Trip> selectedTripStream() => selectedTripStreamController.stream;

  @override
  MimosaRoute getRoute(String stopId) {
    return route;
  }

  // TODO: unused parameter?
  @override
  Trip getTrip(String stopId) {
    return _tripsController.trips![_currentTripIndexController.tripIndex.value];
  }

  @override
  Widget getHeadsignMarker(String stopName) {
    return TooltipMarker(stopName: stopName, icon: const HeadsignFlagMarker());
  }

  @override
  Widget getStartMarker(String tripShortName, String stopName) {
    return TooltipMarker(
      stopName: stopName,
      icon: Container(
          height: 40,
          width: 40,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.white),
          child: Text(tripShortName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery
        .of(context)
        .size
        .height / 4;
    return BottomAppBar(
      child: ControllerDrivenWidget<TripsController, List<Trip>, String>(
          requestData: route.id,
          controller: _tripsController,
          getBody: (data) {
            final fixedStopsService = serviceLocator.get<IStopsService>(
                instanceName: fixedStopsServiceInstanceName)
            as FixedStopsService;
            if (_tripsController.trips!.isEmpty) {
              fixedStopsService.setStops([]);
              final noSolutionsController =
              Get.find<NoSolutionsFoundController>(tag: tripsMapPageRoute);
              noSolutionsController.noSolutions = true;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                noSolutionsController.update();
              });
              return Container();
            }

            fixedStopsService.setStops(_tripsController
                .trips![_currentTripIndexController.tripIndex.value].stops);

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              final routesWithTrips = getRoutesWithTrips();
              drawTripsPolylineAndStops?.call(routesWithTrips);
            });
            return Container(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: Theme
                              .of(context)
                              .primaryColor, width: 5)),
                  color: BottomAppBarTheme
                      .of(context)
                      .color),
              padding: const EdgeInsets.all(5),
              // color: Colors.red,
              child: Scrollbar(
                  thumbVisibility: false,
                  child: RouteTripsList(
                    route: route,
                    onTripSelected: (index) {
                      final fixedStopsService =
                      serviceLocator.get<IStopsService>(
                          instanceName: fixedStopsServiceInstanceName)
                      as FixedStopsService;
                      final selectedTrip = _tripsController.trips![index];
                      fixedStopsService.setStops(selectedTrip.stops);
                      final routesWithTrips = getRoutesWithTrips();
                      MatomoTracker.instance.trackEvent(
                          eventCategory: 'Trip',
                          action: selectedTrip.id,
                          eventName: 'selectTripInMap');
                      selectedTripStreamController.sink.add(
                          _tripsController.trips![index]);
                      drawTripsPolylineAndStops?.call(routesWithTrips);
                    },
                  )),
            );
          }),
    );
  }
}
