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
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/interfaces/i_annotations_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_stops_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class TripStopAnnotationsService extends IAnnotationsService<TripStop> {
  final String stopsServiceInstanceName;
  TripStopAnnotationsService(this.stopsServiceInstanceName);

  @override
  Future<Validation<List<ArAnnotation<TripStop>>>> getAnnotations({
    required Position userPosition,
    Position? destinationPosition,
    String? stopId,
    int maxDistanceInMeters = 1500,
    int maxPoi = 100,
    int minPoi = 2,
    bool useCache = false})
  {
    return serviceLocator
        .get<IStopsService>(instanceName: stopsServiceInstanceName)
        .getStops(
          lat: userPosition.latitude,
          lon: userPosition.longitude,
          maxDistanceInMeters: maxDistanceInMeters,
          maxPoi: maxPoi,
          minPoi: minPoi)
        .map(
            (stops) => stops.map((s) {
              return ArAnnotation<TripStop>(
                  uid: s.stopId,
                  angle: 0,
                  distanceFromUserInMeters: s.distanceFromPosition ?? 0,
                  maxVisibleDistance: maxDistanceInMeters.toDouble(),
                  position: Position(
                    longitude: s.stopLon,
                    latitude: s.stopLat,
                    timestamp: DateTime.now(),
                    accuracy: 1,
                    altitude: 1,
                    heading: 1,
                    speed: 1,
                    speedAccuracy: 1,
                  ),
                  data: s,
                  highlightMode: HighlightMode.nearest
              );
            }).toList()
        );
  }
}