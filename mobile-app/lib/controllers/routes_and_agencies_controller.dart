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
import 'package:mimosa/business_logic/extensions_and_utils/agencies_extensions.dart';
import 'package:mimosa/business_logic/models/apis/agency.dart';
import 'package:mimosa/business_logic/models/section.dart';
import 'package:mimosa/business_logic/services/interfaces/i_agencies_service.dart';
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/location_coords.dart';
import 'package:mimosa/business_logic/services/interfaces/i_routes_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/view_models/routes_and_agencies.dart';

class RoutesAndAgenciesController extends BaseController<RoutesAndAgencies, RoutesAndAgencies, LocationCoords> {
  final routesService = serviceLocator.get<IRoutesService>();
  final agenciesService = serviceLocator.get<IAgenciesService>();

  List<MimosaRoute>? lines;
  List<Agency>? agencies;
  List<Section<MimosaRoute, Agency>>? groupedLines;
  LocationCoords? userPosition;

  @override
  Future<Validation<RoutesAndAgencies>> internalGetDataFromServer(LocationCoords? requestData, {bool? useCache}) {
    userPosition = requestData;

    final routesF = routesService.getRoutes(requestData!);
    final agenciesF = agenciesService.getAgencies();

    return Future.wait(
      [
        routesF,
        agenciesF
      ]
    ).then((results) {
      List<MimosaRoute> routes = [];
      return routesF
        .bindFuture((r) {
          routes = r;
          return agenciesF;
        })
        .map((a) => RoutesAndAgencies(routes: routes, agencies: a));
    });
  }

  int _sortRoutes(MimosaRoute a, MimosaRoute b) {
    var idA = int.tryParse(a.shortName);
    var idB = int.tryParse(b.shortName);
    if(idA != null && idB != null) {
      return idA.compareTo(idB);
    }
    else if(idA == null && idB == null) {
      return a.shortName.compareTo(b.shortName);
    }
    else if(idA == null) {
      return 1;
    }
    else {
      return -1;
    }
  }


  @override
  void internalManageData(RoutesAndAgencies serverData) {
    uiData = Valid(serverData);
    lines = serverData.routes;
    agencies = serverData.agencies.sortByDistanceAsc(userPosition!);

    groupedLines = agencies!.map((a) {
        var ls = lines!.where((l) => l.agencyId == a.id).toList();
        ls.sort(_sortRoutes);
        return Section<MimosaRoute, Agency>(
            sectionContent: ls,
            sectionHeader: a
        );
      })
      .where((s) => s.sectionContent.isNotEmpty)
      .toList();
  }

  List<Section<MimosaRoute, Agency>> filterLines({required String selectedAgencyId, String? searchText}) {
    final result = groupedLines!.where((section) => section.sectionHeader.id == selectedAgencyId).toList();
    if(searchText == null || searchText.isEmpty) {
      return List.from(result);
    }

    return result
            .map((s)
                => Section<MimosaRoute, Agency>(
                    sectionContent: s
                                      .sectionContent
                                      .where((r) => r.shortName.toLowerCase().contains(searchText.toLowerCase()))
                                      .toList(),
                    sectionHeader: s.sectionHeader))
              .where((s) => s.sectionContent.isNotEmpty)
              .toList();
  } 
}