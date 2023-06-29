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
import 'package:get/get.dart';

class AnimatedCollapsableWidget extends StatefulWidget {
  final Widget child;
  final RxBool expandedObs;
  final Curve curve;
  final Curve reverseCurve;
  final bool invertAnimations;

  const AnimatedCollapsableWidget({
    Key? key,
    required this.child,
    required this.expandedObs,
    this.curve = Curves.easeInBack,
    this.reverseCurve = Curves.easeInBack,
    this.invertAnimations = false
  }) : super(key: key);

  @override
  _AnimatedCollapsableWidgetState createState() => _AnimatedCollapsableWidgetState();
}

class _AnimatedCollapsableWidgetState extends State<AnimatedCollapsableWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final valueToCheck = widget.invertAnimations
                            ? !widget.expandedObs.value
                            : widget.expandedObs.value;
      valueToCheck
          ? _controller.forward()
          : _controller.reverse();

      return SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          child: widget.child
      );
    });
  }
}