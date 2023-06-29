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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:mimosa/controllers/itineraries_controller.dart';
import 'package:mimosa/controllers/view_models/itinerary_vm.dart';
import 'package:mimosa/controllers/view_models/plan_trip_data.dart';
import 'package:mimosa/ui/library_widgets/controller_driven_widget.dart';
import 'package:mimosa/ui/widgets/mimosa_error_widget.dart';
import 'package:mimosa/ui/widgets/planned_trip/itineraries_preview_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItinerariesPage extends StatelessWidget {
  final PlanTripData requestData;
  final itinerariesController = Get.put(ItinerariesController());
  ItinerariesPage({super.key}) : requestData = Get.arguments;

  @override
  Widget build(BuildContext context) {

    MatomoTracker.instance.trackScreenWithName(widgetName: 'Itineraries', eventName: 'Open Itineraries page');

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
          title: Text(AppLocalizations.of(context)!.itineraries),
        ),
        body: ControllerDrivenWidget<ItinerariesController, List<ItineraryVM>, PlanTripData>(
          requestData: requestData,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          controller: itinerariesController,
          errorWidget: MimosaErrorWidget(
            message: AppLocalizations.of(context)!.something_went_wrong,
          ),
          getBody: (data) {
            return ItinerariesPreviewWidget(
              itinerariesController: itinerariesController,
              onRefresh: () => itinerariesController.forceReloadDataAndUpdateUI(requestData),
            );
          }
        )
    );
  }
}