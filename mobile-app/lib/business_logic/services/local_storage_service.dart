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
import 'package:hive/hive.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/file_utils_and_extensions.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:uuid/uuid.dart';

const userSettingsBox = 'UserSettings';
const locationsTrackingBox = 'TrackedLocations';
const activitiesTrackingBox = 'TrackedActivities';
const lastTrackingDataUploadDateBox = 'LastTrackingDataUploadDate';
const gamificationBox = 'Gamification';

class LocalStorage implements ILocalStorage {
  @override
  Future<Validation<String>> getUserId() {
    return Hive.openBox<String>(userSettingsBox).then((box) {
      var userId = box.get('UserId');
      if (userId == null) {
        userId = const Uuid().v1();
        box.put('UserId', userId);
      }

      return userId;
    }).tryCatch();
  }

  @override
  Future<Validation<NoValue>> storeLocationData(
      String key, Map<String, dynamic> data) {
    return _store(locationsTrackingBox, key, data);
  }

  @override
  Future<Validation<Map>> getLocationData(String key) {
    return _get(locationsTrackingBox, key);
  }

  @override
  Future<Validation<Map<dynamic, Map>>> getLocationsData() {
    return _getAll(locationsTrackingBox);
  }

  @override
  Future<Validation<NoValue>> deleteLocationData(String key) {
    return _delete(locationsTrackingBox, key);
  }

  @override
  Future<Validation<NoValue>> deleteLocations(Iterable keys) {
    return _deleteAll(locationsTrackingBox, keys);
  }

  @override
  Future<Validation<NoValue>> deleteAllLocations() {
    return getLocationsData()
        .map((data) => data.keys)
        .bindFuture((keys) => deleteLocations(keys));
  }

  @override
  Future<Validation<NoValue>> storeGamificationData(
      String key, Map<String, dynamic> data) {
    return _store(gamificationBox, key, data);
  }

  @override
  Future<Validation<Map>> getGamificationData(String key) {
    return _get(gamificationBox, key);
  }

  @override
  Future<Validation<Map<dynamic, Map>>> getGamificationsData() {
    return _getAll(gamificationBox);
  }

  @override
  Future<Validation<NoValue>> deleteGamificationData(String key) {
    return _delete(gamificationBox, key);
  }

  @override
  Future<Validation<NoValue>> deleteGamificationsData(Iterable keys) {
    return _deleteAll(gamificationBox, keys);
  }

  @override
  Future<Validation<NoValue>> deleteAllGamificationsData() {
    return getGamificationsData()
        .map((data) => data.keys)
        .bindFuture((keys) => deleteGamificationsData(keys));
  }

  Future<Box<Map>> _openBox(String box) {
    return Hive.openBox<Map>(box,
        compactionStrategy: (entries, deletedEntries) => deletedEntries > 1000);
  }

  Future<Validation<NoValue>> _store(
      String box, String key, Map<String, dynamic> data) {
    return _openBox(box)
        .then((box) => box.put(key, data))
        .then((value) => const NoValue.none())
        .tryCatch();
  }

  Future<Validation<Map>> _get(String box, String key) {
    return _openBox(box)
        .then((box) => box.get(key))
        .then((value) => value ?? {})
        .tryCatch();
  }

  Future<Validation<Map<dynamic, Map>>> _getAll(String box) {
    return _openBox(box).then((box) => box.toMap()).tryCatch();
  }

  Future<Validation<NoValue>> _delete(String box, String key) {
    return _openBox(box)
        .then((box) => box.delete(key))
        .then((value) => const NoValue.none())
        .tryCatch();
  }

  Future<Validation<NoValue>> _deleteAll(String box, Iterable keys) {
    return _openBox(box)
        .then((box) => box.deleteAll(keys))
        .then((_) => const NoValue.none())
        .tryCatch();
  }

  @override
  Future<Validation<NoValue>> init({String? relativePath}) {
    return getLocalPath(innerPath: relativePath)
        .then((path) => Valid(path))
        .map((path) {
          Hive.init(path);
          return path;
        })
        .mapFuture(
          (path) => BoxCollection.open(
              'Mimosa',
              {
                userSettingsBox,
                locationsTrackingBox,
                activitiesTrackingBox,
                gamificationBox
              },
              path: path),
        )
        .map((_) => const NoValue.none())
        .tryCatch();
  }

  Future deleteStorage() {
    return Hive.deleteFromDisk();
  }

  @override
  Future<String?> getLastTrackingDataUploadDate() {
    debugPrint('READING LastTrackingDataUploadDate');
    return Hive.openBox<String?>(lastTrackingDataUploadDateBox).then((value) => value.get('lastTrackingDataUploadDate'));
  }

  @override
  Future<Validation<NoValue>> storeLastTrackingDataUploadDate([String? value]) {
    debugPrint('STORING: ${{ 'value': value ?? DateTime.now().toIso8601String() }}');
    return _store(lastTrackingDataUploadDateBox, 'lastTrackingDataUploadDate', { 'value': value ?? DateTime.now().toIso8601String() });
  }
}
