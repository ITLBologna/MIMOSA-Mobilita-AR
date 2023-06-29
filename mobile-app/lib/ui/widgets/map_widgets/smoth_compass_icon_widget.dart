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

import 'package:flutter/material.dart';
import 'package:turf/helpers.dart';

class SmoothCompassIconWidget extends StatefulWidget {
  final double deegrees;
  final double size;
  final Color backgroundColor;

  const SmoothCompassIconWidget(
      {Key? key,
      this.deegrees = 0.0,
      this.size = 24,
      this.backgroundColor = Colors.black})
      : super(key: key);

  @override
  State<SmoothCompassIconWidget> createState() =>
      _SmoothCompassIconWidgetState();
}

class _SmoothCompassIconWidgetState extends State<SmoothCompassIconWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration:
          BoxDecoration(color: widget.backgroundColor, shape: BoxShape.circle),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CustomPaint(
          painter: _SmoothCompassPainter(degrees: widget.deegrees),
        ),
      ),
    );
  }
}

class _SmoothCompassPainter extends CustomPainter {
  double degrees = 0.0;

  _SmoothCompassPainter({this.degrees = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint northPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    Paint southPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;

    // Paint debugPaint = Paint()
    //   ..color = Colors.green.withAlpha(50)
    //   ..style = PaintingStyle.fill;
    // Path debugPath = Path();
    // debugPath.moveTo(0, 0);
    // debugPath.lineTo(size.width, 0);
    // debugPath.lineTo(size.width, size.height);
    // debugPath.lineTo(0, size.height);
    // debugPath.close();

    Path northPath = Path();
    Path southPath = Path();

    northPath.moveTo(size.width / 2, 0.0);
    northPath.relativeLineTo(4, size.height / 2);
    northPath.relativeLineTo(-2, 0);
    northPath.relativeArcToPoint(const Offset(-4, 0),
        radius: const Radius.circular(2.0), clockwise: false);
    northPath.relativeLineTo(-2, 0);
    northPath.close();

    southPath.moveTo(size.width / 2, size.height);
    southPath.relativeLineTo(4, -(size.height / 2));
    southPath.relativeLineTo(-2, 0);
    southPath.relativeArcToPoint(const Offset(-4, 0),
        radius: const Radius.circular(2.0), clockwise: true);
    southPath.relativeLineTo(-2, 0);
    southPath.close();

    //canvas.drawPath(debugPath, debugPaint);

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(degreesToRadians(degrees).toDouble());
    canvas.translate(-(size.width / 2), -(size.height / 2));
    canvas.drawPath(northPath, northPaint);
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant _SmoothCompassPainter oldDelegate) {
    return oldDelegate.degrees != degrees;
  }
}
