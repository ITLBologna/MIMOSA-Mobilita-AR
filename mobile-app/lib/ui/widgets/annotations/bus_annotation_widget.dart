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

import 'dart:math';

import 'package:ar_location_view/ar_annotation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mimosa/business_logic/extensions_and_utils/zwidget_math_utils.dart';
import 'package:mimosa/controllers/view_models/buses_positions_infos_vm.dart';
import 'package:vector_math/vector_math.dart' as math;
import 'package:zwidget/zwidget.dart';

class BusAnnotationWidget extends StatefulWidget {
  final String text;
  final double size;
  final TextStyle? textStyle;
  final ArAnnotation<BusPositionInfoVM>? annotation;

  const BusAnnotationWidget({
    super.key,
    required this.text,
    this.annotation,
    this.textStyle,
    this.size = 60,
  });

  @override
  State<BusAnnotationWidget> createState() => _BusAnnotationWidgetState();
}

class _BusAnnotationWidgetState extends State<BusAnnotationWidget> {
  final _contentKey = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double? rotation;
    if(widget.annotation?.data.bearing != null) {
      rotation = getArrowRotationRadiansFromBearings(userBearing: widget.annotation!.azimuth, bearing: widget.annotation!.data.bearing!);
      // var bearing = widget.annotation!.data.bearing!;
      // var azimuth = widget.annotation!.azimuth;
      //
      // rotation = (bearing - azimuth).abs();
      // if(bearing < azimuth) {
      //   rotation = 360 - rotation;
      // }
      //
      // rotation -= 90;
      // if(rotation < 0) {
      //   rotation += 360;
      // }
      //
      // // ZWidget has a strange coordinates mapping
      // // the 1st quarter goes from 0 to 90
      // if(rotation > 270 && rotation <= 360) {
      //   rotation = 360 - rotation;
      // }
      // // The 4th quarter from 0 to -90
      // else if(rotation > 0 && rotation <= 90) {
      //   rotation *= -1;
      // }
      // // The 2nd from 180 to 270 and 3rd to 90 to 180 so we don't need to adjust anything for these quarters

      // final radians = math.radians(rotation);
      // debugPrint('bearing: ${widget.annotation!.busPositionInfo.bearing!} | user: ${widget.annotation!.azimuth} | rotation: $rotation | radians: $radians' );
    }

    var iconSize = widget.size;
    return Column(
      children: [
          Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(widget.size / 2)),
                border: Border.all(color: Colors.black, width: 2),
                color: Colors.white
            ),
            child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: AutoSizeText(
                    widget.text,
                    style: widget.textStyle ?? Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                )
            )
          ),
        if(widget.annotation?.data.bearing != null)
          ZWidget.backwards(
            key: _contentKey,
            midChild: Icon(Icons.arrow_forward, size: iconSize, color: Colors.white,),
            midToBotChild: Icon(Icons.arrow_forward, size: iconSize, color: Colors.black54,),
            botChild: Icon(Icons.arrow_forward, size: iconSize, color: Colors.black,),
            rotationX: 0,
            rotationY: rotation!, // math.radians(rotation!),
            layers: 11,
            depth: 12,
          ),
      ],
    );
  }
}