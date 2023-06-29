import 'package:ar_location_view/_ar_camera_controller.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ar_location_view.dart';

class ARLocationWidgetUIController extends GetxController {
  final cameraIsPaused = false.obs;
  final cameraIsStopped = true.obs;
}

class ArLocationWidget extends StatefulWidget {
  const ArLocationWidget({
    Key? key,
    required this.onError,
    required this.annotationViewBuilder,
    required this.onLocationChange,
    required this.onWidgetSizeChange,
    this.loader = const Center(
      child: CircularProgressIndicator(),
    ),
    this.maxVisibleDistance = 1500,
    this.frame,
    this.showDebugInfoSensor = true,
    this.dyAnnotationsOffsetInScreenPercent = 0,
    this.paddingOverlap = 5,
    this.yOffsetOverlap,
    this.accessory,
    this.metersAfterWhichNotifyLocationChange = 10,
    this.minimumVisibleAnnotations = 0,
    this.scaleWithDistance = true,
    this.markerColor,
    this.backgroundRadar,
    this.radarPosition,
    this.showRadar = true,
    this.radarWidth,
    this.onRadarTap,
    this.radarSatellites = const [],
    this.viewFinder,
    this.arSensorManager,
    this.viewFinderSelectionDebounceInMilliseconds = 400
  }) : super(key: key);

  final VoidCallback? onRadarTap;
  /// Loader widget
  final Widget loader;

  /// Viewfinder widget used to select annotation on intersection
  final Widget? viewFinder;
  final int viewFinderSelectionDebounceInMilliseconds;

  /// If not set, all annotations are shown
  final int? minimumVisibleAnnotations;
  /// Notify ArLocationWidgetUser that something went wrong
  final Widget Function(Object? error) onError;

  ///Function given context and annotation
  ///return widget for annotation view
  final AnnotationViewBuilder annotationViewBuilder;

  /// Max distance marker visible
  /// Necessary to limit the radar scale
  final double maxVisibleDistance;

  final Size? frame;

  ///Callback when location change
  final ChangeLocationCallback onLocationChange;

  ///Show debug info sensor in debug mode
  final bool showDebugInfoSensor;

  /// Annotation vertical offset. Use positive offset to move annotations toward the top, use negative one to move toward the bottom
  final int dyAnnotationsOffsetInScreenPercent;

  ///Padding when marker overlap
  final double paddingOverlap;

  ///Offset overlap y
  final double? yOffsetOverlap;

  ///accessory
  final Widget? accessory;

  ///Distance in meters after which notify location change
  final double metersAfterWhichNotifyLocationChange;

  ///Scale annotation view with distance from user
  final bool scaleWithDistance;

  /// marker color in radar
  final Color? markerColor;

  ///background radar color
  final Color? backgroundRadar;

  ///radar position in view
  final RadarPosition? radarPosition;

  ///Show radar in view
  final bool showRadar;

  ///Radar width
  final List<Widget> radarSatellites;
  final double? radarWidth;

  final ArSensorManager? arSensorManager;

  final OnWidgetSizeChange onWidgetSizeChange;
  @override
  State<ArLocationWidget> createState() => _ArLocationWidgetState();
}

class _ArLocationWidgetState extends State<ArLocationWidget> with WidgetsBindingObserver {
  late final ARLocationWidgetUIController arLocationWidgetUIController;
  final ArCameraController arCameraController = ArCameraController();
  Future<Validation<CameraController>>? futureCameraController;
  bool pausingResumingPreview = false;

  @override
  void initState() {
    // futureCameraController = arCameraController.init();

    if(Get.isRegistered<ARLocationWidgetUIController>()) {
      arLocationWidgetUIController = Get.find<ARLocationWidgetUIController>();
    }
    else {
      arLocationWidgetUIController = Get.put(ARLocationWidgetUIController());
      arLocationWidgetUIController.cameraIsStopped.value = false;
    }
    super.initState();
  }

  @override
  void dispose() {
    arCameraController.dispose();
    super.dispose();
  }

  void closeCamera() {
    if (arCameraController.controller?.value.isInitialized == true) {
      arCameraController.dispose();
    }
  }

  void initCamera() {
    setState(() {

    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (arCameraController.controller?.value.isInitialized == false) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      closeCamera();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(arLocationWidgetUIController.cameraIsStopped.value) {
        closeCamera();
        return Container(
          color: Colors.black
        );
      }
      else if(arCameraController.controllerState == CameraControllerState.disposed) {
        futureCameraController = arCameraController.init();
      }
      
      return FutureBuilder(
          future: futureCameraController,
          builder: (context, data) {
            if (data.hasError) {
              return widget.onError(data.error);
            }
            else if (data.hasData) {
              if(arLocationWidgetUIController.cameraIsPaused.value) {
                arCameraController.pausePreview();
              }
              else {{
                arCameraController.resumePreview();
              }}

              return data.data!.fold(
                      (failures) => widget.onError(failures.first),
                      (val) =>
                      Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: CameraPreview(arCameraController.controller!),
                          ),
                          ArView(
                            onError: widget.onError,
                            arSensorManager: widget.arSensorManager,
                            annotationViewBuilder: widget.annotationViewBuilder,
                            frame: widget.frame ?? const Size(100, 75),
                            onLocationChange: widget.onLocationChange,
                            maxVisibleDistance: widget.maxVisibleDistance,
                            showDebugInfoSensor: widget.showDebugInfoSensor,
                            paddingOverlap: widget.paddingOverlap,
                            yOffsetOverlap: widget.yOffsetOverlap,
                            metersAfterWhichNotifyLocationChange: widget.metersAfterWhichNotifyLocationChange,
                            scaleWithDistance: widget.scaleWithDistance,
                            markerColor: widget.markerColor,
                            backgroundRadar: widget.backgroundRadar,
                            radarPosition: widget.radarPosition,
                            showRadar: widget.showRadar,
                            radarWidth: widget.radarWidth,
                            onRadarTap: widget.onRadarTap,
                            radarSatellites: widget.radarSatellites,
                            minimumVisibleAnnotations: widget.minimumVisibleAnnotations,
                            onWidgetSizeChange: (Size size, Offset? offset) {
                              widget.onWidgetSizeChange(size, offset);
                            },
                          ),
                          if (widget.accessory != null) widget.accessory!
                        ],
                      )
              );
            }
            else {
              return widget.loader;
            }
          }
      );
    });
  }
}