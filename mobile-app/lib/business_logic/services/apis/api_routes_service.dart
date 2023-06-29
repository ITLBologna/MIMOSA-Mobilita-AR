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
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/location_coords.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_routes_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class ApiRoutesService implements IRoutesService {
  @override
  Future<Validation<List<MimosaRoute>>> getRoutes(LocationCoords coords) {
    return serviceLocator
        .get<IApisService>()
        .getRoutes(lat: coords.latitude, lon: coords.longitude, useCache: true);
  }
}

