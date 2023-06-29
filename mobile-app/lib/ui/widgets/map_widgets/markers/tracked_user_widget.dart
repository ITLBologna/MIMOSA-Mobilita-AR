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

import 'dart:io';

import 'package:ar_location_view/ar_location_view.dart';
import 'package:flutter/material.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';

class TrackedUserWidget extends StatelessWidget {
  const TrackedUserWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: const RadarPainter(
            maxDistance: 0,
            arAnnotations: [],
            heading: 0,
            markerColor: Colors.red,
            background: Colors.white,
            fovColor: radarFovColor
        ),
        child: Center(
          child: Container(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Colors.white, width: 2),
                color: radarFovColor
            ),
          ),
        )
    );
  }

}