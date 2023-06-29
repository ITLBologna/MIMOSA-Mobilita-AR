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

  const AnimatedGradientImage({
    Key? key,
    required this.colorList,
    required this.icon,
    required this.size,
  }) : super(key: key);

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

  late AnimationController _animationController;
  late Animation<Gradient?> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _animation = _createGradientAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Animation<Gradient?> _createGradientAnimation() {
    final gradientLength = widget.colorList.length;
    final sequenceItems = <TweenSequenceItem<Gradient?>>[];

    for (var i = 0; i < gradientLength; i++) {
      final beginIndex = i % gradientLength;
      final endIndex = (i + 1) % gradientLength;

      final beginColor = widget.colorList[beginIndex];
      final endColor = widget.colorList[endIndex];

      final beginAlignment = alignmentList[beginIndex];
      final endAlignment = alignmentList[endIndex];

      final item = TweenSequenceItem(
        tween: _GradientTween(
          begin: _getGradientFromColorsAndAlignment(beginColor, endColor, beginAlignment, endAlignment),
          end: _getGradientFromColorsAndAlignment(endColor, endColor, beginAlignment, endAlignment),
        ),
        weight: 1.0 / (gradientLength * 2), // Divide by 2 to account for both color and alignment animations
      );

      sequenceItems.add(item);

      final nextEndColor = widget.colorList[(endIndex + 1) % gradientLength];
      final nextEndAlignment = alignmentList[(endIndex + 1) % gradientLength];

      final nextItem = TweenSequenceItem(
        tween: _GradientTween(
          begin: _getGradientFromColorsAndAlignment(endColor, endColor, beginAlignment, endAlignment),
          end: _getGradientFromColorsAndAlignment(endColor, nextEndColor, endAlignment, nextEndAlignment),
        ),
        weight: 1.0 / (gradientLength * 2), // Divide by 2 to account for both color and alignment animations
      );

      sequenceItems.add(nextItem);
    }

    return TweenSequence<Gradient?>(sequenceItems).animate(
      _animationController,
    );
  }



  LinearGradient _getGradientFromColors(Color begin, Color end) {
    return LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: [begin, end],
    );
  }

  LinearGradient _getGradientFromColorsAndAlignment(Color beginColor, Color endColor, Alignment beginAlignment, Alignment endAlignment) {
    return LinearGradient(
      begin: beginAlignment,
      end: endAlignment,
      colors: [beginColor, endColor],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final gradient = _animation.value;
        final fallbackShader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.transparent, Colors.transparent],
        ).createShader(Rect.zero);

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          child: Icon(
            widget.icon,
            color: gradient?.colors[0] ?? Colors.black, // Fallback color
            size: widget.size,
          ),
          shaderCallback: (rect) {
            return gradient?.createShader(rect) ?? fallbackShader;
          },
        );
      },
    );
  }
}

class _GradientTween extends Tween<Gradient?> {
  _GradientTween({Gradient? begin, Gradient? end})
      : super(begin: begin, end: end);

  @override
  Gradient? lerp(double t) {
    if (begin == null || end == null) {
      return begin ?? end;
    }

    if (begin is LinearGradient && end is LinearGradient) {
      final beginGradient = begin as LinearGradient;
      final endGradient = end as LinearGradient;

      return LinearGradient.lerp(beginGradient, endGradient, t);
    }

    // Fallback to returning the begin value
    return begin;
  }
}
