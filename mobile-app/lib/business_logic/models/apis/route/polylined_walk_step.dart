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

import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/extensions_and_utils/turf_extensions.dart';
import 'package:mimosa/business_logic/models/apis/route/walk_step.dart';

class PolylinedWalkStep  {
  final WalkStep step;
  final LatLng projectedLatLng;
  final PointOnPolylineInfo info;
  bool reached = false;

  PolylinedWalkStep({
    required this.step,
    required this.projectedLatLng,
    required this.info,
  });
}