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
import 'package:mimosa/business_logic/constants/constants.dart';
import 'package:mimosa/business_logic/enums/trip_modes.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/controllers/bus_to_track_controller.dart';
import 'package:mimosa/controllers/view_models/bus_to_track_vm.dart';
import 'package:mimosa/controllers/view_models/itinerary_vm.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:mimosa/ui/widgets/planned_trip/intinerary_departure_infos.dart';
import 'package:mimosa/ui/widgets/planned_trip/step_preview_widget.dart';

class ItineraryPreviewWidget extends StatefulWidget {
  final bool canTrackBuses;
  final ItineraryVM itinerary;

  const ItineraryPreviewWidget({
      required this.itinerary,
      this.canTrackBuses = false,
      super.key
    });

  @override
  State<ItineraryPreviewWidget> createState() => _ItineraryPreviewWidgetState();
}

class _ItineraryPreviewWidgetState extends State<ItineraryPreviewWidget> {
  late final RouteToTrackController? controller;
  int _selectedIndex = -1;

  @override
  void initState() {
    if(widget.canTrackBuses && Get.isRegistered<RouteToTrackController>()) {
      controller = Get.find<RouteToTrackController>();
      final rswts = widget
          .itinerary
          .getRoutesWithTrips();

      _selectedIndex = rswts.getIndexWhere((rwt) => rwt.route.id != unknownIdStringValue);

      if(_selectedIndex != -1) {
        final btt = rswts[_selectedIndex];
        controller!.setBusToTrack(RouteToTrackVM(route: btt.route, trip: btt.trip));
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final itineraryInfos = widget.itinerary.getItineraryPreviewInfos(context);
    final steps = itineraryInfos.steps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: steps.length,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      final stepWidget = StepPreviewWidget(step: step, isSelected: index == _selectedIndex);
                      if(step.tripMode == TripMode.bus && widget.canTrackBuses) {
                        return InkWell(
                          onTap: () {
                            final btt = widget
                                .itinerary
                                .getRoutesWithTrips()[index];
                            controller?.setBusToTrack(RouteToTrackVM(route: btt.route, trip: btt.trip));
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: stepWidget,
                        );
                      }
                      else {
                        return stepWidget;
                      }
                    },
                    separatorBuilder: (_, __) => const Icon(Icons.arrow_forward_ios, size: 12, color: kDarkRed,),
                  ),
                ),
              ),
              Text(itineraryInfos.duration, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54),)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(itineraryInfos.startTime),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: Text('-'),
              ),
              Text(itineraryInfos.endTime,),
            ],
          ),
          ItineraryDepartureInfosWidget(itinerary: widget.itinerary)
        ],
      ),
    );
  }
}