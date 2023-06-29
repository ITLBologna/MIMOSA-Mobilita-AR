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
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/constants/constants.dart';
import 'package:mimosa/business_logic/enums/ar_pitch_state.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/polyline_extension.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/i_directions_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/business_logic/services/services_constants.dart';
import 'package:mimosa/controllers/annotations_controller.dart';
import 'package:mimosa/controllers/ar_mode_switch_controller.dart';
import 'package:mimosa/controllers/ar_radar_satellites_widgets_controller.dart';
import 'package:mimosa/controllers/bus_position_tracking_controller.dart';
import 'package:mimosa/controllers/bus_to_track_controller.dart';
import 'package:mimosa/controllers/gamification_controller.dart';
import 'package:mimosa/controllers/map_rotation_controller.dart';
import 'package:mimosa/controllers/map_ui_controller.dart';
import 'package:mimosa/controllers/navigating_to_stop_controller.dart';
import 'package:mimosa/controllers/next_runs_controller.dart';
import 'package:mimosa/controllers/no_solutions_found_controller.dart';
import 'package:mimosa/controllers/pinned_stop_controller.dart';
import 'package:mimosa/controllers/track_user_icon_controller.dart';
import 'package:mimosa/controllers/view_models/buses_positions_infos_vm.dart';
import 'package:mimosa/controllers/view_models/itinerary_vm.dart';
import 'package:mimosa/controllers/view_models/polyline_projected_stop.dart';
import 'package:mimosa/controllers/view_models/route_with_trip.dart';
import 'package:mimosa/controllers/view_models/trip_short_name_marker_data.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:mimosa/ui/library_widgets/alert_dialog.dart';
import 'package:mimosa/ui/widgets/annotations/bus_annotation_widget.dart';
import 'package:mimosa/ui/widgets/annotations/trip_stop_annotation_widget.dart';
import 'package:mimosa/ui/widgets/annotations/walk_step_annotation_widget.dart';
import 'package:mimosa/ui/widgets/ar_fab_widget.dart';
import 'package:mimosa/ui/widgets/ar_widgets/ar_widget.dart';
import 'package:mimosa/ui/widgets/back_button_app_bar.dart';
import 'package:mimosa/ui/widgets/gamification/playing_token_widget.dart';
import 'package:mimosa/ui/widgets/map_attributions/map_attributions_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_rotation_icon_button.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_route_itinerary_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_routes_builder_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/plain_stops_marker_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/pinned_stop_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/smoth_compass_icon_widget.dart';
import 'package:mimosa/ui/widgets/map_widgets/track_user_position_icon_button.dart';
import 'package:mimosa/ui/widgets/mimosa_error_widget.dart';
import 'package:turf/helpers.dart' as turf;
import 'package:turf/nearest_point_on_line.dart';
import 'package:wakelock/wakelock.dart';

const headsignStaticPositionId = 'headsign';
const userStaticPositionId = 'user';
const tripStopsStaticPositionsId = 'tripStops';

class _ARUIController extends GetxController {
  final opacity = 0.0.obs;
}

class _FabExpansionController extends GetxController {
  final expanded = false.obs;
  Offset? fabPosition;
  Size? fabSize;
}

class TripsMapPage extends StatefulWidget {
  const TripsMapPage({super.key});

  @override
  State<TripsMapPage> createState() => _TripsMapPageState();
}

