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
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/controllers/ar_mode_switch_controller.dart';
import 'package:mimosa/controllers/map_ui_controller.dart';
import 'package:mimosa/controllers/track_user_icon_controller.dart';

class TrackUserPositionIconButton extends StatelessWidget {
  final MapUIController _mapUIController = Get.find<MapUIController>();
  final TrackUserIconController _trackController =
      Get.find<TrackUserIconController>();
  final ArModeSwitchController _arModeSwitchController =
      Get.find<ArModeSwitchController>();

  final MapController mapController;
  final VoidCallback? onPressed;

  TrackUserPositionIconButton(
      {required this.mapController, this.onPressed, super.key});

  Icon _getIcon() {
    if (_arModeSwitchController.isInARMode.value) {
      if (_trackController.tracking.value) {
        return const Icon(
          Icons.assistant_navigation,
          color: Colors.black,
        );
      } else {
        return const Icon(
          Icons.assistant_navigation,
          color: Colors.grey,
        );
      }
    } else {
      return const Icon(
        Icons.gps_fixed,
        color: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return IconButton(
          visualDensity: VisualDensity.compact,
          icon: _getIcon(),
          onPressed: () {
            onPressed?.call();

            _trackController.tracking.value =
                _arModeSwitchController.isInARMode.value;
            Geolocator.getCurrentPosition().then((position) {
              _mapUIController.centerZoom.value = CenterZoom(
                  center: LatLng(position.latitude, position.longitude),
                  zoom: _mapUIController.centerZoom.value.zoom);

              mapController.move(
                  _mapUIController.centerZoom.value.center, mapController.zoom);
            });
          });
    });
  }
}
