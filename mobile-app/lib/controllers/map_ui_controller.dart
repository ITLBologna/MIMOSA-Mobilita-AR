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

import 'package:ar_location_view/ar_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/extensions_and_utils/future_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:ar_location_view/ar_position.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/navigating_to_stop_controller.dart';
import 'package:mimosa/controllers/view_models/buses_positions_infos_vm.dart';
import 'package:mimosa/controllers/view_models/polyline_projected_stop.dart';
import 'package:mimosa/controllers/view_models/trip_short_name_marker_data.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:mimosa/ui/widgets/annotations/bus_annotation_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/direction_marker_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/highlighted_stop_marker_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/tracked_user_widget.dart';

class MapUIController extends GetxController {
  final centerZoom = Rx<CenterZoom>(CenterZoom(center: LatLng(44.494887, 11.3426163), zoom: 13));
  Marker? userMarker;
  Marker? highlightedStopMarker;
  List<TripShortNameMarkerData> tripShortNamesMarkersData = [];
  List<Marker> trackedBusesMarkers = [];
  List<Marker> directionsMarkers = [];
  List<Marker> tripsMarkers = [];
  List<Marker> headsignMarkers = [];
  List<Polyline> polylines = [];

  List<Marker> getMarkers() {
    List<Marker> markers = [...tripsMarkers];

    markers.addAll(headsignMarkers);

    if(highlightedStopMarker != null) {
      markers.add(highlightedStopMarker!);
    }

    if(userMarker != null) {
      markers.add(userMarker!);
    }

    markers.addAll(trackedBusesMarkers);

    markers.addAll(directionsMarkers);

    return markers;
  }

  void setTrackedBusMarker(List<BusPositionInfoVM> infos, {required BuildContext context}) {
    trackedBusesMarkers
        = infos.map((i) {
          return Marker(
              height: 30,
              width: 100,
              point: LatLng(i.projectedCoords.latitude, i.projectedCoords.longitude),
              rotate: true,
              builder: (context) => // Container(color: Colors.white,child: Text('${i.info.label} | ${i.indexOnPolyline}'),)
              BusAnnotationWidget(text: i.tripShortName, size: 30, textStyle: Theme.of(context).textTheme.headlineSmall,)
          );
        })
        .toList();

    // trackedBusesMarkers.addAll(infos.map((i) {
    //   return Marker(
    //       height: 30,
    //       width: 80,
    //       point: LatLng(i.info.busPosition.latitude, i.info.busPosition.longitude),
    //       rotate: true,
    //       builder: (context) => Container(color: Colors.yellow, child: Text('${i.info.label}'))// lat: ${i.info.busPosition.latitude} lng: ${i.info.busPosition.longitude} plat: ${i.projectedCoords.latitude} plng: ${i.projectedCoords.longitude}'),)
    //     // BusAnnotationWidget(text: i.tripShortName, size: 30, textStyle: Theme.of(context).textTheme.headlineSmall,)
    //   );
    //
    // }));

    WidgetsBinding
        .instance
        .addPostFrameCallback((timeStamp) {
            centerZoom.update((val) { centerZoom.value = val ?? centerZoom.value; });
    });
  }

  Future<ArPosition> setUserMarker({
    bool setInPostframeCallback = false,
    ArPosition? userPosition,
    bool mapRotationEnabled = true,
    double heading = 0,
    required bool arModeOn}) {
      void setMarker(ArPosition position) {
        final clockwiseDegress = heading < 0 ? 360 + heading : heading;
        final latLon = LatLng(position.latitude, position.longitude);
        userMarker = arModeOn
            ? Marker(
                height: 80,
                width: 80,
                point: latLon,
                rotate: true,
                builder: (context) {
                  if(mapRotationEnabled) {
                    return const TrackedUserWidget();
                  }
                  else {
                    return Transform.rotate(
                      angle: clockwiseDegress * pi / 180,
                      child: const TrackedUserWidget(),
                    );
                  }
                }
            )
            : Marker(
                point: latLon,
                rotate: true,
                builder: (context) {
                  return const Icon(Icons.location_history, size: 30, color: Colors.black,);
                }
            );

        centerZoom.update((val) { centerZoom.value = centerZoom.value; });
    }

    final locationService = serviceLocator.get<ILocationService>();
    final futurePosition = userPosition != null
                            ? toFuture(userPosition)
                            : locationService.getLastPosition();
    return futurePosition
        .then((position) {
          if(setInPostframeCallback) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              setMarker(position);
            });
          }
          else {
            setMarker(position);
          }

