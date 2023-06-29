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

import 'package:geolocator/geolocator.dart';
import 'package:mimosa/business_logic/models/apis/agency.dart';
import 'package:mimosa/business_logic/models/apis/location_coords.dart';

extension SortAgencies on List<Agency> {
  int _sortAgencies(LocationCoords userPosition, Agency a, Agency b) {
    final aHasCoords = a.lat != null && a.lon != null;
    final bHasCoords = b.lat != null && b.lon != null;

    if(aHasCoords && bHasCoords) {
      final aDist = Geolocator
          .distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          a.lat!, a.lon!);

      final bDist = Geolocator
          .distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          b.lat!, b.lon!);

      return aDist.compareTo(bDist);
    }
    else if(!aHasCoords && !bHasCoords) {
      return a.name.compareTo(b.name);
    }
    else if(aHasCoords) {
      return -1;
    }
    else {
      return 1;
    }
  }

  List<Agency> sortByDistanceAsc(LocationCoords userPosition) {
      sort(Agency a, Agency b) => _sortAgencies(userPosition, a, b);
      final list = List<Agency>.from(this);
      list.sort(sort);
      return list;
  }
}