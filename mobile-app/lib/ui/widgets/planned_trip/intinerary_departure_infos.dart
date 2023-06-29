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

import 'package:flutter/material.dart';
import 'package:mimosa/controllers/view_models/itinerary_vm.dart';

class ItineraryDepartureInfosWidget extends StatefulWidget  {
  final ItineraryVM itinerary;
  const ItineraryDepartureInfosWidget({super.key, required this.itinerary});

  @override
  State<ItineraryDepartureInfosWidget> createState() => _ItineraryDepartureInfosWidgetState();
}

class _ItineraryDepartureInfosWidgetState extends State<ItineraryDepartureInfosWidget> {
  Timer? updateInfosTimer;
  String? departureInfos;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  void dispose() {
    updateInfosTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(departureInfos == null) {
      departureInfos = widget.itinerary.getBusDepartureInfos(context: context);
      if(departureInfos != null) {
        updateInfosTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
          setState(() {
            departureInfos = widget.itinerary.getBusDepartureInfos(context: context);
          });
        });
      }
    }

    if(departureInfos != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Icon(Icons.timer, size: 15, color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            Text(departureInfos!, style: Theme
                .of(context)
                .textTheme
                .bodySmall,),
          ],
        ),
      );
    }
    else {
      return const SizedBox.shrink();
    }
  }
}