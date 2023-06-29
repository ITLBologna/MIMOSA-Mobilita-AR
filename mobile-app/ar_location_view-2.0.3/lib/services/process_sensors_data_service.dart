import 'dart:io';
import 'dart:math';
import 'package:ar_location_view/_annotations_extensions.dart';
import 'package:ar_location_view/ar_location_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class ProcessSensorsDataService {
  final annotationsController = Get.put<ArAnnotationsController>(ArAnnotationsController());
  Position? lastUserPosition;
  DateTime? lastRegisteredUserPositionDateTime;
  final double metersAfterWhichNotifyLocationChange;
  final double defaultUserSpeedInMetersPerSecond;
  double actualUserSpeedInMetersPerSecond;

  ProcessSensorsDataService({
    required this.metersAfterWhichNotifyLocationChange,
    required this.defaultUserSpeedInMetersPerSecond
  }) : actualUserSpeedInMetersPerSecond = defaultUserSpeedInMetersPerSecond;

  static ArStatus _calculateFOV(NativeDeviceOrientation orientation, double width, double height) {
    final arStatus = ArStatus();
    final fov = ArMath.calculateFOV(orientation, width, height);
    arStatus.hFov = fov.hFov;
    arStatus.vFov = fov.vFov;
    arStatus.hPixelPerDegree = fov.hPixelPerDegree;
    arStatus.vPixelPerDegree = fov.vPixelPerDegree;

    return arStatus;
  }

  double getUserPositionAccuracy() {
    if(Platform.isIOS) {
      return 0;
    }

    return 0; // lastUserPosition?.accuracy ?? 0;
  }

  bool updateUserPositionAndSpeed(Position newPosition) {
    if (lastUserPosition == null) {
      lastUserPosition = newPosition;
      lastRegisteredUserPositionDateTime = DateTime.now();
      return true;
    } else {
      final distance = Geolocator.distanceBetween(
          lastUserPosition!.latitude,
          lastUserPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude
      );


      if (distance > metersAfterWhichNotifyLocationChange) {
        lastUserPosition = newPosition;
        final time = DateTime.now();
        final elapsedSeconds = time.difference(lastRegisteredUserPositionDateTime!).inSeconds;
        // Average speed calculated between current value and new value
        final newSpeed = (actualUserSpeedInMetersPerSecond + distance / elapsedSeconds) / 2;
        // TODO: review this logic
        if(newSpeed > defaultUserSpeedInMetersPerSecond / 2 || newSpeed < defaultUserSpeedInMetersPerSecond * 2) {
          actualUserSpeedInMetersPerSecond = newSpeed;
        }

        lastRegisteredUserPositionDateTime = time;
        return true;
      }
      else {
        return false;
      }
    }
  }

  AnnotationsToShow calculateAnnotationsToShow({
      required ArSensor arSensor,
      required double maxVisibleDistance,
      int? minimumVisibleAnnotations,
      required String fullscreenAnnotationId,
      required double screenWidth,
      required double screenHeight}) {

    final highlightController = Get.find<ArHighlightedAnnotationController>();
    highlightController.annotationUid = '';

    final arStatus = _calculateFOV(arSensor.orientation, screenWidth, screenHeight);
    final deviceLocation = arSensor.location!;
    var radarAnnotations = annotationsController
        .annotations
        .where((a) => a.isVisible && !a.isPinned) // If a stop i pinned, it's removed from AR
        .toList()
        .calculateAzimuthDistanceAndBearingFromUser(deviceLocation)
        .calculateArViewPosition(arSensor, arStatus)
        .filterByDistance(
          maxDistance: maxVisibleDistance,
          arSensor: arSensor,
          deviceLocation: deviceLocation,
          minimumVisibleAnnotations: minimumVisibleAnnotations,
          arStatus: arStatus
        );

    List<ArAnnotation> screenAnnotations = [];
    // We search in annotations and not radarAnnotations because a pinned stop can be fullscreen and
    // in radarAnnotations pinned stop is not present
    final fullscreenAnnotation = annotationsController.annotations.firstWhereOrNull((a) => a.uid == fullscreenAnnotationId);
    if(fullscreenAnnotation != null) {
      screenAnnotations.add(fullscreenAnnotation);
    }
    else {
      screenAnnotations =
        radarAnnotations
            .onScreen(arSensor.heading, arStatus)
            .sortByDistance()
            .highlight();
    }

    final highlighted = screenAnnotations.where((a) => a.highlighted).toList();
    if(highlighted.isNotEmpty) {
      highlightController.annotationUid = highlighted.first.uid;
    }

    if(radarAnnotations.isNotEmpty) {
      final distance = Geolocator.distanceBetween(
          radarAnnotations.last.position.latitude,
          radarAnnotations.last.position.longitude,
          deviceLocation.latitude,
          deviceLocation.longitude);
      maxVisibleDistance = max(maxVisibleDistance, distance + 20);
    }

    return AnnotationsToShow(
        radarAnnotations: radarAnnotations,
        screenAnnotations: screenAnnotations,
        maxVisibleDistance: maxVisibleDistance
    );
  }
}

class AnnotationsToShow {
  final List<ArAnnotation> radarAnnotations;
  List<ArAnnotation> screenAnnotations;
  final double maxVisibleDistance;

  AnnotationsToShow({
    required this.radarAnnotations,
    required this.screenAnnotations,
    required this.maxVisibleDistance
  });
}