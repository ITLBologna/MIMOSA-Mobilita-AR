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

import 'dart:convert';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:bitapp_http_x/bitapp_http_x.dart';
import 'package:mimosa/business_logic/extensions_and_utils/errors_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/models/apis/agency.dart';
import 'package:mimosa/business_logic/models/apis/autocomplete_place.dart';
import 'package:mimosa/business_logic/models/apis/buses_positions/buses_positions_infos.dart';
import 'package:mimosa/business_logic/models/apis/claim_prize_response.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_leaderbord.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/next_runs/runs.dart';
import 'package:mimosa/business_logic/models/apis/route/planned_trip.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/models/apis/user_access_response.dart';
import 'package:mimosa/business_logic/services/apis/commons.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';

class MimosaApisService implements IApisService {
  /// Get stops near user position
  @override
  Future<Validation<List<TripStop>>> getStops(
      {required double lat,
      required double lon,
      int? maxDistanceInMeters,
      int? maxPoi,
      bool? useCache}) {
    var params = {'lat': '$lat', 'lon': '$lon'};
    if (maxDistanceInMeters != null) {
      params['maxDistanceInKm'] = '${maxDistanceInMeters / 1000}';
    }
    if (maxPoi != null) {
      params['limit'] = '$maxPoi';
    }

    return getBaseRequestXWithBearerAndCache('', useCache: useCache)
        .path('v1/stops')
        .jsonGet()
        .params(params)
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() => listFromMap(map,
            key: 'data', fromMap: (map) => TripStop.fromMap(map))))
        .tryCatch();
  }

  @override
  Future<Validation<List<Agency>>> getAgencies(
      {required Duration cacheDuration}) {
    return getBaseRequestXWithBearerAndCache('',
            useCache: true, cacheDuration: cacheDuration)
        .path('v1/agencies')
        .jsonGet()
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() => listFromMap(map,
            key: 'data', fromMap: (map) => Agency.fromMap(map))))
        .tryCatch();
  }

  @override
  Future<Validation<List<MimosaRoute>>> getRoutes(
      {required double lat, required double lon, bool? useCache}) {
    var params = {'lat': '$lat', 'lon': '$lon'};

    return getBaseRequestXWithBearerAndCache('', useCache: useCache)
        .path('v1/routes')
        .jsonGet()
        .params(params)
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() => listFromMap(map,
            key: 'data', fromMap: (map) => MimosaRoute.fromMap(map))))
        .tryCatch();
  }

  @override
  Future<Validation<List<Trip>>> getTrips(
      {required String routeId, bool? useCache}) {
    return getBaseRequestXWithBearerAndCache('', useCache: useCache)
        .path('v1/routes/$routeId/trips')
        .jsonGet()
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() =>
            listFromMap(map, key: 'data', fromMap: (map) => Trip.fromMap(map))))
        .tryCatch();
  }

  @override
  Future<Validation<Runs>> getNextRuns(
      {required String routeId,
      required String stopId,
      required int nResults,
      bool? useCache}) {
    final params = {'route': routeId, 'next': '$nResults'};

    return getBaseRequestXWithBearerAndCache('', useCache: useCache)
        .path('v1/stops/$stopId/arrivals')
        .params(params)
        .jsonGet()
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() => Runs.fromMap(map)))
        .tryCatch();
  }

  @override
  Future<Validation<BusesPositionsInfos>> trackBuses(
      {required String routeId, required String tripId}) {
    final params = {
      'trip': tripId,
    };

    return getBaseRequestXWithBearerAndCache('', useCache: false)
        .path('v1/routes/$routeId/vehicles')
        .params(params)
        .jsonGet()
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind(
            (map) => tryMapJsonToModel(() => BusesPositionsInfos.fromMap(map)))
        .tryCatch();
  }

  @override
  Future<Validation<PlannedTrip>> planRoute(
      {required double fromLat,
      required double fromLng,
      required double toLat,
      required double toLng,
      String mode = 'TRANSIT,WALK',
      bool arriveBy = false,
      bool weelchair = false,
      bool showIntermediateStops = true,
      String locale = 'it',
      int minTransferTime = 0,
      bool? useCache}) {
    var params = {
      'fromPlace': '$fromLat,$fromLng',
      'toPlace': '$toLat,$toLng',
      'mode': mode,
      'arriveBy': arriveBy.toString(),
      'weelchair': weelchair.toString(),
      'showIntermediateStops': showIntermediateStops.toString(),
      'locale': locale,
      'minTransferTime': minTransferTime.toString(),
      // 'date': '2023-02-01',
      // 'time': '20:00'
    };
    return getOtpBaseRequestXWithBearerAndCache('', useCache: useCache)
        .path('otp/routers/default/plan')
        .params(params)
        .jsonGet()
        .doIsolateRequestIfPossible()
        .map((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() => PlannedTrip.fromMap(map)))
        .tryCatch();
  }

  @override
  Future<Validation<List<AutocompletePlace>>> placeAutocomplete(
      {required double lat,
      required double lng,
      required String text,
      String? culture,
      bool? useCache}) {
    var params = {
      'text': text,
      'lang': culture ?? 'it',
      'focus.point.lat': '$lat',
      'focus.point.lon': '$lng'
    };

    return getBaseRequestXWithBearerAndCache('', useCache: useCache)
        .path('geo/v1/autocomplete')
        .params(params)
        .doIsolateRequestIfPossible()
        .map<Map<String, dynamic>>((val) => json.decode(val))
        .bind((map) => tryMapJsonToModel(() => listFromMap(map,
            key: 'features', fromMap: (map) => AutocompletePlace.fromMap(map))))
        .tryCatch();
  }

  @override
  Future<Validation<Map<String, dynamic>>> uploadTrackedLocations(
      {required Map<String, dynamic> trackedLocations}) {
    return getBaseRequestXWithBearerAndCache('', useCache: false)
        .path('tracking/data')
        .jsonPost()
        .body(trackedLocations)
        .doIsolateRequestIfPossible()
        .map<Map<String, dynamic>>((val) => json.decode(val))
        .tryCatch();
  }

  @override
  Future<Validation<ClaimPrizeResponse>> claimGamificationPrize({
    required String userId,
    required String inStopId,
    required String outStopId,
    String? otpFirstStopId,
    String? otpLastStopId,
  }) {
    final body = {
      'user_id': userId,
      'in_stop_id': inStopId,
      'out_stop_id': outStopId,
      'otp_first_stop_id': otpFirstStopId,
      'otp_last_stop_id': otpLastStopId,
    };

    if (otpFirstStopId == null) body.remove("otp_first_stop_id");
    if (otpLastStopId == null) body.remove("otp_last_stop_id");

    return getBaseRequestXWithBearerAndCache('', useCache: false)
        .path('n/play')
        .jsonPost()
        .body(body)
        .doIsolateRequestIfPossible()
        .map<Map<String, dynamic>>((val) => json.decode(val)['data'])
        .bind((map) => tryMapJsonToModel(() => ClaimPrizeResponse.fromMap(map)))
        .tryCatch();
  }

  @override
  Future<Validation<MimosaLeaderboard>> getRank({
    required String userId,
  }) {
    Future<Validation<MimosaLeaderboard>> result =
        getBaseRequestXWithBearerAndCache('', useCache: false)
            .path('n/leaderboard/$userId')
            .doIsolateRequestIfPossible()
            .map<MimosaLeaderboard>(
                (val) => MimosaLeaderboard.fromMap(json.decode(val)['data']));

    return result;
  }

  @override
  Future<Validation<UserAccessResponse>> userAccess(
      {required String userId,
      bool? suggestionsConsent,
      bool? gamificationConsent,
      bool? surveyConsent}) {
    final body = {
      'user_id': userId,
      'suggestions_consent': suggestionsConsent ?? false,
      'gamification_consent': gamificationConsent ?? false,
      'survey_consent': surveyConsent ?? false
    };

    return getBaseRequestXWithBearerAndCache('', useCache: false)
        .path('n/user/access')
        .jsonPost()
        .body(body)
        .doIsolateRequestIfPossible()
        .map<Map<String, dynamic>>((val) => json.decode(val))
        .bind((map) =>
            tryMapJsonToModel(() => UserAccessResponse.fromMap(map['data'])))
        .tryCatch();
  }
}
