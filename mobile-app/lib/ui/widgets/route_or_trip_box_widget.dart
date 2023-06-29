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

class RouteOrTripBoxWidget extends StatelessWidget {
  final MimosaRoute route;
  final Trip? trip;
  final double? size;

  const RouteOrTripBoxWidget({
    super.key,
    required this.route,
    this.trip,
    this.size
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: Color(route.hexTextColor), width: 1),
        color: Color(route.hexColor),
      ),
      child: Center(
        child: AutoSizeText(
            trip?.shortName ?? route.shortName,
            maxLines: 1,
            minFontSize: 8,
            maxFontSize: 14,
            style: Theme
                .of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Color(route.hexTextColor), fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}