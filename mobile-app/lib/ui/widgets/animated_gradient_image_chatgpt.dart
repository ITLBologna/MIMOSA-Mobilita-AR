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

class AnimatedIconGradient extends StatefulWidget {
  final List<Color> colors;
  final IconData iconData;
  final Duration duration;
  final double size;

  const AnimatedIconGradient({
    Key? key,
    required this.colors,
    required this.iconData,
    this.duration = const Duration(seconds: 2),
    this.size = 24.0,
  }) : super(key: key);

  @override
  _AnimatedIconGradientState createState() => _AnimatedIconGradientState();
}

class _AnimatedIconGradientState extends State<AnimatedIconGradient>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<RadialGradient> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = _createAnimation();
    _controller.repeat(reverse: true);
  }

  Animation<RadialGradient> _createAnimation() {
    final beginGradient = RadialGradient(
      colors: widget.colors,
      center: Alignment.center,
      radius: 1.0,
    );

    final endGradient = RadialGradient(
      colors: widget.colors.reversed.toList(),
      center: Alignment.center,
      radius: 1.0,
    );

    return _controller.drive(
      RadialGradientTween(
        begin: beginGradient,
        end: endGradient,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedIconGradient oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.colors != oldWidget.colors) {
      _animation = _createAnimation();
      _controller.reset();
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) =>
              _animation.value.createShader(bounds),
          child: Icon(
            widget.iconData,
            size: widget.size,
          ),
        );
      },
    );
  }
}

class RadialGradientTween extends Tween<RadialGradient> {
  RadialGradientTween({required RadialGradient begin, required RadialGradient end})
      : super(begin: begin, end: end);

  @override
  RadialGradient lerp(double t) {
    return RadialGradient.lerp(begin, end, t)!;
  }
}



