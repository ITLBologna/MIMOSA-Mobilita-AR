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
import 'package:geolocator/geolocator.dart';
import 'package:mimosa/business_logic/extensions_and_utils/future_extensions.dart';
import 'package:mimosa/business_logic/models/errors/errors.dart';
import 'package:mimosa/business_logic/models/errors/geolocations_errors.dart';

class LocationPermissionsService {
  static Future<Validation<NoValue>> requestPermissions() {
    return Geolocator
        .isLocationServiceEnabled()
        .then((serviceEnabled) => Valid(serviceEnabled)) // Wrap the value to a Validation one to enable chain subsequent ops
        .bind((serviceEnabled) {
          if(!serviceEnabled) {
            return Fail.withError(DisabledPlatformServiceError()).toInvalid<bool>();
          }

          return Valid(true);
        })
        .mapFuture((_) => Geolocator.checkPermission())
        .bind((permission) {
          if(permission == LocationPermission.deniedForever) {
            return Fail.withError(LocationPermissionsDeniedForeverError())
                .toInvalid<LocationPermission>();
          }
          return Valid(permission);
        })
        .mapFuture((permission) {
          if(permission == LocationPermission.denied) {
            return Geolocator.requestPermission();
          }

          return toFuture(permission);
        })
        .bind((permission) {
          if(permission == LocationPermission.denied) {
            return Fail.withError(LocationPermissionsDeniedError()).toInvalid<NoValue>();
          }
          else if(permission == LocationPermission.deniedForever) {
            return Fail.withError(LocationPermissionsDeniedForeverError()).toInvalid<NoValue>();
          }
          else {
            return const NoValue.none().toValid();
          }
        })
        .tryCatch();
  }
}