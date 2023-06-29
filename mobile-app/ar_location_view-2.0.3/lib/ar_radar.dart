import 'dart:math';

import 'package:flutter/material.dart';
import 'ar_location_view.dart';
import 'widget_size_render_object.dart';

enum RadarPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

typedef OnWidgetSizeChange = void Function(Size size, Offset? offset);

class RadarPainter extends CustomPainter {
  const RadarPainter(
      {required this.maxDistance,
      required this.arAnnotations,
      required this.heading,
      required this.markerColor,
      required this.background,
      this.fovColor = Colors.blueAccent});

  final angle = pi / 7;

  final Color markerColor;
  final Color background;
  final Color fovColor;
  final double maxDistance;
  final List<ArAnnotation> arAnnotations;
  final double heading;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final angleView = -(angle + heading.toRadians);
    final angleView1 = -(-angle + heading.toRadians);
    final center = Offset(radius, radius);
    final Path path = Path();
    final pointA =
        Offset(radius * (1 - sin(angleView)), radius * (1 - cos(angleView)));
    final pointB =
        Offset(radius * (1 - sin(angleView1)), radius * (1 - cos(angleView1)));
    path.moveTo(pointA.dx, pointA.dy);
    path.lineTo(radius, radius);
    path.lineTo(pointB.dx, pointB.dy);
    path.arcToPoint(pointA, radius: Radius.circular(radius));

    final Paint paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          fovColor.withAlpha(168),
          fovColor.withAlpha(20),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(radius, radius),
        radius: radius,
      ))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint2);
    drawMarker(canvas, arAnnotations, radius);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void drawMarker(
      Canvas canvas, List<ArAnnotation> annotations, double radius) {
    for (final annotation in annotations) {
      final Paint paint = Paint()
        ..color = annotation.isGrayed
            ? Colors.grey
            : Color(annotation.radarMarkerColorHex);
      final distanceInRadar =
          annotation.distanceFromUserInMeters / maxDistance * radius;
      final alpha = pi - annotation.azimuth.toRadians;
      final dx = (distanceInRadar) * sin(alpha);
      final dy = (distanceInRadar) * cos(alpha);
      final center = Offset(dx + radius, dy + radius);
      canvas.drawCircle(center, 3, paint);
    }
  }
}

class ArRadarWidget extends StatefulWidget {
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color ringColor;
  final Color fovColor;
  final Alignment alignment;

  final List<Widget> satellites;
  final double ringThickness;
  final double maxDistance;
  final List<ArAnnotation> arAnnotations;
  final double heading;
  final VoidCallback? onTap;

  final OnWidgetSizeChange onRadarSizeChange;

  const ArRadarWidget(
      {super.key,
      required this.size,
      required this.heading,
      required this.arAnnotations,
      required this.maxDistance,
      required this.onRadarSizeChange,
      this.satellites = const [],
      this.onTap,
      this.ringThickness = 5,
      this.alignment = Alignment.bottomCenter,
      this.backgroundColor = Colors.black,
      this.fovColor = const Color(0xFF4682B4),
      this.ringColor = Colors.white,
      this.borderColor = Colors.black45});

  @override
  State<ArRadarWidget> createState() => _ArRadarWidgetState();
}

class _ArRadarWidgetState extends State<ArRadarWidget> {
  Size? computedRadarSize;
  Offset? computedRadarOffset;

  @override
  Widget build(BuildContext context) {

    const radarPadding = EdgeInsets.symmetric(vertical: 10.0, horizontal: 24);

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: widget.alignment,
        child: Stack(
          alignment: widget.alignment,
          children: [
            Padding(
              padding: radarPadding,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.all(Radius.circular(widget.size / 2)),
                  border: Border.all(
                      color: widget.ringColor, width: widget.ringThickness),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Container(
                        width: widget.size - (widget.ringThickness * 2),
                        height: widget.size - (widget.ringThickness * 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(
                                (widget.size - (widget.ringThickness * 2)) /
                                    2)),
                            border: Border.all(color: widget.borderColor),
                            color: widget.backgroundColor.withAlpha(120)),
                        child: Transform.rotate(
                          angle: -widget.heading.toRadians,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CustomPaint(
                                painter: RadarPainter(
                                    maxDistance: widget.maxDistance,
                                    arAnnotations: widget.arAnnotations,
                                    heading: widget.heading,
                                    markerColor: Colors.red,
                                    background: Colors.white,
                                    fovColor: widget.fovColor),
                                child: Center(
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(3)),
                                        border:
                                            Border.all(color: widget.ringColor),
                                        color: widget.fovColor),
                                  ),
                                )),
                          ),
                        )),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: radarPadding.right),
              child: SizedBox(
                height: widget.size,
                child: Stack(
                  alignment: Alignment(Alignment.center.x, Alignment.center.y),
                  children: [
                    Container(
                        //color: Colors.red.withOpacity(0.2),
                        ),
                    ...widget.satellites
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
