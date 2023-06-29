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

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/extensions_and_utils/turf_extensions.dart';
import 'package:turf/turf.dart';

extension PolylineExt on String {
  List<LatLng> toPolyLine() {
    var polylinePoints = PolylinePoints();

    return polylinePoints
        .decodePolyline(this)
        .map((pp) => LatLng(pp.latitude, pp.longitude))
        .toList();
  }

  LineString toLineString() {
    final coords = toPolyLine()
        .map((c) => Position(c.longitude, c.latitude))
        .toList();

    return LineString(coordinates: coords);
  }
}

extension ListLatLonExt on List<LatLng> {
  LineString toLineString() {
    final coords = map((c) => Position.named(lat: c.latitude, lng: c.longitude))
        .toList();

    return LineString(coordinates: coords);
  }
  
  LatLng projectPoint(LatLng point) {
    return projectLatLon(point.latitude, point.longitude);
  }

  LatLng projectLatLon(double lat, double lon) {
    final turfPoint = Point(coordinates: Position.named(lng: lon, lat: lat));
    Feature<Point>? projectedPoint;
    if(isNotEmpty) {
      projectedPoint = nearestPointOnLine(
          toLineString(),
          turfPoint,
          Unit.meters
      );
      
      return projectedPoint.getLatLng();
    }
    
    return LatLng(lat, lon);
  }
}