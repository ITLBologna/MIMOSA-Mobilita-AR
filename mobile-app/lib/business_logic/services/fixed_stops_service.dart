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

import 'dart:math';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/interfaces/i_stops_service.dart';

class FixedStopsService implements IStopsService{
  List<TripStop> _stops = [];

  void setStops(List<TripStop> stops) {
    _stops = List.from(stops);
  }

  @override
  Future<Validation<List<TripStop>>> getStops(
      {required double lat,
        required double lon,
        int? maxDistanceInMeters,
        int? maxPoi,
        int? minPoi,
        bool? useCache}) {

    _stops.forEach((s) {
      s.distanceFromPosition = Geolocator.distanceBetween(lat, lon, s.stopLat, s.stopLon);
    });
    _stops.sort((a, b) => a.distanceFromPosition!.compareTo(b.distanceFromPosition!));
    var filteredStops = _stops;

    if(maxDistanceInMeters != null) {
      filteredStops = _stops.where((s) => s.distanceFromPosition! < maxDistanceInMeters).toList();
      if(minPoi != null && filteredStops.length < minPoi && _stops.length > minPoi) {
        filteredStops = _stops.take(minPoi).toList();
      }
    }

    var maxStops = filteredStops.length;
    if(maxPoi != null) {
      maxStops = min(maxStops, maxPoi);
    }

    return filteredStops.take(maxStops).toList().toValidFuture();
  }
}