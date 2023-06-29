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
import 'package:mimosa/business_logic/enums/trip_modes.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/models/apis/route/itinerary.dart';
import 'package:mimosa/business_logic/models/apis/route/planned_trip.dart';
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/view_models/itinerary_vm.dart';
import 'package:mimosa/controllers/view_models/plan_trip_data.dart';

class ItinerariesController extends BaseController<List<ItineraryVM>, PlannedTrip, PlanTripData> {
  final service = serviceLocator.get<IApisService>();
  List<ItineraryVM>? itineraries;

  @override
  Future<Validation<PlannedTrip>> internalGetDataFromServer(PlanTripData? requestData, {bool? useCache}) {
    return service.planRoute(
        fromLat: requestData!.userPosition.latitude,
        fromLng: requestData.userPosition.longitude,
        toLat: requestData.place.latitude,
        toLng: requestData.place.longitude,
        mode: requestData.mode,
        useCache: useCache);
  }

  @override
  void internalManageData(PlannedTrip serverData) {
    final its = serverData
                          .plan
                          ?.itineraries.map((i) => ItineraryVM(i))
                          .toList() ?? <ItineraryVM>[];

    its.sort((a, b) {
      final aDep = getItineraryBusDeparture(a.itinerary);
      final bDep = getItineraryBusDeparture(b.itinerary);
      // on foot
      if(a.itinerary.legs.length == 1) {
        return -1;
      }

      if(aDep == null && bDep == null) {
        return 0;
      }

      if(aDep == null && bDep != null) {
        return 1;
      }

      if(aDep != null && bDep == null) {
        return -1;
      }

      return aDep!.compareTo(bDep!);
    });

    uiData = Valid(its);
    itineraries = its;
  }

  DateTime? getItineraryBusDeparture(Itinerary itinerary) {
    return itinerary.legs.getFirstWhere((l) => l.mode == TripMode.bus)?.from?.departure;
  }

  bool onlyOnFootIntinerariesAvailables() {
    return itineraries
            ?.where((i) => i.itinerary.legs.where((leg) => leg.mode != TripMode.walk).isNotEmpty)
            .isEmpty == true;
  }

  List<ItineraryVM> getItineraries({int nMaxBus = 2, bool showWalkPath = false, int? maxMinutesAhead}) {
    return itineraries
      ?.where((i) {
        final depTimeInMinutes = getItineraryBusDeparture(i.itinerary)?.difference(DateTime.now()).inMinutes ?? 0;
        debugPrint(depTimeInMinutes.toString());
        return (i.itinerary.legs.where((leg) => leg.mode == TripMode.bus).length <= nMaxBus &&
              (maxMinutesAhead == null || depTimeInMinutes <= maxMinutesAhead)) &&
              (
                  showWalkPath
                    ? true
                    : i.itinerary.legs.where((leg) => leg.mode != TripMode.walk).isNotEmpty
              );
      })
    .toList() ?? <ItineraryVM>[];
  }
}