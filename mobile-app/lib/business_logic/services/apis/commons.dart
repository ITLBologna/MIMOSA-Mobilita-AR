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

import 'dart:io';
import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:bitapp_http_x/bitapp_http_x.dart';
import 'package:flutter/foundation.dart';
import 'package:mimosa/business_logic/models/otp_request.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

RequestX getBaseRequestXFromBasePath(String basePath, {String? token, bool? useCache, Duration? cacheDuration}) {
  return _getRequestXWithBearerAndCache(
            RequestX(basePath),
            token ?? '',
            useCache: useCache,
            cacheDuration: cacheDuration
        ).trustBadCertificatesInDebug(true);
}

RequestX getBaseRequestX() {
  var iconfigService = serviceLocator.get<IConfigurationService>();

  return RequestX(iconfigService.settings.apiSettings.basePath).trustBadCertificatesInDebug(true);
}

RequestX getOtpBaseRequestX() {
  var iconfigService = serviceLocator.get<IConfigurationService>();

  return OtpRequest(iconfigService.settings.apiSettings.basePath).trustBadCertificatesInDebug(true);
}

RequestX getBaseRequestXWithBearer(String token) {
  return getBaseRequestX().headers({HttpHeaders.authorizationHeader: 'Bearer $token'});
}
RequestX getOtpBaseRequestXWithBearer(String token) {
  return getBaseRequestX().headers({HttpHeaders.authorizationHeader: 'Bearer $token'});
}

RequestX getBaseRequestXWithBearerAndCache(String token, {bool? useCache, Duration? cacheDuration}) {
  return _getRequestXWithBearerAndCache(getBaseRequestX(), token, useCache: useCache, cacheDuration: cacheDuration);
}

RequestX getOtpBaseRequestXWithBearerAndCache(String token, {bool? useCache, Duration? cacheDuration}) {
  return _getRequestXWithBearerAndCache(getOtpBaseRequestX(), token, useCache: useCache, cacheDuration: cacheDuration);
}

RequestX _getRequestXWithBearerAndCache(RequestX requestX, String token, {bool? useCache, Duration? cacheDuration}) {
  useCache = useCache ?? true;
  var iconfigService = serviceLocator.get<IConfigurationService>();
  var request = requestX
      .headers({HttpHeaders.authorizationHeader: 'Bearer $token'});
  if(iconfigService.settings.cacheDurationInSeconds > 0 && useCache == true) {
    Duration duration = cacheDuration ?? Duration(seconds: iconfigService.settings.cacheDurationInSeconds);
    request = request.useCache(duration: duration);
  }

  return request;
}

RequestX getUrlBaseRequestXWithBearerAndCache(String token, String url, {bool? useCache}) {
  var iconfigService = serviceLocator.get<IConfigurationService>();
  useCache = useCache ?? true;
  var request = RequestX.fromUrl(url).headers({HttpHeaders.authorizationHeader: 'Bearer $token'}).trustBadCertificatesInDebug(true);

  if(iconfigService.settings.cacheDurationInSeconds > 0 && useCache == true) {
    request = request.useCache(duration: Duration(seconds: iconfigService.settings.cacheDurationInSeconds));
  }

  return request;
}

extension ExcludeIsolateForWeb on RequestX {
  Future<Validation> doIsolateRequestIfPossible() {
    var iconfigService = serviceLocator.get<IConfigurationService>();
    // Se siamo in web, non possiamo usare gli isolates
    if(iconfigService.settings.apiSettings.doRequestsInIsolate && !kDebugMode) {
      return doIsolateRequest();
    }
    else {
      enableLog(true);
      return doRequest();
    }
  }
}