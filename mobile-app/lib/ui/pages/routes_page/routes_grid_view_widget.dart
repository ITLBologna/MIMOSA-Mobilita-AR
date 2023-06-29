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
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/models/apis/agency.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/section.dart';
import 'package:mimosa/routes.dart';
import 'package:mimosa/ui/widgets/map_widgets/map_route_trips_widgets/map_route_trips_widget.dart';
import 'package:mimosa/ui/widgets/route_or_trip_box_widget.dart';
import 'package:mimosa/ui/widgets/sections_with_header_slivers.dart';
import 'package:shimmer/shimmer.dart';

class RoutesGridViewWidget extends StatelessWidget {
  final bool useAsProgressIndicator;
  final List<Section<MimosaRoute, Agency>> sections;

  const RoutesGridViewWidget({
    this.useAsProgressIndicator = false,
    this.sections = const [],
    super.key
  });

  @override
  Widget build(BuildContext context) {
    var s = sections;
    if(useAsProgressIndicator) {
      s = [
        Section(
          sectionContent: List<MimosaRoute>.generate(100, (index) => MimosaRoute(
            id: 'fake',
            agencyId: 'fake',
            shortName: '',
            longName: '',
            type: '',
            hexColor: hexToInt('FFF')!,
            hexTextColor: hexToInt('FFF')!
          )),
          sectionHeader: Agency(id: 'fake', name: 'fake', url: '')
        )
      ];
    }

    Widget grid = GridViewWithSections<MimosaRoute, Agency>(
        s,
        sliverGridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 60.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 1.0,
        ),
        buildWidget: (context, route) =>
            GestureDetector(
                onTap: ()
                => Get.toNamed(
                    tripsMapPageRoute,
                    arguments: () => MapRouteTripsWidget(route: route,)
                ),
                child: RouteOrTripBoxWidget(route: route)
            ),
        buildHeader: (context, agency) => const SizedBox(height: 20,)
      // Container(
      //   padding: const EdgeInsets.only(top: 20.0, bottom: 25),
      //   child: Text(agency.name, style: Theme.of(context).textTheme.headlineSmall,),
      // ),
    );

    if(useAsProgressIndicator) {
       grid = Shimmer.fromColors(
         baseColor: Colors.grey[300]!,
         highlightColor: Colors.grey[100]!,
         enabled: true,
         child: grid
       );
    }

    const mainPadding = EdgeInsets.only(left: 15.0, right: 15, bottom: 15);
    return SafeArea(
      top: false,
      child: Padding(
        padding: mainPadding,
        child: Container(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
            ),
          ),
          child: grid
        ),
      ),
    );
  }

}