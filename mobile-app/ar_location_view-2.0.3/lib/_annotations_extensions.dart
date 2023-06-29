import 'dart:ui';

import 'package:ar_location_view/ar_annotation.dart';
import 'package:ar_location_view/ar_math.dart';
import 'package:ar_location_view/ar_sensor.dart';
import 'package:ar_location_view/ar_status.dart';
import 'package:geolocator/geolocator.dart';


extension AnnotationsListExtensions on List<ArAnnotation> {
  List<ArAnnotation> filterByDistance({
      required double maxDistance,
      required ArSensor arSensor,
      required Position deviceLocation,
      int? minimumVisibleAnnotations,
      required ArStatus arStatus}) {
        bool checkVisibility(ArAnnotation a) {
          return a.distanceFromUserInMeters < maxDistance &&
              // Annotations can have a lower visibility range, so check is annotation is in proper range
              (a.maxVisibleDistance == null || a.distanceFromUserInMeters < a.maxVisibleDistance!);
        }


        final filtered = where((a) => checkVisibility(a)).toList();
        if (minimumVisibleAnnotations != null && filtered.length < minimumVisibleAnnotations) {
          return sortByDistance().take(minimumVisibleAnnotations).toList();
        }
        else {
          return filtered.sortByDistance();
        }
  }

  List<ArAnnotation> onScreen(double heading, ArStatus arStatus) {
    final degreesDeltaH = arStatus.hFov;
    return where((a) {
      final delta = ArMath.deltaAngle(heading, a.azimuth);
      return delta.abs() <= degreesDeltaH;
    }).toList();
  }

  List<ArAnnotation> calculateAzimuthDistanceAndBearingFromUser(
      Position deviceLocation) {
    return map((e) {
      final annotationLocation = e.position;
      final azimuth = Geolocator.bearingBetween(
        deviceLocation.latitude,
        deviceLocation.longitude,
        annotationLocation.latitude,
        annotationLocation.longitude,
      );
      final distanceFromUser = Geolocator.distanceBetween(
          deviceLocation.latitude,
          deviceLocation.longitude,
          annotationLocation.latitude,
          annotationLocation.longitude);
      return e.copyWith(azimuth: azimuth, distanceFromUserInMeters: distanceFromUser);
    }).toList();
  }

  List<ArAnnotation> calculateArViewPosition(
      ArSensor arSensor,
      ArStatus arStatus) {
    return map((e) {
      final azimuth = e.azimuth;
      final dy = arSensor.pitch * arStatus.vPixelPerDegree;
      final angle = ArMath.deltaAngle(azimuth, arSensor.heading);
      final dx = ArMath.deltaAngle(azimuth, arSensor.heading) * arStatus.hPixelPerDegree;
      final arPosition = Offset(dx, dy);
      return e.copyWith(arPosition: arPosition, angle: angle);
    }).toList();
  }

  List<ArAnnotation> sortByDistance({bool asc = true}) {
    final mul = asc ? 1 : -1;
    final l = toList();
    l.sort((a, b) =>
              a.distanceFromUserInMeters < b.distanceFromUserInMeters
                  ? -1 * mul
                  : a.distanceFromUserInMeters > b.distanceFromUserInMeters
                      ? 1 * mul
                      : 0
            );
    return l;
  }

  /// Remind: before calling this method, sort annotations by distance calling sortByDistanceAsc
  List<ArAnnotation> highlight() {
    final highlightables = where((a) => a.highlightMode != HighlightMode.never).toList();
    final notHighlightables = where((a) => a.highlightMode == HighlightMode.never).toList();
    if(highlightables.isNotEmpty) {
      if(highlightables.first.highlightMode == HighlightMode.nearest) {
        final head = highlightables.take(1).map((a) => a.copyWith(highlighted: true));
        final tail = highlightables.skip(1).map((a) => a.copyWith(highlighted: false));
        final l = List<ArAnnotation>.from([...head, ...tail, ...notHighlightables]);
        return l.sortByDistance();
      }
      else {
        return map((a) => a.copyWith(highlighted: a.highlightMode == HighlightMode.always))
              .toList();
      }
    }

    return toList();
  }
}