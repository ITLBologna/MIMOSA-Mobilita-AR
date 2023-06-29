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
import 'package:ar_location_view/services/process_sensors_data_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/business_logic/services/i_directions_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_directions_annotations_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/vibrate_controller.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';

class DirectionsAnnotationsService implements IDirectionsAnnotationsService {
  @override
  IDirectionService? directionService;

  DirectionsAnnotationsService();

  @override
  List<ArAnnotation<PolylinedWalkStep>> getAnnotations({
    required Position userPosition,
    required LatLng destinationPosition,
    int maxDistanceInMeters = 1500,
    /// Ignored
    int maxPoi = 1,
    /// Ignored
    int minPoi = 1,
    bool useCache = true})
  {
    if(directionService == null) {
      return <ArAnnotation<PolylinedWalkStep>>[];
    }

    final configService = serviceLocator.get<IConfigurationService>();
    final sensorsService = Get.find<ProcessSensorsDataService>();

    final annotations = directionService!
        .getDirectionsTo(
          destinationPosition: destinationPosition
        )
        // Ignore the first: it's the start position!
        .skip(1)
        .map((d) {
          final distance = Geolocator.distanceBetween(
              userPosition.latitude,
              userPosition.longitude,
              d.step.lat!,
              d.step.lon!
          );

          if(!d.reached) {
            d.reached = distance <= (configService.settings.arSettings.markDirectionAsBurnedWhenCloserThanMeters + sensorsService.getUserPositionAccuracy());
            if(d.reached) {
              VibrateController.vibrate(500);
            }
          }

          return ArAnnotation<PolylinedWalkStep>(
              uid: '${d.projectedLatLng.latitude} - ${d.projectedLatLng.longitude}',
              angle: 0,
              distanceFromUserInMeters: distance,
              maxVisibleDistance: maxDistanceInMeters.toDouble(),
              canOverlayOtherAnnotations: true,
              position: Position(
                latitude: d.step.lat!,
                longitude: d.step.lon!,
                timestamp: DateTime.now(),
                accuracy: 1,
                altitude: 1,
                heading: 1,
                speed: 1,
                speedAccuracy: 1,
              ),
              data: d,
              isVisible: false,
              radarMarkerColorHex: directionsColorHex
          );
        })
        .toList();

    final result = annotations.where((a) => !a.data.reached).toList();
    result.getFirst()?.isVisible = true;
    return result;
  }
}