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
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class PlacesAutocompleteRequestData {
  final LatLng userPosition;
  final String text;

  PlacesAutocompleteRequestData({required this.userPosition, required this.text});
}

class PlacesAutocompleteController extends BaseController<List<AutocompletePlace>, List<AutocompletePlace>, PlacesAutocompleteRequestData> {
  final service = serviceLocator.get<IApisService>();
  List<AutocompletePlace>? places;

  @override
  Future<Validation<List<AutocompletePlace>>> internalGetDataFromServer(PlacesAutocompleteRequestData? requestData, {bool? useCache}) {
    return service.placeAutocomplete(
        lat: requestData!.userPosition.latitude,
        lng: requestData.userPosition.longitude,
        text: requestData.text,
        useCache: useCache
    );
  }

  @override
  void internalManageData(List<AutocompletePlace> serverData) {
    uiData = Valid(serverData);
    places = serverData;
  }
}