class _TripsMapPageState extends State<TripsMapPage>
    with
        WidgetsBindingObserver,
        TickerProviderStateMixin,
        TraceableClientMixin {
  final IConfigurationService config =
      serviceLocator.get<IConfigurationService>();
  final _arModeSwitchController = Get.put(ArModeSwitchController());
  final _mapUIController = Get.put(MapUIController());
  final _arUIController = Get.put(_ARUIController());
  final _arLocationWidgetUIController = Get.put(ARLocationWidgetUIController());
  final _routeToTrackController = Get.put(RouteToTrackController());
  final _busesTrackingController = Get.put(BusesPositionsTrackingController());
  final _directionsAnnotationsController =
      Get.put(DirectionsAnnotationsController());
  final _noSolutionsFoundController =
      Get.put(NoSolutionsFoundController(), tag: tripsMapPageRoute);
  final _fabExpansionController = Get.put(_FabExpansionController());
  final _trackUserIconController = Get.put(TrackUserIconController());
  final _gamificationController = Get.put(GamificationController());
  final _navigatingToStopController = Get.put(NavigatingToStopController());
  final _fullscreenAnnotationController =
      Get.put(ArFullscreenAnnotationController());
  final _tripStopsAnnotationsController = Get.put(TripStopAnnotationsController(
      annotationServiceInstanceName: fixedStopsServiceInstanceName));
  final _pinnedStopController = Get.put(PinnedStopController());
  final _mapRotationController = Get.put(MapRotationController());
  late final ILocationService _locationService;

  StreamSubscription? _tripStopsSubscription;
  final ArSensorManager arSensorManager = ArSensorManager();
  final GlobalKey _arWidgetKey = GlobalKey();
  late final MapRoutesBuilderWidget mapRoutesBuilderWidget;
  late MapController mapController;

  Timer? _stopARBackgroundTimer;
  bool _removeLastPolylineWhenStoppedDirections = false;
  Position? _lastUserPosition;
  double _lastHeading = 0;

  ArPitchState? _lastArPitchState;

  StreamSubscription? _busesPositionsSubscription;
  StreamSubscription? _whichRouteSubscription;
  StreamSubscription? _sensorsSubscription;
  StreamSubscription? _directionsSubscription;

  List<PolylineProjectedStop> _projectedStops = [];

  double mapRotation = 0.0;

  void showErrorMessageInPostFrameCallback(
      BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showAlertDialogEx(context,
          progressIndicatorTag: 'initError', title: 'Errore', message: message);
    });
  }

  @override
  void initState() {
    super.initState();

    _gamificationController.otpFirstStop = null;
    _gamificationController.otpLastStop = null;

    _locationService = serviceLocator.get<ILocationService>();
    Get.put(ArHighlightedAnnotationController());
    Get.put(NextRunsController());
    Get.put(ArFullscreenAnnotationController());

    final MapRoutesBuilderWidget Function() mapRouteWidgetBuilder =
        Get.arguments;
    mapRoutesBuilderWidget = mapRouteWidgetBuilder();

    mapRoutesBuilderWidget.selectedTripStream()?.listen((trip) {
      _tripStopsAnnotationsController.updateAnnotations(
          userPosition: _lastUserPosition!, maxPoi: 4);
    });

    mapRoutesBuilderWidget.arModeIsOn =
        () => _arModeSwitchController.isInARMode.value;
    mapRoutesBuilderWidget.drawTripsPolylineAndStops =
        _drawTripsPolylineAndStops;

    _arLocationWidgetUIController.cameraIsPaused.value = true;
    WidgetsBinding.instance.addObserver(this);
    mapController = MapController();

    _mapUIController.setUserMarker(
        setInPostframeCallback: true, arModeOn: false);
  }

  @override
  String get traceName => 'TripsMap';

  @override
  String get traceTitle => 'TripsMapPage';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final configService = serviceLocator.get<IConfigurationService>();
      _stopARBackgroundTimer?.cancel();
      _stopARBackgroundTimer = Timer(
          Duration(
              seconds: configService
                  .settings.arSettings.stopArWhenInBackgroundAfterSeconds), () {
        if (mounted) {
          MatomoTracker.instance.trackEvent(
              eventCategory: 'AR',
              action: 'stopArForPause',
              eventName: 'changeArMode');
          _stopAR();
        }
      });
    } else if (state == AppLifecycleState.resumed) {
      _stopARBackgroundTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tripStopsSubscription?.cancel();
    mapController.dispose();
    _stopAR();
    super.dispose();
  }

  void _doActionIfHeadingChanged(
      ArSensor event, void Function(double heading) action) {
    final headingDiff = (event.heading - _lastHeading).abs();
    // debugPrint('HEADING (event, last, diff) ${event.heading}, $_lastHeading, $headingDiff');
    if (headingDiff > 2 && mounted) {
      _lastHeading = event.heading;
      action(_lastHeading);
    }
  }

  void _rotateMap(ArSensor event) {
    if (_mapRotationController.mapRotationEnabled.value) {
      _doActionIfHeadingChanged(event, (heading) {
        setState(() {
          mapRotation = -heading;
        });
        mapController.rotate(-heading);
        _mapUIController.setUserMarker(
            userPosition: _lastUserPosition?.toArPosition(),
            mapRotationEnabled: _mapRotationController.mapRotationEnabled.value,
            heading: heading,
            arModeOn: _arModeSwitchController.isInARMode.value);
      });
    }
  }

  void _updateUserPositionOnMap(ArSensor event) {
    if (_lastUserPosition == null) {
      _lastUserPosition = event.location;
      return;
    }

    if (_arModeSwitchController.isInARMode.value &&
        !_mapRotationController.mapRotationEnabled.value) {
      _doActionIfHeadingChanged(event, (heading) {
        _mapUIController.setUserMarker(
            userPosition: _lastUserPosition?.toArPosition(),
            mapRotationEnabled: _mapRotationController.mapRotationEnabled.value,
            heading: heading,
            arModeOn: _arModeSwitchController.isInARMode.value);
      });
    }

    final userPositionDifference = Geolocator.distanceBetween(
      _lastUserPosition!.latitude,
      _lastUserPosition!.longitude,
      event.location!.latitude,
      event.location!.longitude,
    );

    if (userPositionDifference > 2) {
      _lastUserPosition = event.location;
      if (event.location != null) {
        // Uncomment to enable location tracking
        MatomoTracker.instance.trackEvent(
            eventCategory: 'Position',
            action:
                '${event.location?.latitude}, ${event.location?.longitude}');
      }
      _mapUIController
          .setUserMarker(
              userPosition: _lastUserPosition?.toArPosition(),
              mapRotationEnabled:
                  _mapRotationController.mapRotationEnabled.value,
              heading: _lastHeading,
              arModeOn: _arModeSwitchController.isInARMode.value)
          .then((value) {
        _mapUIController.centerZoom.value = CenterZoom(
            center: LatLng(
                _lastUserPosition!.latitude, _lastUserPosition!.longitude),
            zoom: mapController.zoom);

        if (_trackUserIconController.tracking.value && mounted) {
          mapController.move(_mapUIController.centerZoom.value.center,
              _mapUIController.centerZoom.value.zoom);
        }
      });
    }
  }

  void _startAR(BuildContext context) {
    _trackUserIconController.tracking.value = true;
    _arModeSwitchController.isInARMode.value = true;
    _arLocationWidgetUIController.cameraIsStopped.value = false;
    final directionsController = Get.find<DirectionsAnnotationsController>();
    directionsController.clearAnnotations();

    Wakelock.enable();

    _startListenToSensors().then(
        (value) => _arLocationWidgetUIController.cameraIsStopped.value = false);

    _trackBus(context);
  }

  void _stopAR() {
    Wakelock.disable();
    final visibleAnnotationsTypesController =
        Get.find<VisibleAnnotationsTypesController>();
    visibleAnnotationsTypesController.setDefaultValue();

    _trackUserIconController.tracking.value = false;
    _arUIController.opacity.value = 0;
    _arLocationWidgetUIController.cameraIsStopped.value = true;
    _arModeSwitchController.isInARMode.value = false;
    _mapUIController.trackedBusesMarkers = [];

    _navigatingToStopController.navigatingToStopId.value = '';
    _fullscreenAnnotationController.annotationUid.value = '';
    _pinnedStopController.showInfo.value = false;
    _pinnedStopController.pinnedStop.value = null;
    _mapRotationController.mapRotationEnabled.value = true;

    _stopListeningDirections();

    _stopListenToSensors();
    _stopTrackingBus();
  }

  Future<void> _startListenToSensors() {
    if (_arModeSwitchController.isInARMode.value) {
      return arSensorManager
          .init(
        locationService: _locationService,
        forceAndroidLocationManager: false,
      )
          .then((value) {
        _sensorsSubscription = arSensorManager.arSensor?.listen((event) {
          _rotateMap(event);
          _updateUserPositionOnMap(event);

          if (event.pitch <= -30) {
            if (_lastArPitchState == null ||
                _lastArPitchState != ArPitchState.rest) {
              MatomoTracker.instance.trackEvent(
                  eventCategory: "AR",
                  action: "showMap",
                  eventName: 'changeArMode');
              _lastArPitchState = ArPitchState.rest;
            }
            _arLocationWidgetUIController.cameraIsPaused.value = true;
            _arUIController.opacity.value = 0;
          } else {
            _arLocationWidgetUIController.cameraIsPaused.value = false;

            if (event.pitch > -30 && event.pitch <= -15) {
              if (_lastArPitchState == null ||
                  _lastArPitchState != ArPitchState.mixed) {
                MatomoTracker.instance.trackEvent(
                    eventCategory: "AR",
                    action:
                        "from${_lastArPitchState == ArPitchState.on ? 'Camera' : 'Map'}To${_lastArPitchState == ArPitchState.on ? 'Map' : 'Camera'}",
                    eventName: 'changeArMode');
                _lastArPitchState = ArPitchState.mixed;
              }
              var p = event.pitch + 30;
              _arUIController.opacity.value = 1 * p / 15.0;
            } else {
              if (_lastArPitchState == null ||
                  _lastArPitchState != ArPitchState.on) {
                MatomoTracker.instance.trackEvent(
                    eventCategory: "AR",
                    action: "showCamera",
                    eventName: 'changeArMode');
                _lastArPitchState = ArPitchState.on;
              }

              _arUIController.opacity.value = 1;
            }
          }
        });
      });
    }

    return Future<void>.value();
  }

  void _stopListenToSensors() {
    _sensorsSubscription?.cancel();
    _busesPositionsSubscription?.cancel();
    arSensorManager.dispose();
  }

  void _startListeningDirections(TripStop stop,
      {IDirectionService? directionService}) {
    final directionsController = Get.find<DirectionsAnnotationsController>();
    _directionsSubscription ??=
        _directionsAnnotationsController.stream.listen((event) {
      _mapUIController.setDirectionsMarkers(event, context: context);
    });

    final destinationLatLng = LatLng(stop.stopLat, stop.stopLon);
    if (directionService != null) {
      _removeLastPolyline();

      _removeLastPolylineWhenStoppedDirections = false;
      _navigatingToStopController.navigatingToStopId.value = stop.stopId;
      directionsController.start(
          userPosition: _lastUserPosition!,
          destinationPosition: destinationLatLng,
          directionService: directionService);
    } else {
      final service = serviceLocator.get<IApisService>();
      service
          .planRoute(
              fromLat: _lastUserPosition!.latitude,
              fromLng: _lastUserPosition!.longitude,
              toLat: stop.stopLat,
              toLng: stop.stopLon,
              mode: 'WALK',
              useCache: true)
          .map((data) {
        final its = data.plan?.itineraries.map((i) => ItineraryVM(i));
        return its?.isNotEmpty == true ? its!.first : null;
      }).fold((failures) => null, (i) {
        if (i != null) {
          _removeLastPolyline();

          final poly = Polyline(
            points: i.walkDirectionsToPolyline(destinationLatLng),
            isDotted: true,
            color: walkPolylineColor,
            strokeWidth: 6,
          );
          _mapUIController.polylines.add(poly);
          _removeLastPolylineWhenStoppedDirections = true;

          _navigatingToStopController.navigatingToStopId.value = stop.stopId;
          directionsController.start(
              userPosition: _lastUserPosition!,
              destinationPosition: LatLng(stop.stopLat, stop.stopLon),
              directionService: i);
        }
      });
    }
  }

  void _removeLastPolyline() {
    if (_removeLastPolylineWhenStoppedDirections &&
        _mapUIController.polylines.isNotEmpty) {
      _mapUIController.polylines.removeLast();
    }

    _removeLastPolylineWhenStoppedDirections = false;
  }

  void _stopListeningDirections() {
    final directionsController = Get.find<DirectionsAnnotationsController>();
    directionsController.stop();
    _directionsSubscription?.cancel();
    _directionsSubscription = null;
    _mapUIController.directionsMarkers = [];
    _navigatingToStopController.navigatingToStopId.value = '';

    _removeLastPolyline();
  }

  void _trackBus(BuildContext context) {
    // Register to listen to realtime bus positions
    _busesPositionsSubscription =
        _busesTrackingController.stream.listen((event) {
      _mapUIController.setTrackedBusMarker(event, context: context);
      // _setTrackedBusMarker(event);
    });

    // Register to which bus to track (in planned route the user can select the bus to track)
    _whichRouteSubscription = _routeToTrackController.stream.listen((event) {
      // Stop listening to the previous bus
      _busesTrackingController.stopTrack();
      _busesTrackingController.trackBuses(route: event.route, trip: event.trip);
    });
  }

  void _stopTrackingBus() {
    _busesPositionsSubscription?.cancel();
    _whichRouteSubscription?.cancel();
    _busesTrackingController.stopTrack();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return GetBuilder<NoSolutionsFoundController>(
        tag: tripsMapPageRoute,
        builder: (_) {
          if (_noSolutionsFoundController.noSolutions) {
            return Scaffold(
              appBar: const BackButtonAppBar(),
              body: MimosaErrorWidget(
                  message: loc.no_tips_found_for_selected_route),
            );
          }

          return Obx(() {
            var preferredSize = const Size.fromHeight(0);
            if (_pinnedStopController.pinnedStop.value != null) {
              preferredSize = const Size.fromHeight(80);
              if (_navigatingToStopController.navigatingToStopId.value ==
                  _pinnedStopController.pinnedStop.value!.stopId) {
                _stopListeningDirections();
              }
            }

            return Scaffold(
                bottomNavigationBar: mapRoutesBuilderWidget,
                appBar: PinnedStopWidget(
                  size: preferredSize,
                  stop: _pinnedStopController.pinnedStop.value,
                ),
                body: SafeArea(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Obx(() {
                        return FlutterMap(
                          options: MapOptions(
                              center: null,
                              zoom: _mapUIController.centerZoom.value.zoom,
                              interactiveFlags: InteractiveFlag.drag |
                                  InteractiveFlag.pinchZoom |
                                  InteractiveFlag.pinchMove,
                              onMapEvent: (event) {
                                if (event.source == MapEventSource.onDrag) {
                                  _trackUserIconController.tracking.value =
                                      false;
                                }
                              }),
                          mapController: mapController,
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.app',
                            ),
                            PolylineLayer(
                              polylines: _mapUIController.polylines,
                            ),
                            MarkerLayer(
                              markers: _mapUIController.getMarkers(),
                            ),
                          ],
                        );
                      }),
                      Align(
                        alignment: Alignment.topRight,
                        child: SafeArea(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 50.0, right: 10),
                            child: Column(
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.black.withAlpha(20)),
                                    child: TrackUserPositionIconButton(
                                      mapController: mapController,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.black.withAlpha(20)),
                                      child: MapRotationIconButton(
                                        mapController: mapController,
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: SmoothCompassIconWidget(
                                    backgroundColor: Colors.black.withAlpha(30),
                                    size: 32,
                                    deegrees: mapRotation,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: GetBuilder<ArHighlightedAnnotationController>(
                            builder: (highlightedController) {
                          // GetBuilder require a widget to be returned
                          // so we return MapAttributionsWidget but the focus of Builder is to update
                          // the highlighted tsop marker on map
                          _mapUIController.setHighlightedStopMarker(
                            highlightedStopId:
                                highlightedController.annotationUid,
                            projectedStops: _projectedStops,
                            arModeOn: _arModeSwitchController.isInARMode(),
                            center: mapController.center,
                            zoom: mapController.zoom,
                            onNavigateTo: (stop) {
                              HapticFeedback.mediumImpact();
                              if (stop.stopId ==
                                  _navigatingToStopController
                                      .navigatingToStopId.value) {
                                _stopListeningDirections();
                              } else {
                                _startListeningDirections(stop,
                                    directionService: _getItinerary(stop));
                              }
                            },
                          );

                          return const MapAttributionsWidget();
                        }),
                      ),
                      Obx(() {
                        return IgnorePointer(
                          ignoring: _fullscreenAnnotationController
                                  .annotationUid.value.isEmpty &&
                              _arUIController.opacity.value < 0.75,
                          child: AnimatedOpacity(
                              opacity: _fullscreenAnnotationController
                                      .annotationUid.value.isEmpty
                                  ? _arUIController.opacity.value
                                  : 1,
                              duration: const Duration(milliseconds: 300),
                              child: ARWidget(
                                  key: _arWidgetKey,
                                  arSensorManager: arSensorManager,
                                  stopsServiceInstanceName:
                                      fixedStopsServiceInstanceName,
                                  showCloseButton: false,
                                  stopsSettings:
                                      config.settings.tripStopsSettings,
                                  busesSettings: config.settings.busesSettings,
                                  radarWidth: min(
                                      MediaQuery.of(context).size.width / 2.5,
                                      158),
                                  radarPosition: RadarPosition.bottomLeft,
                                  buildArAnnotation: (ctx, annotation,
                                      userSpeedInMetersPerSecond) {
                                    if (annotation is ArAnnotation<TripStop>) {
                                      final directionsController = Get.find<
                                          DirectionsAnnotationsController>();
                                      if (directionsController.running) {
                                        directionsController.updateAnnotations(
                                            userPosition: _lastUserPosition!);
                                      }

                                      return TripStopAnnotationWidget(
                                        key: ValueKey(annotation.uid),
                                        route: mapRoutesBuilderWidget
                                            .getRoute(annotation.data.stopId),
                                        trip: mapRoutesBuilderWidget
                                            .getTrip(annotation.data.stopId),
                                        navigatingTo: annotation.data.stopId ==
                                            _navigatingToStopController
                                                .navigatingToStopId.value,
                                        annotation: annotation,
                                        userSpeedInMetersPerSecond:
                                            userSpeedInMetersPerSecond,
                                        arWidgetKey: _arWidgetKey,
                                        lastUserPosition: _lastUserPosition,
                                        onNavigate: () {
                                          HapticFeedback.mediumImpact();
                                          if (annotation.data.stopId ==
                                              _navigatingToStopController
                                                  .navigatingToStopId.value) {
                                            _stopListeningDirections();
                                          } else {
                                            _startListeningDirections(
                                                annotation.data,
                                                directionService: _getItinerary(
                                                    annotation.data));
                                          }
                                        },
                                      );
                                    } else if (annotation
                                        is ArAnnotation<BusPositionInfoVM>) {
                                      return BusAnnotationWidget(
                                        text: annotation.data.tripShortName,
                                        annotation: annotation,
                                      );
                                    } else if (annotation
                                        is ArAnnotation<PolylinedWalkStep>) {
                                      return WalkStepAnnotationWidget(
                                        annotation: annotation,
                                      );
                                    } else {
                                      return const Text(
                                          'ArAnnotation type is not among types required');
                                    }
                                  },
                                  onClose: () {
                                    // _arUIController.opacity.value = 0;
                                  })),
                        );
                      }),
                      Obx(() {
                        if (_gamificationController.userIsPlaying.value) {
                          return const Align(
                              alignment: Alignment.bottomLeft,
                              child: PlayingTokenWidget());
                        } else {
                          return Container();
                        }
                      }),
                      Align(
                        alignment: Alignment.topLeft,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0, left: 10),
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  color: Colors.white),
                              child: IconButton(
                                  iconSize: 20,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.only(left: 8.0),
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black54,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    if (_gamificationController
                                        .userIsPlaying.value) {
                                      showAlertDialogEx(context,
                                          type: DialogExType.okCancel,
                                          progressIndicatorTag:
                                              'back_quit_playing',
                                          title: loc.warning,
                                          message: loc.quit_game_alert_message,
                                          confirmAction: () => Valid(true)
                                              .toFuture()).then((value) {
                                        if (value == true) {
                                          _gamificationController
                                              .cancelCheckIn();
                                          Get.back();
                                        }
                                      });
                                    } else {
                                      Get.back();
                                    }
                                  }),
                            ),
                          ),
                        ),
                      ),
                      if (_pinnedStopController.showInfo.value &&
                          _pinnedStopController.pinnedStop.value != null)
                        PinnedStopInfoWidget(
                          route: mapRoutesBuilderWidget.getRoute(
                              _pinnedStopController.pinnedStop.value!.stopId),
                          stop: _pinnedStopController.pinnedStop.value!,
                        )
                    ],
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endDocked,
                floatingActionButton: ARFab(
                  onStartAR: (Offset? fabPosition, Size? fabSize) {
                    MatomoTracker.instance.trackEvent(
                        eventCategory: "AR",
                        action: "startAr",
                        eventName: 'changeArMode');
                    _fabExpansionController.fabPosition = fabPosition;
                    _fabExpansionController.fabSize = fabSize;
                    _fabExpansionController.expanded.value = true;

                    _mapUIController
                        .setUserMarker(arModeOn: true)
                        .then((position) {
                      if (!mounted) {
                        return;
                      }
                      final latLon =
                          LatLng(position.latitude, position.longitude);
                      mapController.move(latLon, 16);
                      _mapUIController.centerZoom.value =
                          CenterZoom(center: latLon, zoom: 16);
                      _startAR(context);
                    });
                  },
                  onStopAR: () {
                    MatomoTracker.instance.trackEvent(
                        eventCategory: "AR",
                        action: "stopAr",
                        eventName: 'changeArMode');
                    _stopAR();
                    _mapUIController.setHighlightedStopMarker(
                        highlightedStopId: '',
                        projectedStops: _projectedStops,
                        arModeOn: false,
                        center: mapController.center,
                        zoom: mapController.zoom);

                    _mapUIController
                        .setUserMarker(
                            userPosition: _lastUserPosition?.toArPosition(),
                            arModeOn: false)
                        .then((value) {
                      if (!mounted) {
                        return;
                      }
                      mapController.rotate(0);
                      final routesWithTrips =
                          mapRoutesBuilderWidget.getRoutesWithTrips();
                      _drawTripsPolylineAndStops(routesWithTrips);
                    });
                  },
                  childrenDistance: 70,
                  children: const [],
                ));
          });
        });
  }

  ItineraryVM? _getItinerary(TripStop stop) {
    if (mapRoutesBuilderWidget is MapRouteItineraryWidget) {
      final w = mapRoutesBuilderWidget as MapRouteItineraryWidget;
      if (w.itinerary
          .knowsWalkDirectionsTo(LatLng(stop.stopLat, stop.stopLon))) {
        return w.itinerary;
      }
    }

    return null;
  }

  void _drawTripsPolylineAndStops(List<RouteWithTrip> routes) {
    if (!Get.isRegistered<ArHighlightedAnnotationController>()) {
      Get.put(ArHighlightedAnnotationController());
    }

    _gamificationController.plannedCheckInStopsIds = [];
    _gamificationController.plannedCheckOutStopsIds = [];

    _projectedStops = [];
    _mapUIController.clearData();
    bool isItinerary = mapRoutesBuilderWidget is MapRouteItineraryWidget;

    if (isItinerary) {
      final rStart =
          routes.getFirstWhere((r) => r.route.id != unknownIdStringValue);
      final rEnd =
          routes.getLastWhere((r) => r.route.id != unknownIdStringValue);
      _gamificationController.otpFirstStop = rStart?.trip.stops.first;
      _gamificationController.otpLastStop = rEnd?.trip.stops.last;
    }

    routes.forEach((r) {
      final List<TripStop> stops =
          r.route.id == unknownIdStringValue ? [] : r.trip.stops;

      final polyline = r.trip.shapePolyline.isNotEmpty
          ? r.trip.shapePolyline.toPolyLine()
          : stops.map((s) => LatLng(s.stopLat, s.stopLon)).toList();

      final polyCoordinates =
          polyline.map((c) => turf.Position(c.longitude, c.latitude)).toList();

      if (stops.isNotEmpty) {
        final lineString = turf.LineString(coordinates: polyCoordinates);
        final projectedStops = stops.map((s) {
          return PolylineProjectedStop(s,
              projectedCoords: nearestPointOnLine(
                  lineString,
                  turf.Point(coordinates: turf.Position(s.stopLon, s.stopLat)),
                  turf.Unit.meters));
        }).toList();

        _projectedStops.addAll(projectedStops);

        _mapUIController.tripsMarkers.addAll(
            projectedStops.take(projectedStops.length - 1).map((ps) => Marker(
                height: 14,
                width: 14,
                point: ps.getLatLng(),
                builder: (context) => const PlainStopsMarker(
                      size: 14,
                      borderColor: radarFovColor,
                      centerColor: Colors.white,
                      borderWidth: 3,
                    ))));

        if (isItinerary) {
          _mapUIController.tripShortNamesMarkersData.add(
              TripShortNameMarkerData(
                  latLon: projectedStops.first.getLatLng(),
                  tripShortName: r.trip.shortName ?? unknownStringValue));

          _mapUIController.headsignMarkers.add(Marker(
              rotate: true,
              point: projectedStops.first.getLatLng(),
              builder: (context) => mapRoutesBuilderWidget.getStartMarker(
                  r.trip.shortName ?? unknownStringValue,
                  stops.first.stopName)));

          _gamificationController.plannedCheckInStopsIds
              .add(projectedStops.first.stop.stopId);
          _gamificationController.plannedCheckOutStopsIds
              .add(projectedStops.last.stop.stopId);
        }

        _mapUIController.headsignMarkers.add(Marker(
            rotate: true,
            point: projectedStops.last.getLatLng(),
            builder: (context) =>
                mapRoutesBuilderWidget.getHeadsignMarker(stops.last.stopName)));

        _gamificationController.routes.add(r.route);
      }

      _mapUIController.polylines.add(Polyline(
        points: polyline,
        isDotted: stops.isEmpty,
        color: stops.isEmpty ? walkPolylineColor : radarFovColor,
        strokeWidth: 6,
      ));
    });

    final allDistinctPoints =
        _mapUIController.polylines.expand((p) => p.points).toSet().toList();
    if (allDistinctPoints.isNotEmpty) {
      final lastStop = routes.getLast()?.trip.stops.last;

      // Mostriamo l'icona di fine viaggio solo se l'ultima fermata ha come id unknown ossia
      // è una fermata 'a piedi'.
      if (lastStop?.stopLat != null &&
          lastStop?.stopLon != null &&
          lastStop?.stopId == unknownStringValue) {
        _mapUIController.headsignMarkers.add(Marker(
            point: LatLng(lastStop!.stopLat, lastStop.stopLon),
            rotate: true,
            builder: (context) {
              return const Icon(
                Icons.location_pin,
                size: 30,
                color: Colors.red,
              );
            }));
      }

      // First, set zoom without user position to give an immediate feedback to user
      // (sometimes retrieving user position is slow and map looks empty
      _mapUIController.centerZoom.value = mapController
          .centerZoomFitBounds(LatLngBounds.fromPoints(allDistinctPoints));
      mapController.move(_mapUIController.centerZoom.value.center,
          _mapUIController.centerZoom.value.zoom);

      _locationService.getLastPosition().then((position) {
        if (!mounted) {
          return;
        }

        allDistinctPoints.add(LatLng(position.latitude, position.longitude));
        final zoom = mapController
            .centerZoomFitBounds(LatLngBounds.fromPoints(allDistinctPoints));
        final distanceFromCenter = Geolocator.distanceBetween(
            zoom.center.latitude,
            zoom.center.longitude,
            position.latitude,
            position.longitude);

        var zoomScaleFactor = (distanceFromCenter / 3000.0) * 0.03;
        if (zoomScaleFactor < 0.01) {
          zoomScaleFactor = 0.01;
        } else if (zoomScaleFactor > 0.08) {
          zoomScaleFactor = 0.08;
        }

        final paddedZoom = CenterZoom(
            center: zoom.center, zoom: zoom.zoom * (1 - zoomScaleFactor));
        _mapUIController.centerZoom.value = paddedZoom;
        mapController.move(_mapUIController.centerZoom.value.center,
            _mapUIController.centerZoom.value.zoom);
      });
    }
  }
}
