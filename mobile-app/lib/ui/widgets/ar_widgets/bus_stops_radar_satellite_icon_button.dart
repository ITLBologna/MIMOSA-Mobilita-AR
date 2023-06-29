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

import 'package:ar_location_view/ar_radar.dart';
import 'package:ar_location_view/ar_radar_satellite_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/ar_radar_satellites_widgets_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BusStopsRadarSatelliteIconButton extends StatefulWidget {
  final Size size;
  final VoidCallback onPressed;
  final double radarWidth;
  final RadarPosition radarPosition;
  final double offsetFromRadar;
  final double orbitalDegrees;
  final Size? radarSize;
  final Offset? radarOffset;
  final double radarOffsetCompensation;

  const BusStopsRadarSatelliteIconButton({required this.size,
    required this.onPressed,
    required this.radarWidth,
    this.radarSize,
    this.radarOffset,
    this.radarPosition = RadarPosition.bottomCenter,
    this.radarOffsetCompensation = 0.0,
    this.offsetFromRadar = 0.0,
    this.orbitalDegrees = 0.0,
    super.key});

  @override
  State<BusStopsRadarSatelliteIconButton> createState() =>
      _BusStopsRadarSatelliteIconButtonState();
}

class _BusStopsRadarSatelliteIconButtonState
    extends State<BusStopsRadarSatelliteIconButton> {
  late bool _checked;
  final _visibleAnnotationsController =
  Get.put(VisibleAnnotationsTypesController());

  @override
  void initState() {
    _checked = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Obx(() {
      return ArRadarSatelliteWidget(
          radarSize: widget.radarWidth,
          radarPosition: widget.radarPosition,
          orbitalDegrees: widget.orbitalDegrees,
          offsetFromRadar: widget.offsetFromRadar,
          radarComputedOffset: widget.radarOffset,
          radarComputedSize: widget.radarSize,
          radarOffsetCompensation: widget.radarOffsetCompensation,
          //widget.size.width,
          ringWidth: 2,
          color: _visibleAnnotationsController.stopsAnnotationsAreVisible()
              ? Colors.red
              : Colors.black.withOpacity(0.4),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _checked = !_checked;
              _visibleAnnotationsController
                  .setStopsAnnotationsVisibility(_checked);
              widget.onPressed();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.bus_alert,
                    color: _visibleAnnotationsController
                        .stopsAnnotationsAreVisible()
                        ? Colors.white
                        : Colors.grey[400],
                    size: widget.size.width - 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(loc.radar_satellite_button_bus,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                          color: _visibleAnnotationsController
                              .stopsAnnotationsAreVisible()
                              ? Colors.white
                              : Colors.grey[400])),
                ),
              ],
            ),
          ));
    });
  }
}
