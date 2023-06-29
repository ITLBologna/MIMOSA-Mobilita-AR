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

import 'dart:async';

import 'package:ar_location_view/ar_annotation.dart';
import 'package:ar_location_view/services/process_sensors_data_service.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/i_directions_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_annotations_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_directions_annotations_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/pinned_stop_controller.dart';
import 'package:mimosa/controllers/vibrate_controller.dart';

abstract class AnnotationsController<T> extends GetxController {
  late final StreamController<List<ArAnnotation<T>>>
      _annotationsStreamController;

  bool _showAnnotations = true;
  Position? _lastUserPosition;
  int? _lastMaxDistanceInMeters;
  int? _lastMaxPoi;
  int? _lastMinPoi;

  Stream<List<ArAnnotation<T>>> get stream =>
      _annotationsStreamController.stream;

  void showAnnotations([bool show = true]) {
    if (_showAnnotations != show) {
      _showAnnotations = show;
      if (show && _lastUserPosition != null) {
        updateAnnotations(
            userPosition: _lastUserPosition!,
            maxDistanceInMeters: _lastMaxDistanceInMeters!,
            maxPoi: _lastMaxPoi!,
            minPoi: _lastMinPoi!);
      } else {
        _annotationsStreamController.add([]);
      }
    }
  }

  void _updateAnnotations(
      {required Position userPosition,
      int maxDistanceInMeters = 1500,
      int maxPoi = 100,
      int minPoi = 2});

  void updateAnnotations(
      {required Position userPosition,
      int maxDistanceInMeters = 1500,
      int maxPoi = 100,
      int minPoi = 2}) {
    _lastUserPosition = userPosition;
    _lastMaxDistanceInMeters = maxDistanceInMeters;
    _lastMaxPoi = maxPoi;
    _lastMinPoi = minPoi;

    if (!_showAnnotations) {
      return;
    }

    _updateAnnotations(
        userPosition: userPosition,
        maxDistanceInMeters: maxDistanceInMeters,
        maxPoi: maxPoi,
        minPoi: minPoi);
  }

  void clearAnnotations() {
    _annotationsStreamController.add([]);
  }

  @override
  void onInit() {
    _annotationsStreamController =
        StreamController<List<ArAnnotation<T>>>.broadcast();
    super.onInit();
  }

  @override
  void onClose() {
    _annotationsStreamController.close();
    super.onClose();
  }
}

class TripStopAnnotationsController extends AnnotationsController<TripStop> {
  final String annotationServiceInstanceName;
  late final IAnnotationsService<TripStop> annotationService;
  late final PinnedStopController pinnedStopController;

  TripStopAnnotationsController({required this.annotationServiceInstanceName});

  @override
  void _updateAnnotations(
      {required Position userPosition,
      int maxDistanceInMeters = 1500,
      int maxPoi = 100,
      int minPoi = 2}) {
    annotationService
        .getAnnotations(
            userPosition: userPosition,
            maxDistanceInMeters: maxDistanceInMeters,
            maxPoi: maxPoi,
            minPoi: minPoi)
        .map((annotations) {
      annotations.forEach((a) {
        final configService = serviceLocator.get<IConfigurationService>();
        final sensorsService = Get.find<ProcessSensorsDataService>();
        if (a.distanceFromUserInMeters <=
            (configService.settings.arSettings.pinStopWhenCloserThanMeters +
                sensorsService.getUserPositionAccuracy())) {
          if (pinnedStopController.pinnedStop.value?.stopId != a.data.stopId) {
            VibrateController.vibrate(500);
            a.isPinned = true;
            pinnedStopController.pinnedStop.value = a.data;
            pinnedStopController.showInfo.value = false;
          }
        } else if (pinnedStopController.pinnedStop.value?.stopId ==
            a.data.stopId) {
          pinnedStopController.showInfo.value = false;
          pinnedStopController.pinnedStop.value = null;
          a.isPinned = false;
        }
      });
      return annotations;
    }).fold((failures) => debugPrint(failures.first.toString()),
            (annotations) => _annotationsStreamController.add(annotations));
  }

  @override
  void onInit() {
    annotationService = serviceLocator.get<IAnnotationsService<TripStop>>(
        instanceName: annotationServiceInstanceName);
    pinnedStopController = Get.put(PinnedStopController());
    super.onInit();
  }

  @override
  void onClose() {
    _annotationsStreamController.close();
    super.onClose();
  }
}

class DirectionsAnnotationsController
    extends AnnotationsController<PolylinedWalkStep> {
  IDirectionService? _directionService;
  LatLng? _destinationPosition;
  late final IDirectionsAnnotationsService annotationService;
  bool _running = false;

  bool get running => _running;

  @override
  void _updateAnnotations(
      {required Position userPosition,
      int maxDistanceInMeters = 1500,
      int maxPoi = 100,
      int minPoi = 2}) {
    if (_destinationPosition == null || _directionService == null) {
      return;
    }

    annotationService.directionService = _directionService;

    final annotations = annotationService.getAnnotations(
        userPosition: userPosition,
        destinationPosition: _destinationPosition!,
        maxDistanceInMeters: maxDistanceInMeters,
        maxPoi: maxPoi,
        minPoi: minPoi);

    _annotationsStreamController.add(annotations);
  }

  void start(
      {required Position userPosition,
      required LatLng destinationPosition,
      required IDirectionService directionService}) {
    _lastUserPosition = userPosition;
    _destinationPosition = destinationPosition;
    _directionService = directionService;
    _running = true;
    updateAnnotations(userPosition: userPosition);
    update();
  }

  void stop() {
    _running = false;
    _lastUserPosition = null;
    _destinationPosition = null;
    _directionService = null;
    _annotationsStreamController.add([]);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    annotationService = serviceLocator.get<IDirectionsAnnotationsService>();
  }

  @override
  void onClose() {
    _annotationsStreamController.close();
    super.onClose();
  }
}
