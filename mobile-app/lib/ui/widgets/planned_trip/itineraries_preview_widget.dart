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
import 'package:mimosa/controllers/itineraries_controller.dart';
import 'package:mimosa/controllers/itineraries_quick_filter_controller.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_route_itinerary_widget.dart';
import 'package:mimosa/ui/widgets/mimosa_error_widget.dart';
import 'package:mimosa/ui/widgets/planned_trip/itineraries_quick_filter.dart';
import 'package:mimosa/ui/widgets/planned_trip/itinerary_preview_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItinerariesPreviewWidget extends StatelessWidget {
  final ItinerariesController itinerariesController;
  final void Function() onRefresh;
  const ItinerariesPreviewWidget({super.key, required this.itinerariesController, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Lo costruiamo qui perché ci serve il filterController istanziato dal widget
      final filterWidget = ItinerariesQuickFilter();
      final filterController = Get.find<IntinerariesQuickFilterController>();
      final solutionsFound = filterController.showAtLeastOneResult(itinerariesController);
      if(!solutionsFound) {
        // Necessario altrimenti Obx si lamenta che non usiamo variabili del filter controller
        final fake = filterController.maxBus;

        return MimosaErrorWidget(
          message: AppLocalizations.of(context)!.no_solution_found,
          iconData: Icons.announcement_rounded
        );
      }

      final itineraries = itinerariesController
          .getItineraries(
          nMaxBus: filterController.maxBus,
          showWalkPath: filterController.showWalkPath,
          maxMinutesAhead: filterController.minutesAhead
      );

      return Column(
        children: [
          filterWidget,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: RefreshIndicator(
                onRefresh: () async => onRefresh(),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: itineraries.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.black12, thickness: 0.2, height: 1, indent: 10, endIndent: 10,),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: ()
                        => Get.toNamed(
                            itineraryMapRoute,
                            arguments: () => MapRouteItineraryWidget(itinerary: itineraries[index],)
                        ),
                      child: ItineraryPreviewWidget(itinerary: itineraries[index])
                    );
                  }),
              )
            ),
          ),
        ],
      );
    });
  }
}