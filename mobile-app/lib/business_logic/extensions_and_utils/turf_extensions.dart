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

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/polyline_extension.dart';
import 'package:turf/turf.dart' as turf;

extension FeaturePoint on turf.Feature<turf.Point> {
  double? getLat() => geometry?.coordinates.lat.toDouble();
  double? getLon() => geometry?.coordinates.lng.toDouble();
  LatLng getLatLng() => LatLng(getLat()!, getLon()!);
}

class PointOnPolylineInfo {
  final LatLng latLon;
  final int indexNearestPreviousPoint;
  final double? bearing;

  PointOnPolylineInfo(
    this.latLon,
    {
      required this.indexNearestPreviousPoint,
      required this.bearing
    }
  );

}

List<LatLng> recInterpolatePolyline(List<LatLng> poly, int index, double distanceBetweenPointsInMeters) {
  const d = Distance();
  var newPoly = <LatLng>[];

  while(index < poly.length - 1) {
    final cur = poly[index];
    final next = poly[index + 1];

    var dist = Geolocator.distanceBetween(
        cur.latitude,
        cur.longitude,
        next.latitude,
        next.longitude);

    int nPoints = dist ~/ distanceBetweenPointsInMeters;

    var bearingCurNext = Geolocator.bearingBetween(
        cur.latitude,
        cur.longitude,
        next.latitude,
        next.longitude
    );

    final newPoints = <LatLng>[];
    for(int i = 1; i <= nPoints; i ++) {
      var newLatLng = d.offset(cur, distanceBetweenPointsInMeters * i, bearingCurNext);
      newPoints.add(newLatLng);
    }

    if(newPoints.isNotEmpty) {
      newPoly.addAll(<LatLng>[...[cur], ...newPoints]);
    }

    index ++;
  }

  return newPoly;
}

/// To find the index of the previous point we must find the point between them the point
/// has the same bearing. Other than bearing, the distance between the previous point and the point must be lesser
/// then the distance between the previous one and the next one (in other words, the point must be between the previous and next point)
int nearestPreviousPointIndexOnLine(List<LatLng> poly, LatLng point, double distanceInMeters) {
  for (int i = 0; i < poly.length - 2; i ++) {
    var cur = poly[i];
    var next = poly[i + 1];
    if(point == next) {
      return i;
    }

    //
    var bearingCurNext = Geolocator.bearingBetween(
        cur.latitude,
        cur.longitude,
        next.latitude,
        next.longitude
    );

    var bearingCurPoint = Geolocator.bearingBetween(
      cur.latitude,
      cur.longitude,
      point.latitude,
      point.longitude,
    );

    var bearingPointNext = Geolocator.bearingBetween(
      point.latitude,
      point.longitude,
      next.latitude,
      next.longitude,
    );

    final diff1 = bearingCurNext - bearingPointNext;
    final diff2 = bearingCurNext - bearingCurPoint;

    final distanceCurPoint = Geolocator.distanceBetween(
        cur.latitude,
        cur.longitude,
        point.latitude,
        point.longitude);

    final distanceCurNext = Geolocator.distanceBetween(
        cur.latitude,
        cur.longitude,
        next.latitude,
        next.longitude);

    if(diff1.abs() < 1 && diff2.abs() < 1 && distanceCurPoint < distanceCurNext) {
      return i;
    }
    // debugPrint('bearingCurNext: $bearingCurNext - bearingCurPoint: $bearingCurPoint - bearingPointNext: $bearingPointNext - index: $i');
  }

  return -1;
}

PointOnPolylineInfo calcDirectionPointPolylineInfo(List<LatLng> poly, LatLng point) {
  double? minDistance;
  int minIndex = 0;
  for (int i = 0; i < poly.length; i ++) {
    final d = Geolocator.distanceBetween(
      poly[i].latitude,
      poly[i].longitude,
      point.latitude,
      point.longitude
    );

    if(minDistance == null || d < minDistance) {
      minDistance = d;
      minIndex = i;
    }
  }

  var prev = poly[minIndex];
  var next = poly[minIndex + 1];

  var bearing = Geolocator.bearingBetween(
    prev.latitude,
    prev.longitude,
    next.latitude,
    next.longitude,
  );

  return PointOnPolylineInfo(poly[minIndex], bearing: bearing, indexNearestPreviousPoint: minIndex);
}

PointOnPolylineInfo nextPointOnPolyline(List<LatLng> poly, LatLng point, double distanceInMeters, int indexOnPolyline) {
  var index = indexOnPolyline == -1
                ? nearestPreviousPointIndexOnLine(poly, point, distanceInMeters)
                : indexOnPolyline;

  if(index == -1 || index == poly.length - 1) {
    return PointOnPolylineInfo(poly.last, bearing: null, indexNearestPreviousPoint: index);
  }

  var prev = poly[index];
  var next = poly[index + 1];

  var bearing = Geolocator.bearingBetween(
    prev.latitude,
    prev.longitude,
    next.latitude,
    next.longitude,
  );

  var distancePrevNext = Geolocator.distanceBetween(
      prev.latitude,
      prev.longitude,
      next.latitude,
      next.longitude);

  const d = Distance();
  var newLatLon = d.offset(point, distanceInMeters, bearing);

  var distancePrevCur = Geolocator.distanceBetween(
      prev.latitude,
      prev.longitude,
      newLatLon.latitude,
      newLatLon.longitude);

  var nextIndex = poly.indexOf(next);
  // If the new lat lon is outside the segment prev-next (distance between prev and new lat long > prev and next),
  // take the surplus and project along the polyline considering the bearing with the next segment
  while(distancePrevCur > distancePrevNext) {
    index = nextIndex;
    if(nextIndex == poly.length - 1) {
      return PointOnPolylineInfo(poly[nextIndex], bearing: bearing, indexNearestPreviousPoint: nextIndex);
    }

    double diff = distancePrevCur - distancePrevNext;
    prev = poly[nextIndex];
    nextIndex ++;
    next = poly[nextIndex];

    bearing = Geolocator.bearingBetween(
      prev.latitude,
      prev.longitude,
      next.latitude,
      next.longitude,
    );

    newLatLon = d.offset(prev, diff, bearing);

    distancePrevNext = Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        next.latitude,
        next.longitude);

    distancePrevCur = Geolocator.distanceBetween(
        prev.latitude,
        prev.longitude,
        newLatLon.latitude,
        newLatLon.longitude);
  }

  final turfPoint = turf.Point(coordinates: turf.Position(newLatLon.longitude, newLatLon.latitude));
  final projectedPoint = turf.nearestPointOnLine(
      poly.toLineString(),
      turfPoint,
      turf.Unit.meters
  );

  return PointOnPolylineInfo(projectedPoint.getLatLng(), bearing: bearing, indexNearestPreviousPoint: index);
}