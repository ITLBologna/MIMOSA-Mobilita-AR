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

import 'dart:async';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/business_logic/models/apis/agency.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/location_coords.dart';
import 'package:mimosa/business_logic/models/section.dart';
import 'package:mimosa/controllers/agency_selection_controller.dart';
import 'package:mimosa/controllers/routes_and_agencies_controller.dart';
import 'package:mimosa/controllers/mimosa_search_controller.dart';
import 'package:mimosa/controllers/view_models/agency_vm.dart';
import 'package:mimosa/controllers/view_models/routes_and_agencies.dart';
import 'package:mimosa/ui/library_widgets/controller_driven_widget.dart';
import 'package:mimosa/ui/pages/routes_page/route_search_waiting_widget.dart';
import 'package:mimosa/ui/pages/routes_page/routes_grid_view_widget.dart';
import 'package:mimosa/ui/pages/routes_page/routes_search_widget.dart';
import 'package:mimosa/ui/widgets/mimosa_error_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> with TraceableClientMixin {
  final _routesAndAgenciesController = Get.put(RoutesAndAgenciesController());
  final _agencySelectionController = Get.put(AgencySelectionController());
  final searchRoutesUIController = Get.put(MimosaSearchController());

  StreamSubscription<String>? searchSubscription;
  String lastSearch = '';

  @override
  void dispose() {
    searchSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    searchSubscription = searchRoutesUIController.searchText.listen((searchText) {
      lastSearch = searchText;
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Container(
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ControllerDrivenWidget<AgencySelectionController, List<AgencyVM>, EmptyOption>(
                controller: _agencySelectionController,
                progressIndicator: const RouteSearchWaitingWidget(),
                errorWidget: const SizedBox(),
                enablePullToRefresh: false,
                getBody: (agencies) {
                  return RouteSearchWidget(
                    agencies: agencies,
                  );
                }
            ),
            const Divider(height: 0.3, thickness: 0.3, indent: 15, endIndent: 15, color: Colors.black45,),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ControllerDrivenWidget<RoutesAndAgenciesController, RoutesAndAgencies, LocationCoords>(
                    requestData: const LocationCoords(latitude: 0, longitude: 0),
                    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                    controller: _routesAndAgenciesController,
                    progressIndicator: const RoutesGridViewWidget(useAsProgressIndicator: true,),
                    enablePullToRefresh: false,
                    errorWidget: MimosaErrorWidget(
                      message: AppLocalizations.of(context)!.something_went_wrong,
                    ),
                    getBody: (data) {
                      return GetBuilder<AgencySelectionController>(
                        builder: (_) {
                          // If there is no selected agency, agencies are still loading, so return an empty Container
                          if(_agencySelectionController.getSelected() == null) {
                            return const RoutesGridViewWidget(useAsProgressIndicator: true,);
                          }

                          return Obx(() {
                            List<Section<MimosaRoute, Agency>> sections =
                                _routesAndAgenciesController
                                    .filterLines(
                                      selectedAgencyId: _agencySelectionController.getSelected()!.id,
                                      searchText: searchRoutesUIController.searchText.value
                                    );

                            if (sections.isEmpty) {
                              return MimosaErrorWidget(message: AppLocalizations.of(context)!.no_bus_line_found,);
                            }

                            return RoutesGridViewWidget(sections: sections);
                          });
                        }
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  String get traceName => 'Routes';

  @override
  String get traceTitle => 'RoutesPage';
}