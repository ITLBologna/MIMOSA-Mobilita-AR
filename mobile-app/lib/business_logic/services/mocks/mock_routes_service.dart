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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/location_coords.dart';
import 'package:mimosa/business_logic/services/interfaces/i_routes_service.dart';

class MockRoutesService implements IRoutesService {
  @override
  Future<Validation<List<MimosaRoute>>> getRoutes(LocationCoords coords) {
    List<MimosaRoute> lines = [];
    for(int i = 1; i < 101; i ++) {
      lines.add(MimosaRoute(
          id: i.toString(),
          agencyId: 'agency $i',
          shortName: i.toString(),
          longName: 'Linea $i',
          type: 't',
          hexColor: hexToInt(RandomColor.getColor(Options(format: Format.hex))),
          hexTextColor: hexToInt(RandomColor.getColor(Options(format: Format.hex))),
          )
      );
    }

    return lines.toValidFuture();
  }

  int hexToInt(dynamic hex) {
    var hexColor = hex as String;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }

    return int.parse("0x$hexColor");
  }
}

