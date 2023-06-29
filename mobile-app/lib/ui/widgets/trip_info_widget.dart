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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/ui/widgets/trip_widget.dart';

class TripInfoWidget extends StatelessWidget {
  final MimosaRoute route;
  final Trip trip;
  final DateTime? scheduledDepartureTime;
  final DateTime? liveDepartureTime;
  final double? userSpeedInMetersPerSecond;
  final double? distanceFromUser;
  final bool isExpanded;

  const TripInfoWidget(
      {super.key,
      required this.route,
      required this.trip,
      required this.scheduledDepartureTime,
      required this.liveDepartureTime,
      this.userSpeedInMetersPerSecond,
      this.distanceFromUser,
      this.isExpanded = false});

  Duration? _getDepartureTimeLeft() {
    final now = DateTime.now();
    final duration =
        (liveDepartureTime ?? scheduledDepartureTime)?.difference(now);
    if (duration?.isNegative != false) {
      return null;
    }

    return duration;
  }

  String _getDurationInMinutesAndSecond(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds - (duration.inMinutes * 60);

    return '${minutes.toString()}m ${seconds.toString()}s';
  }

  String _getDepartureTimeString(BuildContext context, Duration? duration) {
    if (duration != null) {
      return _getDurationInMinutesAndSecond(duration);
    }

    return AppLocalizations.of(context)!.unavailable_departure_time;
  }

  @override
  Widget build(BuildContext context) {
    final duration = _getDepartureTimeLeft();
    final onFootDuration = (userSpeedInMetersPerSecond != null &&
            distanceFromUser != null)
        ? Duration(seconds: distanceFromUser! ~/ userSpeedInMetersPerSecond!)
        : const Duration(seconds: 0);

    final departureStr = _getDepartureTimeString(context, duration);
    bool isRealtime = liveDepartureTime != null;

    Color walkIconColor = Colors.black54;
    if (duration != null) {
      switch (duration.compareTo(onFootDuration)) {
        case -1:
          walkIconColor = Colors.red;
          break;
        case 1:
          walkIconColor = Colors.green;
          break;
        default:
          walkIconColor = Colors.orange;
          break;
      }
    }

    int? minutesDelayed = liveDepartureTime != null &&
            scheduledDepartureTime != null
        ? (liveDepartureTime!.difference(scheduledDepartureTime!).inSeconds /
                60)
            .round()
        : null;

    Color delayBackgroundColor = Colors.grey.shade200;
    Color delayForegroundColor = Colors.grey.shade900;
    if (minutesDelayed != null && minutesDelayed > 0) {
      delayBackgroundColor = Colors.red.shade100;
      delayForegroundColor = Colors.red.shade900;
    }
    if (minutesDelayed != null && minutesDelayed > 0) {
      delayBackgroundColor = Colors.orange.shade100;
      delayForegroundColor = Colors.orange.shade900;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TripWidget(
          route: route,
          trip: trip,
          isExpanded: isExpanded,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Transform.translate(
                offset: isRealtime ? const Offset(10, -2) : const Offset(0, 0),
                child: Transform(
                  transform:
                      Matrix4.rotationZ(isRealtime ? degToRadian(50) : 0),
                  child: Icon(
                      isRealtime
                          ? Icons.wifi_rounded
                          : Icons.access_time_rounded,
                      size: 15,
                      color: Colors.black54),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: 60,
                  child: AutoSizeText(departureStr),
                ),
              ),
              minutesDelayed != null && minutesDelayed != 0
                  ? Opacity(
                      opacity: 0.4,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          color: delayBackgroundColor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2.0),
                          child: Text(
                            ' ${minutesDelayed > 0 ? AppLocalizations.of(context)!.trip_stop_bus_late : AppLocalizations.of(context)!.trip_stop_bus_early} ${minutesDelayed.abs()} min',
                            style: TextStyle(
                                fontSize: 14,
                                color: delayForegroundColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        ),
        userSpeedInMetersPerSecond != null && distanceFromUser != null
            ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.walking,
                      size: 15,
                      color: walkIconColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: duration?.compareTo(onFootDuration) == 1
                          ? Text(AppLocalizations.of(context)!
                              .trip_stop_annotation_will_arrive_on_time)
                          : Text(AppLocalizations.of(context)!
                              .trip_stop_annotation_will_arrive_late),
                    )
                  ],
                ),
              )
            : Container()
      ],
    );
  }
}
