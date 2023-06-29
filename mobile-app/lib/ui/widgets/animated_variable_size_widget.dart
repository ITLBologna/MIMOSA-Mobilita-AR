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

class AnimatedVariableSizeWidget extends StatefulWidget {  
  final Widget child;
  final Axis axis;
  final RxBool expandedObs;
  final Curve curve;
  final Curve reverseCurve;
  final int duration;
  final int reverseDuration;

  final void Function()? onEnd;
  const AnimatedVariableSizeWidget({
    Key? key,
    required this.child,
    required this.expandedObs,
    this.axis = Axis.vertical,
    this.onEnd,
    this.curve = Curves.easeIn,
    this.reverseCurve = Curves.elasticOut,
    this.duration = 200,
    this.reverseDuration = 600
    }) : super(key: key);

  @override
  State<AnimatedVariableSizeWidget> createState() => _AnimatedVariableSizeWidgetState();
}

class _AnimatedVariableSizeWidgetState extends State<AnimatedVariableSizeWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      reverseDuration: Duration(milliseconds: widget.reverseDuration),
      vsync: this,
    )..addStatusListener((status) {
      if(status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        widget.onEnd?.call();
      }
    });
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

      widget.expandedObs.value
          ? _controller.forward()
          : _controller.reverse();

      return SizeTransition(
              sizeFactor: _animation,
              axis: widget.axis,
              child: widget.child
            );
    }); 
  }
}