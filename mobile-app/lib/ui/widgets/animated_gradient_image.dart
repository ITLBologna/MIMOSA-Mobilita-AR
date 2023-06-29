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

class AnimatedGradientImage extends StatefulWidget {
  final List<Color> colorList;
  final IconData icon;
  final double? size;

  const AnimatedGradientImage(
      {Key? key,
        required this.colorList,
        required this.icon,
        required this.size})
      : super(key: key);

  @override
  State<AnimatedGradientImage> createState() => _AnimatedGradientImageState();
}

class _AnimatedGradientImageState extends State<AnimatedGradientImage>
    with SingleTickerProviderStateMixin {
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];

  late Animation<LinearGradient> _animation;
  late LinearGradientTween _tween;
  late AnimationController _animationController;

  int index = 0;
  late Color bottomColor;
  late Color topColor;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;
  late Color initialBottomColor;
  late Color initialTopColor;
  Alignment initialBegin = Alignment.bottomLeft;
  Alignment initialEnd = Alignment.topRight;

  late LinearGradient _initialLinearGradient;
  late LinearGradient _currentLinearGradient;

  @override
  void initState() {
    super.initState();

    bottomColor = widget.colorList[0];
    topColor = widget.colorList[1];
    initialBottomColor = widget.colorList[0];
    initialTopColor = widget.colorList[1];

    _initialLinearGradient = _getGradientFromProperties();
    _currentLinearGradient = _setNextGradientProperties();
    debugPrint('Initial is $_initialLinearGradient');
    debugPrint('Current is $_currentLinearGradient');

    _animationController =
    AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          debugPrint('animation completed');
          _setNewGradient();
        }
      })
      ..addListener(() {
        setState(() {});
      });

    // Start the animation
    _animationController.forward();
    _tween = LinearGradientTween(
        begin: _initialLinearGradient, end: _currentLinearGradient);
    _animation = _tween.animate(_animationController)
      ..addStatusListener((status) {
        debugPrint('Animation status is $status');
        if (status == AnimationStatus.completed) {
          debugPrint('animation completed');
          _setNewGradient();
        }
      });
  }

  void _setNewGradient() {
    _tween.begin = _tween.end;
    _animationController.reset();
    _tween.end = _setNextGradientProperties();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          child: Icon(
            widget.icon,
            color: _animation.value.colors[0], // Use the animated gradient color
            size: widget.size,
          ),
          shaderCallback: (rect) {
            return _animation.value.createShader(rect);
          },
        );
      },
    );
  }


  LinearGradient _setNextGradientProperties() {
    index = index + 1;
    // animate the color
    bottomColor = widget.colorList[index % widget.colorList.length];
    topColor = widget.colorList[(index + 1) % widget.colorList.length];

    // animate the alignment
    begin = alignmentList[index % alignmentList.length];
    end = alignmentList[(index + 2) % alignmentList.length];

    return _getGradientFromProperties();
  }

  LinearGradient _getGradientFromProperties() {
    return LinearGradient(
        begin: begin, end: end, colors: [bottomColor, topColor]);
  }
}

class LinearGradientTween extends Tween<LinearGradient> {
  final LinearGradient begin;
  final LinearGradient end;

  /// Provide a begin and end Gradient. To fade between.
  LinearGradientTween({
    required this.begin,
    required this.end,
  }) : super(begin: begin, end: end);

  @override
  LinearGradient lerp(double t) => LinearGradient.lerp(begin, end, t)!;
}