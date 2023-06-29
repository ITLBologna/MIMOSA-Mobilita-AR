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
import 'package:hive/hive.dart';
import 'package:mimosa/business_logic/extensions_and_utils/future_utils.dart';
import 'package:mimosa/business_logic/models/apis/user_access_response.dart';
import 'package:mimosa/business_logic/models/errors/errors.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class UserAccessController {
  Future<UserAccessResponse?> userAccessResponse = Future.value(null);
  Future<String?>? userId;

  StreamController<UserAccessResponse> userAccessResponseStreamController =
      StreamController<UserAccessResponse>.broadcast();

  Stream<UserAccessResponse> userAccessResponseStream() =>
      userAccessResponseStreamController.stream;

  String? sUserId;

  Future<String?> loadUserId() {
    if (userId != null) {
      return userId!;
    }

    final localStorageService = serviceLocator.get<ILocalStorage>();
    return userId =
        localStorageService.getUserId().fold((failures) => null, (val) => val);
  }

  Future<UserAccessResponse?> access() {
    final service = serviceLocator.get<IApisService>();
    final userIdAndSettings =
        waitConcurrently(loadUserId(), Hive.openBox('settings'));
    return userAccessResponse = userIdAndSettings.then((value) {
      sUserId = value.item1;
      var box = value.item2;
      bool suggestionsConsent =
          box.get('noticeSuggestionsConsentAllowed', defaultValue: false);
      bool gamificationConsent =
          box.get('noticeGamificationConsentAllowed', defaultValue: false);
      bool surveyConsent =
          box.get('noticePollsConsentAllowed', defaultValue: false);

      return sUserId == null
          ? Fail.withError(StorageError())
              .toInvalid<UserAccessResponse>()
              .toFuture()
          : service.userAccess(
              userId: sUserId!,
              suggestionsConsent: suggestionsConsent,
              gamificationConsent: gamificationConsent,
              surveyConsent: surveyConsent);
    }).fold((failures) => null, (val) {
      userAccessResponseStreamController.sink.add(val);
      return val;
    });
  }
}

class UserSurveyWrapper {
  final String? surveyId;
  final int? userId;

  UserSurveyWrapper({required this.surveyId, required this.userId});
}
