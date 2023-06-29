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

import 'package:mimosa/controllers/view_models/itinerary_preview_step.dart';

class ItineraryPreview {
  final String duration;
  final String startTime;
  final String endTime;
  final String? firstBusStopName;
  final List<ItineraryPreviewStep> steps;

  ItineraryPreview({
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.firstBusStopName,
    this.steps = const []
  });
}