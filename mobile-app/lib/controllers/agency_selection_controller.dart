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

import 'package:geolocator/geolocator.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/extensions_and_utils/agencies_extensions.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/models/apis/agency.dart';
import 'package:mimosa/business_logic/models/apis/location_coords.dart';
import 'package:mimosa/business_logic/services/interfaces/i_agencies_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/controllers/view_models/agency_vm.dart';

class AgencySelectionController extends BaseController<List<AgencyVM>, List<Agency>, EmptyOption> {
  LocationCoords? _userPosition;
  List<AgencyVM> agencies = [];

  @override
  Future<Validation<List<Agency>>> internalGetDataFromServer(EmptyOption? requestData, {bool? useCache}) {
    final agenciesService = serviceLocator.get<IAgenciesService>();
    final locationService = serviceLocator.get<ILocationService>();
    return locationService
        .getLastPosition()
        .then((value) {
            _userPosition = LocationCoords(latitude: value.latitude, longitude: value.longitude);
            return agenciesService.getAgencies();
        });
  }

  @override
  void internalManageData(List<Agency> serverData) {
    agencies = serverData
                .sortByDistanceAsc(_userPosition!)
                .map((a) => AgencyVM(agency: a))
                .toList();
    agencies.first.select();
    uiData = Valid(agencies);
  }

  void select({required int index}) {
    for (var a in agencies) {
      a.select(false);
    }
    agencies[index].select();
  }

  Agency? getSelected() {
    return agencies.getFirstWhere((a) => a.isSelected)?.agency;
  }

  void selectFromValue(String? id) {
    for (var a in agencies) {
      a.select(false);
    }

    var foundAgency = agencies.getFirstWhere((a) => a.agency.id == id);
    MatomoTracker.instance.trackEvent(eventCategory: 'Route', action: foundAgency?.agency.id ?? 'N/D', eventName: "selectAgency");
    foundAgency?.select();
    update();
  }
}