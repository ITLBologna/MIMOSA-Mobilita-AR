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
import 'dart:math';

import 'package:ar_location_view/ar_location_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/models/configuration_settings.dart';
import 'package:mimosa/business_logic/services/i_directions_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_annotations_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/business_logic/services/services_constants.dart';
import 'package:mimosa/controllers/annotations_controller.dart';
import 'package:mimosa/controllers/ar_radar_satellites_widgets_controller.dart';
import 'package:mimosa/controllers/bus_position_tracking_controller.dart';
import 'package:mimosa/controllers/navigating_to_stop_controller.dart';
import 'package:mimosa/controllers/view_models/buses_positions_infos_vm.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:mimosa/ui/widgets/ar_widgets/bus_stops_radar_satellite_icon_button.dart';
import 'package:mimosa/ui/widgets/ar_widgets/directions_radar_satellite_icon_button.dart';
import 'package:rxdart/rxdart.dart';

const radarSatellitesControllerTag = 'filterStatusSatellite';

class ARWidget extends StatefulWidget {
  final IConfigurationService config =
      serviceLocator.get<IConfigurationService>();
  final String? stopsServiceInstanceName;
  final IDirectionService? directionService;
  final VoidCallback? onClose;
  final VoidCallback? onRadarTap;
  final bool showCloseButton;
  final StopsSettings stopsSettings;
  final BusesSettings busesSettings;
  final ArSensorManager? arSensorManager;
  final RadarPosition radarPosition;
  final double radarWidth;
  final Widget Function(BuildContext context, ArAnnotation annotation,
      double userSpeedInMetersPerSecond) buildArAnnotation;

  Size? radarSize;
  Offset? radarOffset;

  double radarOffsetCompensation = 0.0;

  ARWidget(
      {super.key,
      this.arSensorManager,
      this.stopsServiceInstanceName,
      this.directionService,
      this.onClose,
      this.onRadarTap,
      required this.stopsSettings,
      required this.busesSettings,
      required this.buildArAnnotation,
      required this.radarWidth,
      this.radarPosition = RadarPosition.bottomCenter,
      this.showCloseButton = true});

  @override
  State<ARWidget> createState() => _ARWidgetState();
}

class _ARWidgetState extends State<ARWidget> {
  late final IAnnotationsService annotationService;
  late final IConfigurationService configurationService;
  Position? userPosition;
  bool showCompassNeedsCalibration = true;
  late final TripStopAnnotationsController _tripStopsAnnotationsController;
  late final DirectionsAnnotationsController _directionsAnnotationsController;
  late final BusesPositionsTrackingController _busPositionTrackingController;
  late final StreamSubscription<List<ArAnnotation>> _annotationsSubscription;
  late final VisibleAnnotationsTypesController
      _visibleAnnotationsTypesController;

  void _updateAnnotations() {
    _directionsAnnotationsController.updateAnnotations(
        userPosition: userPosition!,
        maxDistanceInMeters: widget.stopsSettings.maxDistanceInMeters.toInt(),
        maxPoi: widget.stopsSettings.maxPoi,
        minPoi: widget.stopsSettings.minPoi);

    _tripStopsAnnotationsController.updateAnnotations(
        userPosition: userPosition!,
        maxDistanceInMeters: widget.stopsSettings.maxDistanceInMeters.toInt(),
        maxPoi: widget.stopsSettings.maxPoi,
        minPoi: widget.stopsSettings.minPoi);
  }

  ArAnnotation<BusPositionInfoVM> _getBusAnnotationFromBusPositionInfo(
      BusPositionInfoVM info) {
    final distanceFromUser = userPosition != null
        ? Geolocator.distanceBetween(
            userPosition!.latitude,
            userPosition!.longitude,
            info.projectedCoords.latitude,
            info.projectedCoords.longitude)
        : -1.0;
    return ArAnnotation<BusPositionInfoVM>(
        uid: info.info.label,
        data: info,
        position: Position(
          latitude: info.projectedCoords.latitude,
          longitude: info.projectedCoords.longitude,
          timestamp: DateTime.now(),
          accuracy: 1,
          altitude: 1,
          heading: 1,
          speed: 1,
          speedAccuracy: 1,
        ),
        distanceFromUserInMeters: distanceFromUser,
        angle: 0,
        radarMarkerColorHex: 0xFFFFFFFF,
        maxVisibleDistance:
            configurationService.settings.busesSettings.maxDistanceInMeters,
        canOverlayOtherAnnotations: true,
        highlightMode: HighlightMode.never);
  }

  @override
  void initState() {
    final String stopsServiceInstanceName =
        Get.parameters['stopsServiceInstanceName'] ??
            widget.stopsServiceInstanceName ??
            apiStopsServiceInstanceName;
    annotationService = serviceLocator.get<IAnnotationsService<TripStop>>(
        instanceName: stopsServiceInstanceName);

    configurationService = serviceLocator.get<IConfigurationService>();

    _directionsAnnotationsController =
        Get.put(DirectionsAnnotationsController());
    _visibleAnnotationsTypesController =
        Get.put(VisibleAnnotationsTypesController());
    _tripStopsAnnotationsController = Get.put(TripStopAnnotationsController(
        annotationServiceInstanceName: stopsServiceInstanceName));
    _busPositionTrackingController =
        Get.find<BusesPositionsTrackingController>();

    _annotationsSubscription = CombineLatestStream.combine3<
            List<ArAnnotation<TripStop>>,
            List<ArAnnotation<PolylinedWalkStep>>,
            List<ArAnnotation<BusPositionInfoVM>>,
            List<ArAnnotation>>(
        _tripStopsAnnotationsController.stream,
        _directionsAnnotationsController.stream,
        _busPositionTrackingController.stream.map((event) =>
            event.map((e) => _getBusAnnotationFromBusPositionInfo(e)).toList()),
        (trips, directions, buses) =>
            [...trips, ...directions, ...buses]).listen((annotations) {
      final arAnnotationsController = Get.find<ArAnnotationsController>();
      arAnnotationsController.annotations.value = annotations;
      _updateAnnotationsVisibility();
    });

    super.initState();
  }

