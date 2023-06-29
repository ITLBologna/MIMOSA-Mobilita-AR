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
import 'package:mimosa/controllers/itineraries_quick_filter_controller.dart';

class ItinerariesQuickFilter extends StatelessWidget {
  final filterController = Get.put(IntinerariesQuickFilterController());
  ItinerariesQuickFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(thickness: 3,),
        SizedBox(
          height: 40,
          child: Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => filterController.toggleShowWalkPath(),
                  icon: Icon(
                    Icons.directions_walk,
                    color: filterController.showWalkPath
                        ? Colors.green
                        : Theme
                        .of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                  ),
                ),
                VerticalDivider(width: 10,
                  thickness: 0.3,
                  color: Theme
                      .of(context)
                      .textTheme
                      .bodySmall
                      ?.color,
                  indent: 5,
                  endIndent: 5,),
                TextButton(
                  onPressed: () => filterController.nextMaxNChanges(),
                  child: Row(
                    children: [
                      Text(
                        'Max:',
                        style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black87),),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: filterController.maxBus,
                            itemBuilder: (context, _) {
                              return const Icon(Icons.directions_bus, color: Colors.black87);
                            }
                        ),
                      )
                    ],
                  ),
                ),
                VerticalDivider(width: 10,
                  thickness: 0.3,
                  color: Theme
                      .of(context)
                      .textTheme
                      .bodySmall
                      ?.color,
                  indent: 5,
                  endIndent: 5,),
                TextButton(
                  onPressed: () => filterController.nextMaxMinutesAhead(),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.black87),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          filterController.minutesAhead.toString(),
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                )
              ],
            );
          }),
        ),
        const Divider(thickness: 3,)
      ],
    );
  }
}