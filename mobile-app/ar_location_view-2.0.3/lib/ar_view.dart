import 'package:ar_location_view/_annotations_extensions.dart';
import 'package:ar_location_view/services/process_sensors_data_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'ar_location_view.dart';

/// Signature for a function that creates a widget for a given annotation,
typedef AnnotationViewBuilder = Widget Function(
    BuildContext context, ArAnnotation annotation, double userSpeedInMetersPerSecond);

typedef ChangeLocationCallback = void Function(Position position);

class ArView extends StatefulWidget {
  const ArView({
    Key? key,
    required this.onError,
    required this.annotationViewBuilder,
    required this.frame,
    required this.onLocationChange,
    this.arSensorManager,
    this.loader = const Center(
      child: CircularProgressIndicator(),
    ),
    this.maxVisibleDistance = 1500,
    this.minimumVisibleAnnotations,
    this.showDebugInfoSensor = true,
    this.dyAnnotationsOffsetInScreenPercent = 0,
    this.paddingOverlap = 5,
    this.yOffsetOverlap,
    required this.metersAfterWhichNotifyLocationChange,
    required this.onWidgetSizeChange,
    this.scaleWithDistance = true,
    this.markerColor,
    this.backgroundRadar,
    this.radarPosition,
    this.showRadar = true,
    this.radarWidth,
    this.onRadarTap,
    this.radarSatellites = const []
  }) : super(key: key);

  final VoidCallback? onRadarTap;
  final Widget Function(Object? error) onError;
  final Widget loader;
  final ArSensorManager? arSensorManager;
  final AnnotationViewBuilder annotationViewBuilder;
  final double maxVisibleDistance;
  final int? minimumVisibleAnnotations;

  final Size frame;

  final ChangeLocationCallback onLocationChange;

  final bool showDebugInfoSensor;

  /// Annotation vertical offset. Use positive offset to move annotations toward the top, use negative one to move toward the bottom
  final int dyAnnotationsOffsetInScreenPercent;
  final double paddingOverlap;
  final double? yOffsetOverlap;
  final double metersAfterWhichNotifyLocationChange;

  ///Scale annotation view with distance from user
  final bool scaleWithDistance;

  ///Radar
  final List<Widget> radarSatellites;

  /// marker color in radar
  final Color? markerColor;

  ///background radar color
  final Color? backgroundRadar;

  ///radar position in view
  final RadarPosition? radarPosition;

  ///Show radar in view
  final bool showRadar;

  ///Radar width
  final double? radarWidth;

  final OnWidgetSizeChange onWidgetSizeChange;

  @override
  State<ArView> createState() => _ArViewStateEx();
}

abstract class _ArViewState extends State<ArView> {
  late ArSensorManager arSensorManager;
  final highlightedAnnotationController = Get.put(ArHighlightedAnnotationController());
  final fullscreenAnnotationController = Get.put(ArFullscreenAnnotationController());
  Position? position;

  @override
  void initState() {
    if(widget.arSensorManager != null) {
      arSensorManager = widget.arSensorManager!;
    }
    else {
      arSensorManager = ArSensorManager();
      arSensorManager.init();
    }
    super.initState();
  }

  @override
  void dispose() {
    if(widget.arSensorManager == null) {
      arSensorManager.dispose();
    }
    super.dispose();
  }

  Widget _debugInfo(BuildContext context, ArSensor? arSensor) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latitude  : ${arSensor?.location?.latitude}'),
            Text('Longitude : ${arSensor?.location?.longitude}'),
            Text('Pitch     : ${arSensor?.pitch}'),
            Text('Heading   : ${arSensor?.heading}'),
          ],
        ),
      ),
    );
  }
}

