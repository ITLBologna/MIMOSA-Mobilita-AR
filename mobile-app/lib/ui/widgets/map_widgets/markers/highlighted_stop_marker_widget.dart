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
import 'package:mimosa/business_logic/services/i_directions_service.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';

class HighlightedStopMarkerWidget extends StatelessWidget {
  final String stopName;
  final Color borderColor;
  final Color navigateToIconColor;
  final double width;
  final String? tripShortName;
  final VoidCallback? onNavigate;

  const HighlightedStopMarkerWidget({
    required this.stopName,
    required this.borderColor,
    required this.navigateToIconColor,
    required this.width,
    this.onNavigate,
    this.tripShortName,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          border: Border.all(color: borderColor, width: 2),
          color: Colors.white
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // If we need to incorporate bus short name indications...
          if(tripShortName?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, bottom: 2, right: 2),
              child: Container(
                height: 25,
                width: 25,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: lightMimosaYellow
                ),
                child: Center(
                    child: AutoSizeText(
                      tripShortName!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    )
                )
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: AutoSizeText(
                stopName,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                minFontSize: 6,
              ),
            ),
          ),
          IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              onPressed: () {
                onNavigate?.call();
              },
              icon: Icon(Icons.assistant_navigation, color: navigateToIconColor, size: 25)
          ),
        ],
      ),
    );
  }
}