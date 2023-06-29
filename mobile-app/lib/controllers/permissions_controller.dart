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
import 'dart:io';

import 'package:get/get.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class MimosaPermissionStatus {
  final PermissionStatus locationPermissionStatus;
  final PermissionStatus cameraPermissionStatus;
  final PermissionStatus activityRecognitionPermissionStatus;
  final PermissionStatus notificationPermissionStatus;

  MimosaPermissionStatus({required this.locationPermissionStatus,
    required this.activityRecognitionPermissionStatus,
    required this.cameraPermissionStatus,
    required this.notificationPermissionStatus});
}

enum MimosaPermission {
  location,
  camera,
  activityRecognition,
  notification,
}

class PermissionsController extends GetxController {

  int locationPermanentlyDeniedCounter = 0;

  StreamController<
      PermissionStatus> locationPermissionStatusStreamController = StreamController<
      PermissionStatus>.broadcast();
  StreamController<
      PermissionStatus> cameraPermissionStatusStreamController = StreamController<
      PermissionStatus>.broadcast();
  StreamController<
      PermissionStatus> activityRecognitionPermissionStatusStreamController = StreamController<
      PermissionStatus>.broadcast();
  StreamController<
      PermissionStatus> notificationsPermissionStatusStreamController = StreamController<
      PermissionStatus>.broadcast();

  BehaviorSubject<MimosaPermissionStatus> mimosaPermissionStatus =
  BehaviorSubject<MimosaPermissionStatus>();

  Stream<MimosaPermissionStatus> mps() =>
      CombineLatestStream.combine4(
          locationPermissionStatusStreamController.stream,
          cameraPermissionStatusStreamController.stream,
          activityRecognitionPermissionStatusStreamController.stream,
          notificationsPermissionStatusStreamController.stream,
              (PermissionStatus locationPermissionStatus,
              PermissionStatus cameraPermissionStatus,
              PermissionStatus activityRecognitionPermissionStatus,
              PermissionStatus notificationsPermissionStatus) {
            MimosaPermissionStatus status = MimosaPermissionStatus(
                locationPermissionStatus: locationPermissionStatus == PermissionStatus.denied && locationPermanentlyDeniedCounter > 1 ? PermissionStatus.permanentlyDenied : locationPermissionStatus,
                activityRecognitionPermissionStatus:
                activityRecognitionPermissionStatus,
                cameraPermissionStatus: cameraPermissionStatus,
                notificationPermissionStatus: notificationsPermissionStatus);

            return status;
          }
      );

  updateMimosaPermissionStatus() async {
    PermissionStatus locationPermissionStatus = await Permission.location
        .status;
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    PermissionStatus activityRecognitionPermissionStatus = await (Platform.isAndroid ? Permission
        .activityRecognition.status : Permission.sensors.status);
    PermissionStatus notificationsPermissionStatus = await Permission
        .notification.status;

    locationPermissionStatusStreamController.sink.add(
        locationPermissionStatus);
    cameraPermissionStatusStreamController.sink.add(
        cameraPermissionStatus);
    activityRecognitionPermissionStatusStreamController.sink.add(
        activityRecognitionPermissionStatus);
    notificationsPermissionStatusStreamController.sink.add(
        notificationsPermissionStatus);

    MimosaPermissionStatus status = MimosaPermissionStatus(
        locationPermissionStatus: locationPermissionStatus == PermissionStatus.denied && locationPermanentlyDeniedCounter > 1 ? PermissionStatus.permanentlyDenied : locationPermissionStatus,
        activityRecognitionPermissionStatus:
        activityRecognitionPermissionStatus,
        cameraPermissionStatus: cameraPermissionStatus,
        notificationPermissionStatus: notificationsPermissionStatus);

    mimosaPermissionStatus.value = status;

    return status;
  }
}