class _ArViewStateEx extends _ArViewState {
  late final ProcessSensorsDataService processSensorsDataService;
  ArSensor? lastArSensorData;
  @override
  void initState() {
    processSensorsDataService = Get.put(ProcessSensorsDataService(
        metersAfterWhichNotifyLocationChange: widget.metersAfterWhichNotifyLocationChange,
        defaultUserSpeedInMetersPerSecond: 1.30
    ));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    Alignment radarAlignment;

    switch (widget.radarPosition) {
      case RadarPosition.topLeft:
        radarAlignment = Alignment.topLeft;
        break;
      case RadarPosition.topCenter:
        radarAlignment = Alignment.topCenter;
        break;
      case RadarPosition.topRight:
        radarAlignment = Alignment.topRight;
        break;
      case RadarPosition.bottomLeft:
        radarAlignment = Alignment.bottomLeft;
        break;
      case RadarPosition.bottomRight:
        radarAlignment = Alignment.bottomRight;
        break;
      case RadarPosition.bottomCenter:
      default:
        radarAlignment = Alignment.bottomCenter;
        break;
    }

    return StreamBuilder(
      stream: arSensorManager.arSensor,
      builder: (context, data) {
        if (data.hasData) {
          if (data.data != null) {
            var arSensor = data.data!;
            if (arSensor.location == null) {
              return widget.loader;
            }

            if(lastArSensorData == null) {
              lastArSensorData = arSensor;
            }
            else {
              if((arSensor.heading - lastArSensorData!.heading).abs() < 0.9) {
                arSensor = arSensor.copyWith(heading: lastArSensorData!.heading);
              }
              else {
                lastArSensorData = lastArSensorData!.copyWith(heading: arSensor.heading);
              }

              if((arSensor.pitch - lastArSensorData!.pitch).abs() < 0.9) {
                arSensor = arSensor.copyWith(pitch: lastArSensorData!.pitch);
              }
              else {
                lastArSensorData = lastArSensorData!.copyWith(pitch: arSensor.pitch);
              }
            }

            if(processSensorsDataService.updateUserPositionAndSpeed(arSensor.location!)) {
              widget.onLocationChange(processSensorsDataService.lastUserPosition!);
            }

            final annotationsToShow = processSensorsDataService.calculateAnnotationsToShow(
              arSensor: arSensor,
              maxVisibleDistance: widget.maxVisibleDistance,
              minimumVisibleAnnotations: widget.minimumVisibleAnnotations,
              fullscreenAnnotationId: fullscreenAnnotationController.annotationUid.value,
              screenWidth: width,
              screenHeight: height
            );

            annotationsToShow.screenAnnotations = fullscreenAnnotationController.calculateAnnotationsToShow(annotationsToShow.screenAnnotations);

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) => highlightedAnnotationController.update());
            return Stack(
              children: [
                if (kDebugMode && widget.showDebugInfoSensor)
                  Positioned(
                    bottom: 0,
                    child: _debugInfo(context, arSensor),
                  ),
                CustomMultiChildLayout(
                  delegate: _AnnotationsLayoutDelegate(
                      annotations: annotationsToShow.screenAnnotations,
                      dyAnnotationsOffsetInScreenPercent: widget.dyAnnotationsOffsetInScreenPercent
                  ),
                  // Ordiniamo da quella più lontana a quella più vicina per fare in modo che
                  // in caso di sovrapposizione, una fermata più vicina sia sopra una più lontana
                  children: annotationsToShow.screenAnnotations.reversed.map((a) {
                    var scaleFactor = 1.0;
                    final scaleA = a.scaleWithDistance ?? widget.scaleWithDistance;
                    if(scaleA &&
                        annotationsToShow.radarAnnotations.length > 1 &&
                        !a.highlighted &&
                        fullscreenAnnotationController.annotationUid != a.uid) {
                      scaleFactor = 1 - (a.distanceFromUserInMeters / (annotationsToShow.maxVisibleDistance + 280));
                    }

                    return LayoutId(
                      id: a.uid,
                      child: Transform.scale(
                          scale: scaleFactor,
                          child: widget.annotationViewBuilder(context, a, processSensorsDataService.actualUserSpeedInMetersPerSecond)
                      ));
                    }).toList(),
                ),
                if (widget.showRadar)
                  Obx(() {
                    if(fullscreenAnnotationController.annotationUid.value.isNotEmpty) {
                      return const SizedBox();
                    }

                    return ArRadarWidget(
                      size: widget.radarWidth != null
                              ? widget.radarWidth!
                              : width / 2,
                      heading: arSensor.heading,
                      arAnnotations: annotationsToShow.radarAnnotations.sortByDistance(asc: false),
                      maxDistance: annotationsToShow.maxVisibleDistance,
                      onTap: widget.onRadarTap,
                      alignment: radarAlignment,
                      satellites: widget.radarSatellites,
                      onRadarSizeChange: (Size size, Offset? offset) {
                        widget.onWidgetSizeChange(size, offset);
                      },
                    );
                  }),
                if(arSensor.compassNeedsCalibration)
                  widget.onError(CompassNeedsCalibrationError())
              ],
            );
          }
        }
        return widget.loader;
      },
    );
  }
}

