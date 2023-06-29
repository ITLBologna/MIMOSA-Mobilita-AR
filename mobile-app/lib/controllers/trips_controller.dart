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
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/polyline_extension.dart';

class TripsController extends BaseController<List<Trip>, List<Trip>, String> {
  final service = serviceLocator.get<IApisService>();
  List<Trip>? trips;

  @override
  Future<Validation<List<Trip>>> internalGetDataFromServer(String? requestData, {bool? useCache}) {
    return service.getTrips(routeId: requestData!, useCache: useCache);
  }

  @override
  void internalManageData(List<Trip> serverData) {
    serverData = serverData
                  .distinctBy((e) => e.stops.last.stopId)
                  .toList();
    serverData.sort((a, b) => a.directionId.compareTo(b.directionId));

    uiData = Valid(serverData);
    trips = serverData;
  }

  List<LatLng>? getTripPolyline(String tripId) {
    var trip = trips?.getFirstWhere((t) => t.id == tripId);
    return trip?.shapePolyline.toPolyLine();
  }
}