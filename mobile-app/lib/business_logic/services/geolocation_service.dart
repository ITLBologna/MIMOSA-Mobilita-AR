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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mimosa/business_logic/extensions_and_utils/future_extensions.dart';
import 'package:ar_location_view/ar_position_extensions.dart';
import 'package:mimosa/business_logic/models/errors/errors.dart';
import 'package:mimosa/business_logic/models/mimosa_location_data.dart';
import 'package:ar_location_view/ar_position.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/controllers/vibrate_controller.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler_lib;
import 'package:rxdart/rxdart.dart';

class GeoLocationService extends ILocationService {
  final _activity = FlutterActivityRecognition.instance;
  StreamSubscription? _locationAndActivitySubscription;
  Future<Position>? _firstPosition;
  StreamSubscription<Position>? _geolocatorSubscription;
  BehaviorSubject<ArPosition>? _positionsToTrackSubject;

  LocationSettings _buildSettings({
    required int notificationsIntervalInMillisec,
    required String androidNotificationTitle,
    required String androidNotificationDescription,
    required int distanceFilterInMeters,
  }) {
    LocationSettings settings;
    if (Platform.isIOS) {
      settings = AppleSettings(
          pauseLocationUpdatesAutomatically: true,
          distanceFilter: distanceFilterInMeters,
          showBackgroundLocationIndicator: false);
    } else {
      settings = AndroidSettings(
          distanceFilter: distanceFilterInMeters,
          intervalDuration:
              Duration(milliseconds: notificationsIntervalInMillisec),
          foregroundNotificationConfig: ForegroundNotificationConfig(
              notificationTitle: androidNotificationTitle,
              notificationText: androidNotificationDescription));
    }

    return settings;
  }

  Future<NoValue> _startListeningToGeolocator(LocationSettings settings) {
    _stopListeningToGeolocator();
    _positionsToTrackSubject = BehaviorSubject<ArPosition>();
    _firstPosition = Geolocator.getCurrentPosition();
    return _firstPosition!.then((value) {
      _positionsToTrackSubject?.add(value.toArPosition());
      _geolocatorSubscription =
          Geolocator.getPositionStream(locationSettings: settings)
              .listen((event) {
        _positionsToTrackSubject?.add(event.toArPosition());
      });

      return const NoValue.none();
    });
  }

  void _stopListeningToGeolocator() {
    _geolocatorSubscription?.cancel();
    _positionsToTrackSubject?.close();
    _positionsToTrackSubject = null;
  }

  @override
  StreamSubscription<ArPosition> listenToPosition(
      void Function(ArPosition) callback) {
    return _positionsToTrackSubject!.listen(callback);
  }

  @override
  Future<ArPosition> getLastPosition() {
    if (_positionsToTrackSubject?.hasValue == true) {
      return Future.value(_positionsToTrackSubject!.value);
    } else {
      return _firstPosition!.then((value) => value.toArPosition());
    }
  }

  @override
  Future<Validation<NoValue>> startTracking(
      {int notificationsIntervalInMillisec = 10000,
      required String androidNotificationTitle,
      String androidNotificationSubtitle = '',
      String androidNotificationDescription = '',
      String androidNotificationIconName = '@mipmap/ic_launcher',
      int distanceFilterInMeters = 0,
      required int minDistanceToTrackInMeters,
      void Function(MimosaLocationData locationData)? onLocationUpdate,
      void Function(Fail error)? onError}) {
    stopTracking();
    return checkLocationServiceStatus()
        .map((_) => _buildSettings(
            notificationsIntervalInMillisec: notificationsIntervalInMillisec,
            androidNotificationTitle: androidNotificationTitle,
            androidNotificationDescription: androidNotificationDescription,
            distanceFilterInMeters: distanceFilterInMeters))
        .mapFuture((settings) {
      return _startListeningToGeolocator(settings);
    }).bind((_) {
      return Try(() {
        Activity? lastEvent;
        ArPosition? lastPosition;

        _locationAndActivitySubscription = CombineLatestStream.combine2(
            _positionsToTrackSubject!.stream,
            _activity.activityStream
                .where((event) =>
                    event.confidence != ActivityConfidence.LOW &&
                    event.type != lastEvent?.type)
                .map((event) => _ActivityWithDateTime(event)),
            (l, a) => _PositionDataAndActivity(l, a)).handleError((error) {
          if (error is Error) {
            return onError?.call(Fail.withError(error));
          } else if (error is Exception) {
            return onError?.call(Fail.withException(error));
          }
        }).listen((n) {
          lastEvent = n.activity.activity;
          final data = MimosaLocationData(
              latitude: n.position.latitude,
              longitude: n.position.longitude,
              speed: n.position.speed,
              heading: n.position.heading,
              time: n.position.timestamp?.millisecondsSinceEpoch.toDouble(),
              activity: n.activity.activity.type.name);

          if (lastPosition == null) {
            onLocationUpdate?.call(data);
          } else {
            final distance = Geolocator.distanceBetween(
                n.position.latitude,
                n.position.longitude,
                lastPosition!.latitude,
                lastPosition!.longitude);

            if (distance >= minDistanceToTrackInMeters) {
              lastPosition = n.position;
              onLocationUpdate?.call(data);
            }
          }
        });
        return const NoValue.none();
      });
    }).tryCatch();
  }