class _AnnotationSizeAndOffsetDecorator {
  final ArAnnotation annotation;
  final Size size;
  Offset offset;

  _AnnotationSizeAndOffsetDecorator({required this.annotation, required this.size, required this.offset});
}

class _AnnotationsLayoutDelegate extends MultiChildLayoutDelegate {
  _AnnotationsLayoutDelegate({
    required this.annotations,
    required this.dyAnnotationsOffsetInScreenPercent
  });

  final List<ArAnnotation> annotations;
  final int dyAnnotationsOffsetInScreenPercent;

  bool _intersects(_AnnotationSizeAndOffsetDecorator annotation1, _AnnotationSizeAndOffsetDecorator annotation2) {
    final ra1 = annotation1.offset & annotation1.size;
    final ra2 = annotation2.offset & annotation2.size;

    return ra1.overlaps(ra2);
  }

  // Perform layout will be called when re-layout is needed.
  @override
  void performLayout(Size size) {
    final List<_AnnotationSizeAndOffsetDecorator> decoratedAnnotations = List.empty(growable: true);
    for (final ArAnnotation a in annotations) {
      final Size currentSize = layoutChild(
        a.uid,
        const BoxConstraints.tightForFinite(),
      );

      double dyOffset;
      double dxOffset;
      if(a.customPositioned) {
        dxOffset = a.arPosition.dx;
        dyOffset = a.arPosition.dy;
      }
      else {
        dyOffset =  100 * dyAnnotationsOffsetInScreenPercent / size.height;
        dyOffset = a.arPosition.dy + (size.height - currentSize.height) * 0.5 - dyOffset;
        dxOffset = a.arPosition.dx + (size.width - currentSize.width) / 2;
      }

      decoratedAnnotations.add(
          _AnnotationSizeAndOffsetDecorator(
              annotation: a,
              size: currentSize,
              offset: Offset(dxOffset, dyOffset)
          )
      );
    }

    decoratedAnnotations.sort((a, b) => a.annotation.distanceFromUserInMeters.compareTo(b.annotation.distanceFromUserInMeters));
    for (final _AnnotationSizeAndOffsetDecorator da in decoratedAnnotations) {
      var i = 0;
      while (i < annotations.length) {
        final da2 = decoratedAnnotations[i];
        if (da.annotation.uid == da2.annotation.uid || da.annotation.canOverlayOtherAnnotations || da2.annotation.canOverlayOtherAnnotations) {
          break;
        }
        final collision = _intersects(da, da2);
        if (collision) {
          da.offset = Offset(da.offset.dx, da2.offset.dy - (da.size.height /*widget.paddingOverlap*/));
        }
        i++;
      }
    }

    for (final _AnnotationSizeAndOffsetDecorator da in decoratedAnnotations) {
      positionChild(da.annotation.uid, da.offset);
    }
  }

  // shouldRelayout is called to see if the delegate has changed and requires a
  // layout to occur. Should only return true if the delegate state itself
  // changes: changes in the CustomMultiChildLayout attributes will
  // automatically cause a relayout, like any other widget.
  @override
  bool shouldRelayout(_AnnotationsLayoutDelegate oldDelegate) {
    return true;
  }
}