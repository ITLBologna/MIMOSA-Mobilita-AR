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
import 'package:mimosa/business_logic/enums/trip_modes.dart';
import 'package:mimosa/controllers/view_models/itinerary_preview_step.dart';

class StepPreviewWidget extends StatelessWidget {
  final ItineraryPreviewStep step;
  final bool isSelected;

  const StepPreviewWidget({
    super.key,
    required this.step,
    this.isSelected = false
  });

  @override
  Widget build(BuildContext context) {
    if(step.tripMode == TripMode.walk) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Icon(Icons.directions_walk_outlined, color: Color(step.color),),
              Text(step.duration, style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        ),
      );
    }
    else {
      return SizedBox(
        height: 50,
        width: 50,
        child: Stack(
          children: [
            Center(
              child: Container(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    border: Border.all(color: Color(step.textColor), width: 1),
                    color: Color(step.color)
                ),
                child: Center(child: Text(step.tripShortName ?? '', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Color(step.textColor)),)),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                  ),
                  child: const Icon(Icons.directions_bus, size: 12,),
                ),
              ),
            ),
            if(isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Container(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor
                    ),
                    child: const Icon(Icons.wifi, size: 12,),
                  ),
                ),
              )
          ],
        ),
      );
    }
  }
}