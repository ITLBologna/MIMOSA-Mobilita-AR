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

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mimosa/controllers/view_models/plan_trip_data.dart';
import 'package:mimosa/ui/widgets/destination_type_ahead_widget.dart';

@immutable
class TripCardWidget extends StatelessWidget {
  final Function(PlanTripData) onPressed;

  const TripCardWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    PlanTripData? planTripData;
    return Card(
      elevation: 5,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Stack(
        children: [
          Image.asset('assets/images/mappa_bo.jpg'),
          Container(
            width: double.infinity,
            color: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10),
              child: Text(
                AppLocalizations.of(context)!.where_are_you_going,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DestinationTypeAheadWidget(
                        onPlaceSelected: (autocompletePlace, userPosition) {
                      planTripData = PlanTripData(
                          place: autocompletePlace, userPosition: userPosition);
                    })),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: ElevatedButton(
                      onPressed: () {
                        if (planTripData != null) {
                          onPressed(planTripData!);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.go)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