  void _updateAnnotationsVisibility() {
    final arAnnotationsController = Get.find<ArAnnotationsController>();
    arAnnotationsController.annotations.value.forEach((a) {
      if (a is ArAnnotation<TripStop>) {
        final controller = Get.find<NavigatingToStopController>();
        a.isVisible =
            _visibleAnnotationsTypesController.stopsAnnotationsAreVisible();
        a.radarMarkerColorHex = stopsColorHex;
        if (a.data.stopId == controller.navigatingToStopId.value &&
            _visibleAnnotationsTypesController
                .directionsAnnotationsAreVisible()) {
          a.isVisible = true;
          a.radarMarkerColorHex = directionsColorHex;
        }
      }
      // Direction annotations are always visible
      else if (a is ArAnnotation<PolylinedWalkStep>) {
        a.isVisible = a.isVisible &&
            _visibleAnnotationsTypesController
                .directionsAnnotationsAreVisible();
      }
    });
  }

  @override
  void dispose() {
    _annotationsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double radarOffsetCompensation = 0.0;
    if (widget.radarPosition == RadarPosition.bottomLeft ||
        widget.radarPosition == RadarPosition.topLeft) {
      radarOffsetCompensation = -widget.radarWidth + 16;
    } else if (widget.radarPosition == RadarPosition.bottomRight ||
        widget.radarPosition == RadarPosition.topRight) {
      radarOffsetCompensation = -widget.radarWidth + 16;
    }

    return Stack(
      children: [
        GetBuilder<DirectionsAnnotationsController>(builder: (controller) {
          return ArLocationWidget(
            arSensorManager: widget.arSensorManager,
            radarWidth: widget.radarWidth,
            onError: (error) {
              if (error is CompassNeedsCalibrationError) {
                return Visibility(
                  visible: showCompassNeedsCalibration,
                  child: CompassNeedsCalibrationWidget(
                    messageRead: () => showCompassNeedsCalibration = false,
                  ),
                );
              } else {
                return Container(
                  color: Colors.white,
                  child: Center(
                      child: Text(AppLocalizations.of(context)!.camera_error)),
                );
              }
            },
            maxVisibleDistance: max(widget.stopsSettings.maxDistanceInMeters,
                widget.busesSettings.maxDistanceInMeters),
            // The logic of minimum visible annotations in ar lib does not suite our needs
            // because we have different annotation types, so we need minimum one for each type.
            // We set null, because the filter based on distance and minimum visibility is done by annotations controllers
            minimumVisibleAnnotations: null,
            metersAfterWhichNotifyLocationChange: widget.config.settings
                .arSettings.metersAfterWhichNotifyLocationChange,
            showDebugInfoSensor: false,
            radarPosition: widget.radarPosition,
            onWidgetSizeChange: (Size size, Offset? offset) {
              setState(() {
                widget.radarSize = size;
                widget.radarOffset = offset;
              });
            },
            radarSatellites: [
              BusStopsRadarSatelliteIconButton(
                  radarWidth: widget.radarWidth,
                  radarSize: widget.radarSize,
                  radarOffset: widget.radarOffset,
                  offsetFromRadar: ((widget.radarWidth) / 2) + 84,
                  radarOffsetCompensation: radarOffsetCompensation,
                  orbitalDegrees: 24,
                  size: const Size(48, 48),
                  onPressed: () => _updateAnnotationsVisibility()),
              if (controller.running)
                DirectionsRadarSatelliteIconButton(
                    radarWidth: widget.radarWidth,
                    radarSize: widget.radarSize,
                    radarOffset: widget.radarOffset,
                    offsetFromRadar: ((widget.radarWidth) / 2) + 94,
                    radarOffsetCompensation: radarOffsetCompensation,
                    orbitalDegrees: 9,
                    size: const Size(48, 48),
                    onPressed: () => _updateAnnotationsVisibility())
            ],
            dyAnnotationsOffsetInScreenPercent: widget
                .config.settings.arSettings.dyAnnotationsOffsetInScreenPercent,
            annotationViewBuilder:
                (context, annotation, userSpeedInMetersPerSecond) {
              return widget.buildArAnnotation(
                  context, annotation, userSpeedInMetersPerSecond);
            },
            onLocationChange: (pos) {
              userPosition = pos;
              _updateAnnotations();
            },
          );
        }),
        if (widget.showCloseButton)
          Align(
            alignment: Alignment.topLeft,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: Theme.of(context).primaryColor),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                        iconSize: 20,
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          widget.onClose != null
                              ? widget.onClose?.call()
                              : Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close)),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}

class CompassNeedsCalibrationWidget extends StatelessWidget {
  final void Function() messageRead;

  const CompassNeedsCalibrationWidget({super.key, required this.messageRead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
          child: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Icon(
                    FontAwesomeIcons.compass,
                    size: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      AppLocalizations.of(context)!.compass_needs_calibration,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                  onPressed: messageRead,
                  child: const Text(
                    'OK',
                    textAlign: TextAlign.center,
                  )),
            )
          ],
        ),
      )),
    );
  }
}