          return position;
        });
  }

  void setHighlightedStopMarker({
    required String highlightedStopId,
    required List<PolylineProjectedStop> projectedStops,
    required bool arModeOn,
    required LatLng center,
    required double zoom,
    void Function(TripStop)? onNavigateTo,
  }) {

    final navigatingToStopController = Get.find<NavigatingToStopController>();
    if(highlightedStopId.isEmpty && highlightedStopMarker == null) {
      return;
    }

    final ps = projectedStops.getFirstWhere((ps) => ps.stop.stopId == highlightedStopId);
    if(ps == null || !arModeOn) {
      highlightedStopMarker = null;
    }
    else if(highlightedStopMarker?.point == ps.getLatLng()) {
      return;
    }
    else {
      final psLatLng = ps.getLatLng();
      // Check if this markers overlay marker that indicates which bus to take
      final tsn = tripShortNamesMarkersData
          .getFirstWhere((e) => e.latLon == psLatLng)
          ?.tripShortName ?? '';
      // Markers widgets are positioned and requires fixed width; the problem is we do not know it at creation time
      // We estimate a value of 150 relying on resizing text by autosize text. If test is short, marker look oversized,
      // so we do some adjustemnt to calculate marker width based on text length
      var width = 150.0;
      final stopCode = '#${ps.stop.stopCode}';

      if (stopCode.length < 4) {
        width = 50;
      }
      else if (stopCode.length < 7) {
        width = 70.0;
      }
      else if (stopCode.length < 10) {
        width = 100.0;
      }

      // Make space for navigate to icon button
      width += 25.0;

      var height = 35.0;
      // If we need to incorporate bus name, adjust size
      if(tsn.isNotEmpty) {
        width += 25.0;
      }

      highlightedStopMarker = Marker(
          height: height,
          width: width,
          point: psLatLng,
          rotate: true,
          builder: (context) => Obx(() =>
             HighlightedStopMarkerWidget(
              stopName: stopCode,
              borderColor: navigatingToStopController.navigatingToStopId.value == ps.stop.stopId ? directionsColor : Colors.red,
              navigateToIconColor: navigatingToStopController.navigatingToStopId.value == ps.stop.stopId ? directionsColor : Colors.black,
              width: width,
              tripShortName: tsn,
              onNavigate: () => onNavigateTo?.call(ps.stop),
            ),
          )
      );
    }

    WidgetsBinding
        .instance
        .addPostFrameCallback((timeStamp) {
          centerZoom.update((val) { centerZoom.value = CenterZoom(center: center, zoom: zoom); });
        });
  }

  void setDirectionsMarkers(List<ArAnnotation<PolylinedWalkStep>> steps, {required BuildContext context}) {
    const iconSize = 30.0;
    directionsMarkers
        = steps
            .where((s) => !s.data.reached)
            .map((s) {
              return Marker(
                height: iconSize,
                width: iconSize,
                point: LatLng(s.data.projectedLatLng.latitude, s.data.projectedLatLng.longitude),
                rotate: false,
                builder: (context) {

                  if(s.data.info.bearing == null) {
                    return const DirectionMarkerIcon(
                        size: iconSize,
                        iconData: Icons.directions
                    );
                  }

                  var bearing = s.data.info.bearing!;
                  if(bearing < 0) {
                    bearing += 360;
                  }

                  bearing -= 90;
                  return Transform.rotate(
                    angle: bearing * pi / 180,
                    child: const DirectionMarkerIcon(
                      size: iconSize,
                      iconData: Icons.arrow_circle_right
                    )
                  );
                }
              );
            })
            .toList();

    WidgetsBinding
        .instance
        .addPostFrameCallback((timeStamp) {
      centerZoom.update((val) { centerZoom.value = val ?? centerZoom.value; });
    });
  }

  void clearData() {
    tripsMarkers = [];
    headsignMarkers = [];
    polylines = [];
  }
}
