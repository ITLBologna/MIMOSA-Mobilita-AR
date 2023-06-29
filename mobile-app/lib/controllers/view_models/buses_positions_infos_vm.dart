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
import 'package:mimosa/business_logic/models/apis/buses_positions/bus_position_info.dart';
import 'package:mimosa/business_logic/extensions_and_utils/polyline_extension.dart';
import 'package:uuid/uuid.dart';

class BusesPositionsInfosVM {
  DateTime? expiresAt;
  final String tripShortName;
  List<BusPositionInfoVM> infos = [];

  BusesPositionsInfosVM({
    required this.tripShortName
  });
}

class BusPositionInfoVM {
  final BusInfo info;
  final String tripShortName;
  List<LatLng> polyline;
  LatLng projectedCoords;
  double? bearing;
  int indexOnPolyline = -1;
  DateTime updatedAt;

  BusPositionInfoVM({
    required this.tripShortName,
    required this.info,
    required this.polyline
  }) : projectedCoords = LatLng(info.busPosition.latitude, info.busPosition.longitude), updatedAt = info.updatedAt;

  void projectCoords() {
    final latLon = polyline.projectLatLon(info.busPosition.latitude, info.busPosition.longitude);
    projectedCoords = LatLng(latLon.latitude, latLon.longitude);
  }
}