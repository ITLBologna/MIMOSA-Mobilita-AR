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
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/models/apis/api_tracking_data.dart';
import 'package:mimosa/business_logic/models/mimosa_location_data.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class LocationUploaderService {
  Timer? _timer;
  bool get isInitialized => _timer != null;
  bool _uploading = false;

  void init({
    required ILocalStorage localStorageService,
    required IApisService apiService,
    required int maxEntriesToUpload,
    int uploadCheckIntervalInSeconds = 30}
  ) {
    _uploading = false;

    DateTime lastUpload = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: uploadCheckIntervalInSeconds), (timer) {
      List<MimosaLocationData> storedTrackedLocations = [];

      if(!_uploading) {
        _uploading = true;
        final config = serviceLocator.get<IConfigurationService>();
        Iterable keysToDelete = [];
        localStorageService
          .getLocationsData()
          .map((data) {
            final lastUpdateInterval = DateTime.now().difference(lastUpload).inHours;
            if(data.keys.length >= config.settings.trackingSettings.minNumberOfTarckingDataToUpload ||
                 lastUpdateInterval >= config.settings.trackingSettings.maxTimeBetweenUploadsInHours) {
              keysToDelete = data.keys;
              storedTrackedLocations = data.fromMapWithKeys().getLastEntries(maxEntriesToUpload).toList();
              return data.keys;
            }
            else {
              return keysToDelete;
            }
          }
        )
        .bindFuture(
            (_) => localStorageService.getUserId()
        )
        .map((userId) => TrackingDataToUpload(userId: userId, data: storedTrackedLocations))
        .bindFuture((dataToUpload) {
          if(dataToUpload.data.isNotEmpty) {
            return apiService
                    .uploadTrackedLocations(trackedLocations: dataToUpload.toMap())
                    .fold(
                      (failures) => failures.toInvalid(),
                      (val) {
                        lastUpload = DateTime.now();
                        return Valid(val);
                      });
          }
          else {
            return <String, dynamic>{}.toValidFuture();
          }
        })
        .fold(
          (failures) {
            _uploading = false;
          },
          (val) {
            localStorageService.deleteLocations(keysToDelete);
            _uploading = false;
          }
        )
        .tryCatch();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
