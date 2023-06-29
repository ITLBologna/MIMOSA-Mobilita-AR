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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mimosa/controllers/ar_mode_switch_controller.dart';
import 'package:mimosa/controllers/map_rotation_controller.dart';
import 'package:mimosa/controllers/map_ui_controller.dart';
import 'package:mimosa/controllers/track_user_icon_controller.dart';

class MapRotationIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final MapController mapController;

  const MapRotationIconButton({
    required this.mapController,
    this.onPressed,
    super.key
  });


  Icon _getIcon() {
    final c = Get.find<MapRotationController>();
    if(c.mapRotationEnabled.value) {
      return const Icon(Icons.rotate_left, color: Colors.black, size: 28);
    }
    else {
      return Icon(Icons.rotate_left, color: Colors.grey[600]!, size: 28);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arModeSwitchController = Get.find<ArModeSwitchController>();

    return Obx(() {
      if(!arModeSwitchController.isInARMode.value) {
        return const SizedBox();
      }

      return IconButton(
          visualDensity: VisualDensity.compact,
          icon: _getIcon(),
          onPressed: () {
            onPressed?.call();
            final c = Get.find<MapRotationController>();
            c.mapRotationEnabled.value = !c.mapRotationEnabled.value;
            if(!c.mapRotationEnabled.value) {
              mapController.rotate(0);
            }
          });
    });
  }
}