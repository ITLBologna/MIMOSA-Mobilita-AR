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

// import 'dart:async';
// import 'dart:io';
//
// import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
// import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
// import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
// import 'package:mimosa/business_logic/extensions_and_utils/future_extensions.dart';
// import 'package:mimosa/business_logic/models/android_notification_data_adapter.dart';
// import 'package:mimosa/business_logic/models/errors/errors.dart';
// import 'package:mimosa/business_logic/models/errors/mimosa_errors.dart';
// import 'package:mimosa/business_logic/models/mimosa_location_data.dart';
// import 'package:mimosa/business_logic/services/interfaces/i_ar_location_service.dart';
// import 'package:permission_handler/permission_handler.dart' as permission_handler_lib;
// import 'package:rxdart/rxdart.dart';
//
// class BackgroundLocationService implements IBackgroundLocationService
// {
//   final Location _location = Location();
//   final _activity = FlutterActivityRecognition.instance;
//   StreamSubscription? _locationAndActivitySubscription;
//
//   @override
//   Future<Validation<NoValue>> startTracking({
//     int notificationsIntervalInMillisec = 10000,
//     required String androidNotificationTitle,
//     String androidNotificationSubtitle = '',
//     String androidNotificationDescription = '',
//     String androidNotificationIconName = '@mipmap/ic_launcher',
//     double distanceFilterInMeters = 0.0,
//     void Function(MimosaLocationData locationData)? onLocationUpdate,
//     void Function(Fail error)? onError
//   }) {
//     return checkLocationServiceStatus()
//             .mapFuture((_) =>
//               _location.changeSettings(
//                   interval: notificationsIntervalInMillisec,
//                   distanceFilter: distanceFilterInMeters
//               )
//             )
//             .mapFuture((_) =>
//               _location.enableBackgroundMode(enable: true)
//             )
//             .bindFuture((_) {
//               if(Platform.isAndroid) {
//                 return _location.changeNotificationOptions(
//                     title: androidNotificationTitle,
//                     subtitle: androidNotificationSubtitle,
//                     description: androidNotificationDescription,
//                     iconName: androidNotificationIconName,
//                     onTapBringToFront: false
//                 ).then(
//                   (value) => value == null
//                               ? Fail.withError(MimosaAndroidLocationError()).toInvalid<AndroidNotificationDataAdapter>()
//                               : Valid(AndroidNotificationDataAdapter(channelId: value.channelId, notificationId: value.notificationId))
//                 );
//               }
//               else {
//                 return Valid(const AndroidNotificationDataAdapter(channelId: '', notificationId: -1)).toFuture();
//               }
//             })
//             .bind(
//               (_) {
//                   return Try(() {
//                     _locationAndActivitySubscription = CombineLatestStream
//                       .combine2(
//                         _location.onLocationChanged,
//                         _activity
//                             .activityStream
//                             .where((event) => event.confidence != ActivityConfidence.LOW)
//                             .map((event)
//                               => _ActivityWithDateTime(event)),
//                         (l, a) => _LocationDataAndActivity(l, a)
//                     ).handleError((error) {
//                         if(error is Error) {
//                           return onError?.call(Fail.withError(error));
//                         }
//                         else if(error is Exception) {
//                           return onError?.call(Fail.withException(error));
//                         }
//                       }).listen((n) {
//                         final data = MimosaLocationData(
//                           latitude: n.locationData.latitude,
//                           longitude: n.locationData.longitude,
//                           speed: n.locationData.speed,
//                           heading: n.locationData.heading,
//                           time: n.locationData.time,
//                           activity: n.activity.activity.type.name
//                         );
//
//                         onLocationUpdate?.call(data);
//                       });
//                       return const NoValue.none();
//                     });
//               })
//             .tryCatch();
//   }
//
//   @override
//   void stopTracking() {
//     _locationAndActivitySubscription?.cancel();
//   }
//
//   @override
//   Future<bool> isLocationServiceStatusEnabled() {
//     return _location.serviceEnabled();
//   }
//
//   @override
//   Future<Validation<NoValue>> checkLocationServiceStatus() {
//     return _location
//       .serviceEnabled()
//       .then((enabled) => Valid(enabled))
//       .mapFuture((enabled) {
//         if(enabled) {
//           return toFuture(enabled);
//         }
//         else {
//           return _location.requestService();
//         }
//       })
//       .bind((enabled) {
//         if (enabled == true) {
//           return const NoValue.none().toValid();
//         }
//         else {
//           return Fail.withError(DisabledPlatformServiceError()).toInvalid<NoValue>();
//         }
//       })
//       .tryCatch();
//   }
//
//   @override
//   Future<bool> isLocationAlwaysPermissionGranted() {
//     return permission_handler_lib.Permission
//         .locationAlways
//         .isGranted;
//   }
//
//   @override
//   Future<Validation<MimosaLocationPermissionStatus>> checkLocationAlwaysPermissionStatus() {
//     return permission_handler_lib.Permission
//         .locationAlways
//         .request()
//         .tryCatch()
//         .map(
//             (status) {
//           if(status == permission_handler_lib.PermissionStatus.granted) {
//             return MimosaLocationPermissionStatus.alwaysGranted;
//           }
//           else if(status == permission_handler_lib.PermissionStatus.denied) {
//             return MimosaLocationPermissionStatus.alwaysDenied;
//           }
//           else {
//             return MimosaLocationPermissionStatus.values.byName(status.name);
//           }
//         });
//   }
//
//   @override
//   Future<Validation<MimosaLocationPermissionStatus>> checkLocationWhenInUsePermissionStatus() {
//     return permission_handler_lib.Permission
//         .locationWhenInUse
//         .request()
//         .tryCatch()
//         .map(
//             (status) {
//               if(status == permission_handler_lib.PermissionStatus.granted) {
//                 return MimosaLocationPermissionStatus.whenInUseGranted;
//               }
//               else if(status == permission_handler_lib.PermissionStatus.denied) {
//                 return MimosaLocationPermissionStatus.whenInUseDenied;
//               }
//               else {
//                 return MimosaLocationPermissionStatus.values.byName(status.name);
//               }
//             });
//   }
//
//   @override
//   Future<MimosaLocationPermissionStatus> checkLocationPermissions() {
//     return isLocationServiceStatusEnabled()
//         .then((value) {
//           return value
//               ? Valid(MimosaLocationPermissionStatus.serviceEnabled)
//               : Fail.withError(LocationPermissionError(MimosaLocationPermissionStatus.serviceDisabled)).toInvalid();
//         })
//         .bindFuture((_)
//           => permission_handler_lib
//               .Permission
//               .locationWhenInUse
//               .isGranted
//               .then((value)
//                 => value
//                     ? Valid(true)
//                     : Fail.withError(LocationPermissionError(MimosaLocationPermissionStatus.whenInUseDenied)).toInvalid<bool>())
//               )
//         .bindFuture((_)
//           => permission_handler_lib
//               .Permission
//               .locationAlways
//               .isGranted
//               .then((value)
//                 => value
//                     ? Valid(true)
//                     : Fail.withError(LocationPermissionError(MimosaLocationPermissionStatus.alwaysDenied)).toInvalid()
//               )
//         )
//         .fold(
//             (failures) {
//               return failures.first.fold(
//                       (err) {
//                         final error = err as LocationPermissionError;
//                         return error.mimosaLocationPermissionStatus;
//                       },
//                       (exc) => MimosaLocationPermissionStatus.whenInUseDenied // Non può succedere
//                     );
//             },
//             (_) => MimosaLocationPermissionStatus.alwaysGranted
//     );
//   }
//
// }
//
// class LocationPermissionError extends Error {
//   final MimosaLocationPermissionStatus mimosaLocationPermissionStatus;
//   LocationPermissionError(this.mimosaLocationPermissionStatus);
// }
//
// class _ActivityWithDateTime {
//   final Activity activity;
//   final DateTime dateTime;
//
//   _ActivityWithDateTime(this.activity) : dateTime = DateTime.now();
// }
//
// class _LocationDataAndActivity {
//   final LocationData locationData;
//   final _ActivityWithDateTime activity;
//
//   _LocationDataAndActivity(this.locationData, this.activity);
// }