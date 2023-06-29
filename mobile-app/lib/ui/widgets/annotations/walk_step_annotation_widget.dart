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

import 'package:ar_location_view/ar_annotation.dart';
import 'package:flutter/material.dart';
import 'package:mimosa/business_logic/extensions_and_utils/zwidget_math_utils.dart';
import 'package:mimosa/business_logic/models/apis/route/polylined_walk_step.dart';
import 'package:mimosa/controllers/walk_step_instructions_controller.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:zwidget/zwidget.dart';

class WalkStepAnnotationWidget extends StatefulWidget {
  final double size;
  final TextStyle? textStyle;
  final ArAnnotation<PolylinedWalkStep> annotation;

  const WalkStepAnnotationWidget({
    super.key,
    required this.annotation,
    this.textStyle,
    this.size = 60,
  });

  @override
  State<WalkStepAnnotationWidget> createState() => _WalkStepAnnotationWidgetState();
}

class _WalkStepAnnotationWidgetState extends State<WalkStepAnnotationWidget> {
  final _contentKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double? rotation;
    if(widget.annotation.data.info.bearing != null) {
      rotation = getArrowRotationRadiansFromBearings(
          userBearing: widget.annotation.azimuth,
          bearing: widget.annotation.data.info.bearing!
      );
    }

    var iconSize = widget.size;
    return Column(
      children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: directionsColor, width: 2),
              color: Colors.white,
            ),
            child: Text(WalkStepInstructionsController.getInstructions(widget.annotation.data.step, context: context))
          ),
        if(rotation != null)
          ZWidget.backwards(
            key: _contentKey,
            midChild: Icon(Icons.arrow_forward, size: iconSize, color: directionsColor,),
            midToBotChild: Icon(Icons.arrow_forward, size: iconSize, color: Colors.black,),
            botChild: Icon(Icons.arrow_forward, size: iconSize, color: Colors.black,),
            rotationX: 0,
            rotationY: rotation,
            layers: 11,
            depth: 12,
          ),
      ],
    );
  }
}