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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:mimosa/controllers/ar_radar_satellites_widgets_controller.dart';
import 'package:mimosa/ui/contants/colors_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DirectionsRadarSatelliteIconButton extends StatefulWidget {
  final Size size;
  final VoidCallback onPressed;
  final double radarWidth;
  final RadarPosition radarPosition;
  final double offsetFromRadar;
  final double orbitalDegrees;
  final Size? radarSize;
  final Offset? radarOffset;
  final double radarOffsetCompensation;

  const DirectionsRadarSatelliteIconButton(
      {required this.size,
      required this.onPressed,
      required this.radarWidth,
      this.radarSize,
      this.radarOffset,
      this.radarOffsetCompensation = 0.0,
      this.radarPosition = RadarPosition.bottomCenter,
      this.offsetFromRadar = 0.0,
      this.orbitalDegrees = 0.0,
      super.key});

  @override
  State<DirectionsRadarSatelliteIconButton> createState() =>
      _DirectionsRadarSatelliteIconButtonState();
}

class _DirectionsRadarSatelliteIconButtonState
    extends State<DirectionsRadarSatelliteIconButton> {
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
    Color foregroundColor =
        _visibleAnnotationsController.directionsAnnotationsAreVisible()
            ? Colors.white
            : Colors.grey[400] ?? Colors.grey;
    return Obx(() {
      final loc = AppLocalizations.of(context)!;
      return ArRadarSatelliteWidget(
          radarPosition: widget.radarPosition,
          radarSize: widget.radarWidth,
          orbitalDegrees: widget.orbitalDegrees,
          offsetFromRadar: widget.offsetFromRadar,
          radarComputedOffset: widget.radarOffset,
          radarComputedSize: widget.radarSize,
          radarOffsetCompensation: widget.radarOffsetCompensation,
          //widget.size.width,
          ringWidth: 2,
          color: _visibleAnnotationsController.directionsAnnotationsAreVisible()
              ? directionsColor
              : Colors.black.withOpacity(0.4),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _checked = !_checked;
              _visibleAnnotationsController
                  .setDirectionsAnnotationsVisibility(_checked);
              widget.onPressed();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.assistant_navigation,
                    color: _visibleAnnotationsController
                            .directionsAnnotationsAreVisible()
                        ? Colors.white
                        : Colors.grey[400],
                    size: widget.size.width - 32,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(loc.radar_satellite_button_directions,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0,
                          color: _visibleAnnotationsController
                                  .directionsAnnotationsAreVisible()
                              ? Colors.white
                              : Colors.grey[400])),
                ),
              ],
            ),
          ));
    });
  }
}

/*
backgroundColor: _visibleAnnotationsController.directionsAnnotationsAreVisible()
                ? directionsColor
                : Colors.transparent,
            elevation: 0.2,
            onPressed: () {
              _checked = !_checked;
              _visibleAnnotationsController.setDirectionsAnnotationsVisibility(_checked);
              widget.onPressed();
            },
            extendedIconLabelSpacing: 4.0,
            extendedPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            label: Text("Indicazioni", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0, color: _visibleAnnotationsController.stopsAnnotationsAreVisible()
                ? Colors.white
                : Colors.grey[400])),
            icon: Icon(
              Icons.assistant_navigation,
              size: widget.size.width - 32,
              color: _visibleAnnotationsController.directionsAnnotationsAreVisible()
                        ? Colors.white
                        : Colors.grey[400]
              ),
 */
