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

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/models/apis/claim_prize_response.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/models/errors/errors.dart';
import 'package:mimosa/business_logic/models/gamification/gamification_data.dart';
import 'package:mimosa/business_logic/models/gamification/gamification_stod_data.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_notification_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class GamificationController extends GetxController {
  static const _remindPlayNotificationId = 10;
  final userIsPlaying = false.obs;
  final userCheckedOut = false.obs;
  final storage = serviceLocator.get<ILocalStorage>();
  final apiService = serviceLocator.get<IApisService>();
  final notificationService = serviceLocator.get<ILocalNotificationService>();

  GamificationStopData? checkedInStop;
  List<String> plannedCheckInStopsIds = [];
  List<String> plannedCheckOutStopsIds = [];
  List<MimosaRoute> routes = [];
  TripStop? otpFirstStop;
  TripStop? otpLastStop;

  @override
  void onInit() {
    getCheckedInStop()
        .then((value) {
          checkedInStop = value;
          userIsPlaying.value = value != null;
        });

    super.onInit();
  }

  Future<GamificationStopData?> getCheckedInStop() {
    return storage
        .getGamificationsData()
        .fold(
          (failures) {
            debugPrint('getCheckedInStopId Error');
            return null;
          },
          (val) {
            return val
                .keys
                .map((key) => GamificationData.fromMap(val[key]!))
                .getFirstWhere((gd) => gd.checkOutStop == null)
                ?.checkInStop;
        }
    );
  }

  Future<Validation> deleteAllData() {
    return storage
      .getGamificationsData()
      .map((val) => storage.deleteGamificationsData(val.keys));
  }

  GamificationStopData? getGSData(TripStop? stop) {
    return stop == null
            ? null
            : GamificationStopData(
                id: stop.stopId,
                name: stop.stopName,
                code: stop.stopCode,
                lat: stop.stopLat,
                lon: stop.stopLon
              );
  }

  Future<Validation<NoValue>> checkIn(
      TripStop stop,
      {
        TripStop? tripPlannerInitialStop,
        TripStop? tripPlannerLastStop,
        String? notificationTitle,
        String? notificationBody,
        Duration? notifyAfter
      }) {
    final gd = GamificationData(
      checkInTime: DateTime.now().millisecondsSinceEpoch,
      checkInStop: getGSData(stop)!,
      tripPlannerInitialStop: getGSData(tripPlannerInitialStop),
      tripPlannerLastStop: getGSData(tripPlannerLastStop)
    );

    return storage
      .deleteAllGamificationsData()
      .bindFuture((_) => storage.storeGamificationData(stop.stopId, gd.toMap()))
      .map((_) {
        checkedInStop = getGSData(stop);
        userIsPlaying.value = true;
        if(notificationTitle != null && notifyAfter != null) {
          notificationService.scheduleNotification(
              id: _remindPlayNotificationId,
              title: notificationTitle,
              body: notificationBody ?? '',
              duration: notifyAfter
          );
        }
        return const NoValue.none();
      })
      .tryCatch();
  }

  Future<Validation<NoValue>> cancelCheckIn() {
    return storage
        .deleteAllGamificationsData()
        .map((v) {
          notificationService.cancelNotification(_remindPlayNotificationId);
          userIsPlaying.value = false;
          checkedInStop = null;
          return v;
        })
        .tryCatch();
  }

  Future<Validation> deleteGamificationData() {
    return storage.deleteAllGamificationsData();
  }

  Future<Validation<ClaimPrizeResponse>> checkOut(TripStop stop, String userId) {
    if(checkedInStop == null) {
      return Fail.withError(StorageError(), message: GamificationErrorCodes.notCheckedIn.name).toInvalid<ClaimPrizeResponse>().toFuture();
    }

    return storage
      .getGamificationData(checkedInStop!.id)
      .map((val) {
        final gd = GamificationData.fromMap(val);
        return gd.copyWith(
          checkOutStop: getGSData(stop),
          checkOutTime: DateTime.now().millisecondsSinceEpoch
        );
      })
      .bindFuture((gd) {
        return apiService.claimGamificationPrize(
          userId: userId,
          inStopId: gd.checkInStop.id,
          outStopId: stop.stopId,
          otpFirstStopId: gd.tripPlannerInitialStop?.id,
          otpLastStopId: gd.tripPlannerLastStop?.id
        );
      })
      .fold(
        (failures) => Fail.withError(Error()).toInvalid<ClaimPrizeResponse>(),
        (response) {
          notificationService.cancelNotification(_remindPlayNotificationId);
          userCheckedOut.value = true;
          userIsPlaying.value = false;
          checkedInStop = null;
          // Ignore the deletion result
          storage.deleteAllGamificationsData();

          return Valid(response);
        }
      )
      .tryCatch();
  }
}