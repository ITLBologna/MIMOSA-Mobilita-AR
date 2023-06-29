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

abstract class ILocalStorage {
  Future<Validation<NoValue>> init({String? relativePath});
  Future<Validation<String>> getUserId();
  Future<Validation<NoValue>> storeLocationData(String key, Map<String, dynamic> data);
  Future<String?> getLastTrackingDataUploadDate();
  Future<Validation<NoValue>> storeLastTrackingDataUploadDate([String? value]);
  Future<Validation<Map>> getLocationData(String key);
  Future<Validation<Map<dynamic, Map>>> getLocationsData();
  Future<Validation<NoValue>> deleteLocationData(String key);
  Future<Validation<NoValue>> deleteLocations(Iterable keys);
  Future<Validation<NoValue>> deleteAllLocations();

  Future<Validation<NoValue>> storeGamificationData(String key, Map<String, dynamic> data);
  Future<Validation<Map>> getGamificationData(String key);
  Future<Validation<Map<dynamic, Map>>> getGamificationsData();
  Future<Validation<NoValue>> deleteGamificationData(String key);
  Future<Validation<NoValue>> deleteGamificationsData(Iterable keys);
  Future<Validation<NoValue>> deleteAllGamificationsData();
}