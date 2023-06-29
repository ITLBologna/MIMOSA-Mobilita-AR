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

class AnimatedIconWithGradient extends StatefulWidget {
  final List<Color> colors;
  final IconData icon;
  final double size;

  AnimatedIconWithGradient(
      {required this.colors, required this.icon, required this.size});

  @override
  _AnimatedIconWithGradientState createState() =>
      _AnimatedIconWithGradientState();
}

class _AnimatedIconWithGradientState extends State<AnimatedIconWithGradient>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _controller
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _index = (_index + 1) % widget.colors.length;
          });
        }
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final Rect rect = Rect.fromLTRB(0, 0, bounds.width, bounds.height);
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.colors[_index],
                widget.colors[(_index + 1) % widget.colors.length],
              ],
            ).createShader(rect);
          },
          child: Icon(widget.icon, color: Colors.white, size: widget.size),
        );
      },
    );
  }
}
