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
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/models/apis/autocomplete_place.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_autocomplete_place_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class AutocompletePlacesService implements IAutocompletePlaceService {
  @override
  Future<Validation<List<AutocompletePlace>>> getAutocompletePlaces({required String input, required LatLng location, double? radiusInMeters}) {
    final iApiService = serviceLocator.get<IApisService>();
    return iApiService.placeAutocomplete(lat: location.latitude, lng: location.longitude, text: input, useCache: true);
  }
}