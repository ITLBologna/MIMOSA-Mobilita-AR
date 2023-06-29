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
import 'package:mimosa/business_logic/services/interfaces/i_autocomplete_place_service.dart';

List<AutocompletePlace> places = <AutocompletePlace>[
  AutocompletePlace(
      name: '',
      description: 'Sasso Marconi',
      latitude: 44.41036535257505,
      longitude: 11.244800884509296
  ),
  AutocompletePlace(
      name: '',
    description: 'Via Andrea Costa, 202, 40134 Bologna BO',
    latitude: 44.49319809850677,
    longitude: 11.30595918960577
  ),
  AutocompletePlace(
      name: '',
      description: 'Antoniano, Via Guido Guinizelli, 3, 40125 Bologna BO',
      latitude: 44.48664344016538,
      longitude: 11.35948431348462
  ),
  AutocompletePlace(
      name: '',
      description: 'Strada Statale 64 Porrettana, 40128 Bologna BO',
      latitude: 44.520704,
      longitude: 11.362381
  ),

  AutocompletePlace(
      name: '',
      description: 'Via Andrea Costa, 202, 40134 Bologna BO',
      latitude: 44.49319809850677,
      longitude: 11.30595918960577
  ),
  AutocompletePlace(
      name: '',
      description: 'Antoniano, Via Guido Guinizelli, 3, 40125 Bologna BO',
      latitude: 44.48664344016538,
      longitude: 11.35948431348462
  ),
  AutocompletePlace(
      name: '',
      description: 'Strada Statale 64 Porrettana, 40128 Bologna BO',
      latitude: 44.520704,
      longitude: 11.362381
  ),

  AutocompletePlace(
      name: '',
      description: 'Via Andrea Costa, 202, 40134 Bologna BO',
      latitude: 44.49319809850677,
      longitude: 11.30595918960577
  ),
  AutocompletePlace(
      name: '',
      description: 'Antoniano, Via Guido Guinizelli, 3, 40125 Bologna BO',
      latitude: 44.48664344016538,
      longitude: 11.35948431348462
  ),
  AutocompletePlace(
      name: '',
      description: 'Strada Statale 64 Porrettana, 40128 Bologna BO',
      latitude: 44.520704,
      longitude: 11.362381
  ),

];

class MockAutocompletePlacesService implements IAutocompletePlaceService {
  @override
  Future<Validation<List<AutocompletePlace>>> getAutocompletePlaces({required String input, required LatLng location, double? radiusInMeters}) {
    return places
            .where((p) => p.description.toLowerCase().contains(input.toLowerCase()))
            .toList()
            .toValidFuture();
  }
}