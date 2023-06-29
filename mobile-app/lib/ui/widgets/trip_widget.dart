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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/ui/widgets/map_widgets/markers/headsign_flag_marker.dart';
import 'package:mimosa/ui/widgets/route_or_trip_box_widget.dart';

class TripWidget extends StatelessWidget {
  final MimosaRoute route;
  final Trip trip;
  final double size;
  final bool isSelected;
  final bool isExpanded;
  final Color? textColor;

  const TripWidget(
      {super.key,
      required this.route,
      required this.trip,
      this.size = 25,
      this.textColor,
      this.isExpanded = true,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    var fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;
    Widget textWidget = Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: AutoSizeText(
        trip.headsign ?? trip.stops.last.stopName,
        maxLines: 1,
        minFontSize: 6,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: fontWeight, color: textColor),
      ),
    );

    if (isExpanded) {
      textWidget = Expanded(child: textWidget);
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
            height: size,
            constraints: BoxConstraints(minWidth: size),
            child: RouteOrTripBoxWidget(
              route: route,
              trip: trip,
            )),
        textWidget,
        if (isSelected) const HeadsignFlagMarker(size: 30)
      ],
    );
  }
}
