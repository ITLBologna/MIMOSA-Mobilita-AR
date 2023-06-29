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

import 'package:ar_location_view/ar_location_view.dart';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:mimosa/business_logic/models/mimosa_location_data.dart';

import 'package:ar_location_view/ar_position.dart';

enum MimosaLocationPermissionStatus {
  whenInUseDenied,
  whenInUseGranted,
  alwaysDenied,
  alwaysGranted,
  serviceDisabled,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  serviceEnabled
}


abstract class ILocationService extends IArLocationService
{
  Future<bool> isLocationServiceStatusEnabled();
  Future<Validation<NoValue>> checkLocationServiceStatus();
  Future<MimosaLocationPermissionStatus> checkLocationPermissions();

  Future<Validation<NoValue>> startTracking({
    int notificationsIntervalInMillisec = 10000,
    required String androidNotificationTitle,
    String androidNotificationSubtitle = '',
    String androidNotificationDescription = '',
    String androidNotificationIconName = '@mipmap/ic_launcher',
    int distanceFilterInMeters = 0,
    required int minDistanceToTrackInMeters,
    void Function(MimosaLocationData locationData)? onLocationUpdate,
    void Function(Fail error)? onError
  });

  void stopTracking();

  Future<bool> isLocationAlwaysPermissionGranted();
  Future<Validation<MimosaLocationPermissionStatus>> checkLocationAlwaysPermissionStatus();
  Future<Validation<MimosaLocationPermissionStatus>> checkLocationWhenInUsePermissionStatus();
}

