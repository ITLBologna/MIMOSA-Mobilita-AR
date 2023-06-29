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
import 'package:get/get.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/controllers/ar_mode_switch_controller.dart';
import 'package:mimosa/controllers/bus_to_track_controller.dart';
import 'package:mimosa/controllers/trips_controller.dart';
import 'package:mimosa/controllers/view_models/bus_to_track_vm.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_route_trips_widgets/ui_controllers/current_trip_index_controller.dart';
import 'package:mimosa/ui/widgets/trip_widget.dart';

class RouteTripsList extends StatefulWidget {
  final MimosaRoute route;
  final void Function(int index) onTripSelected;

  const RouteTripsList({
    required this.route,
    required this.onTripSelected,
    super.key
  });

  @override
  State<RouteTripsList> createState() => _RouteTripsListState();
}

class _RouteTripsListState extends State<RouteTripsList> {
  final _currentTripIndexController = Get.put(CurrentTripIndexController());
  final _arModeSwitchController = Get.find<ArModeSwitchController>();
  final _busToTrackController = Get.find<RouteToTrackController>();
  final _tripsController = Get.find<TripsController>();

  @override
  void initState() {
    _busToTrackController
        .setBusToTrack(
          RouteToTrackVM(
            route: widget.route,
            trip: _tripsController.trips![_currentTripIndexController.tripIndex.value]
          )
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() =>
        ListView.separated(
          shrinkWrap: true,
          itemCount: _arModeSwitchController.isInARMode.value
              ? 1
              : _tripsController.trips!.length,
          separatorBuilder: (context, index) {
            if(index < _tripsController.trips!.length - 1 &&
                _tripsController.trips![index].directionId == 0 &&
                _tripsController.trips![index + 1].directionId == 1) {
              return Divider(
                color: Theme.of(context).textTheme.labelLarge!.color,
                thickness: 0.5,
                height: 10,
                indent: 10,
                endIndent: 10,
              );
            }
            else {
              return Container();
            }
          },
          itemBuilder: (context, index) {
            return Material(
              child: InkWell(
                splashColor: _currentTripIndexController.tripIndex.value == index ? Colors.transparent : null,
                hoverColor: _currentTripIndexController.tripIndex.value == index ? Colors.transparent : null,
                highlightColor: _currentTripIndexController.tripIndex.value == index ? Colors.transparent : null,
                onTap: () {
                  // TODO: check if index compare works
                  if(_arModeSwitchController.isInARMode.value || _currentTripIndexController.tripIndex.value == index) {
                    return;
                  }

                  setState(() {
                    _currentTripIndexController.tripIndex.value = index;
                  });

                  _busToTrackController
                      .setBusToTrack(
                      RouteToTrackVM(
                          route: widget.route,
                          trip: _tripsController.trips![index]
                      )
                  );

                  widget.onTripSelected(index);
                },
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TripWidget(
                        route: widget.route,
                        trip: _arModeSwitchController.isInARMode.value
                            ? _tripsController.trips![_currentTripIndexController.tripIndex.value]
                            : _tripsController.trips![index],
                        isSelected: _arModeSwitchController.isInARMode.value
                            ? true
                            : index == _currentTripIndexController.tripIndex.value,
                        // textColor: Colors.white,
                        size: 35
                    )
                ),
              ),
            );
          },
        )
    );
  }
}