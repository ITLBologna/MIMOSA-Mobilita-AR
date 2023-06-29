import 'dart:math';

import 'package:flutter/material.dart';

import 'ar_radar.dart';

class ArRadarSatelliteWidget extends StatelessWidget {
  final Color ringColor;
  final Color? color;
  final Gradient? gradient;
  final Widget? child;
  final double ringWidth;
  final double? radarSize;
  final double orbitalDegrees;
  final Size? size;
  final double offsetFromRadar;
  final String? text;
  final RadarPosition radarPosition;
  final Size? radarComputedSize;
  final Offset? radarComputedOffset;
  final double radarOffsetCompensation;

  const ArRadarSatelliteWidget({
    required this.orbitalDegrees,
    this.radarSize,
    this.size,
    this.radarComputedSize,
    this.radarComputedOffset,
    required this.offsetFromRadar,
    required this.radarPosition,
    this.radarOffsetCompensation = 0.0,
    this.child,
    this.color = Colors.black45,
    this.gradient,
    this.ringWidth = 1,
    this.ringColor = Colors.white,
    this.text,
    super.key
  }) : assert(color == null || gradient == null, 'Cannot mix color and gradient: one of them must be null');

  Point<double> _findPointOnRadarCircumference(BuildContext context) {
    // Default radar size is screen width / 2
    final width = MediaQuery.of(context).size.width; //radarSize ?? MediaQuery.of(context).size.width / 2;

    final radians = orbitalDegrees * pi / 180;
    final radiusX = offsetFromRadar;
    final radiusY = offsetFromRadar;
    final x = radiusX * cos(radians);
    final y = radiusY * sin(radians);
    return Point(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final point = _findPointOnRadarCircumference(context);

    return Transform.translate(
      offset: Offset(point.x + radarOffsetCompensation, point.y),
      child: Container(
        width: size?.width,
        height: size?.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: ringColor, width: ringWidth),
          gradient: gradient,
          color: color
        ),
        child: child,
      ),
    );
  }

}