  @override
  void stopTracking() {
    _locationAndActivitySubscription?.cancel();
    _stopListeningToGeolocator();
  }

  @override
  Future<bool> isLocationServiceStatusEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<Validation<NoValue>> checkLocationServiceStatus() {
    return Geolocator.isLocationServiceEnabled()
        .then((enabled) => Valid(enabled))
        .mapFuture((enabled) {
      if (enabled) {
        return toFuture(enabled);
      } else {
        return Geolocator.requestPermission();
      }
    }).bind((enabled) {
      if (enabled == true) {
        return const NoValue.none().toValid();
      } else {
        return Fail.withError(DisabledPlatformServiceError())
            .toInvalid<NoValue>();
      }
    }).tryCatch();
  }

  @override
  Future<bool> isLocationAlwaysPermissionGranted() {
    return permission_handler_lib.Permission.locationAlways.isGranted;
  }

  @override
  Future<Validation<MimosaLocationPermissionStatus>>
      checkLocationAlwaysPermissionStatus() {
    return permission_handler_lib.Permission.locationAlways
        .request()
        .tryCatch()
        .map((status) {
      if (status == permission_handler_lib.PermissionStatus.granted) {
        return MimosaLocationPermissionStatus.alwaysGranted;
      } else if (status == permission_handler_lib.PermissionStatus.denied) {
        return MimosaLocationPermissionStatus.alwaysDenied;
      } else {
        return MimosaLocationPermissionStatus.values.byName(status.name);
      }
    });
  }

  @override
  Future<Validation<MimosaLocationPermissionStatus>>
      checkLocationWhenInUsePermissionStatus() {
    return permission_handler_lib.Permission.locationWhenInUse
        .request()
        .tryCatch()
        .map((status) {
      if (status == permission_handler_lib.PermissionStatus.granted) {
        return MimosaLocationPermissionStatus.whenInUseGranted;
      } else if (status == permission_handler_lib.PermissionStatus.denied) {
        return MimosaLocationPermissionStatus.whenInUseDenied;
      } else {
        return MimosaLocationPermissionStatus.values.byName(status.name);
      }
    });
  }

  @override
  Future<MimosaLocationPermissionStatus> checkLocationPermissions() {
    return isLocationServiceStatusEnabled()
        .then((value) {
          return value
              ? Valid(MimosaLocationPermissionStatus.serviceEnabled)
              : Fail.withError(LocationPermissionError(
                      MimosaLocationPermissionStatus.serviceDisabled))
                  .toInvalid();
        })
        .bindFuture((_) => permission_handler_lib
            .Permission.locationWhenInUse.isGranted
            .then((value) => value
                ? Valid(true)
                : Fail.withError(LocationPermissionError(
                        MimosaLocationPermissionStatus.whenInUseDenied))
                    .toInvalid<bool>()))
        .bindFuture((_) => permission_handler_lib.Permission.locationAlways.isGranted
            .then((value) => value
                ? Valid(true)
                : Fail.withError(
                        LocationPermissionError(MimosaLocationPermissionStatus.alwaysDenied))
                    .toInvalid()))
        .fold((failures) {
          return failures.first.fold((err) {
            final error = err as LocationPermissionError;
            return error.mimosaLocationPermissionStatus;
          },
              (exc) => MimosaLocationPermissionStatus
                  .whenInUseDenied // Non può succedere
              );
        }, (_) => MimosaLocationPermissionStatus.alwaysGranted);
  }
}

class LocationPermissionError extends Error {
  final MimosaLocationPermissionStatus mimosaLocationPermissionStatus;

  LocationPermissionError(this.mimosaLocationPermissionStatus);
}

class _ActivityWithDateTime {
  final Activity activity;
  final DateTime dateTime;

  _ActivityWithDateTime(this.activity) : dateTime = DateTime.now();
}

class _PositionDataAndActivity {
  final ArPosition position;
  final _ActivityWithDateTime activity;

  _PositionDataAndActivity(this.position, this.activity);
}
