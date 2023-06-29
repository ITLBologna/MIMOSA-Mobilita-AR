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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/ar_mode_switch_controller.dart';

@immutable
class ARFab extends StatefulWidget {
  final void Function(Offset? fabPosition, Size? fabSize) onStartAR;
  final void Function() onStopAR;

  const ARFab({
    super.key,
    required this.onStartAR,
    required this.onStopAR,
    required this.childrenDistance,
    required this.children,
  });

  final double childrenDistance;
  final List<Widget> children;

  @override
  State<ARFab> createState() => _ARFabState();
}

class _ARFabState extends State<ARFab> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  late final ArModeSwitchController _arModeSwitchController;
  late final GlobalKey _key;

  @override
  void initState() {
    super.initState();

    _key = GlobalKey();
    _arModeSwitchController = Get.find<ArModeSwitchController>();
    _controller = AnimationController(
      value: _arModeSwitchController.isInARMode.value ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(void Function() action) {
    _arModeSwitchController.isInARMode.value = !_arModeSwitchController.isInARMode.value;
    action();
  }

  @override
  Widget build(BuildContext context) {
    final fabChild = Image.asset('assets/images/ar-cube-100.png', width: 30,);

    return Obx(() {
        if (_arModeSwitchController.isInARMode.value) {
          _controller.forward();
        }
        else {
          _controller.reverse();
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            FloatingActionButton(
              key: _key,
              heroTag: 'ArTag',
              backgroundColor: Colors.red,
              onPressed: () => _toggle(widget.onStopAR),
              child: fabChild,
            ),
            // ..._buildExpandingActionButtons(),
            IgnorePointer(
              ignoring: _arModeSwitchController.isInARMode.value,
              child: AnimatedOpacity(
                opacity: _arModeSwitchController.isInARMode.value ? 0.0 : 1.0,
                curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
                duration: const Duration(milliseconds: 250),
                child: FloatingActionButton(
                  onPressed: () {

                    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
                    final position = renderBox?.localToGlobal(Offset.zero) ;

                    _toggle(() => widget.onStartAR(position, _key.currentContext?.size));
                  },
                  child: fabChild,
                ),
              ),
            ),
          ],
        );
      });
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0; i < count; i++, angleInDegrees += step) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 90,
          maxDistance: widget.childrenDistance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 4.0,
      child: TextButton(
        onPressed: () => debugPrint('pressed'),
        child: icon,
      ),
    );
  }
}