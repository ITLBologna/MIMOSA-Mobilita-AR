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

abstract class IApisService {
  Future<Validation<List<TripStop>>> getStops({required double lat,
    required double lon,
    int? maxDistanceInMeters,
    int? maxPoi,
    bool? useCache});

  Future<Validation<List<Agency>>> getAgencies(
      {required Duration cacheDuration});

  Future<Validation<List<MimosaRoute>>> getRoutes({
    required double lat,
    required double lon,
    bool? useCache});

  Future<Validation<List<Trip>>> getTrips({
    required String routeId,
    bool? useCache});

  Future<Validation<Runs>> getNextRuns({
    required String routeId,
    required String stopId,
    required int nResults,
    bool? useCache});

  Future<Validation<BusesPositionsInfos>> trackBuses({
    required String routeId,
    required String tripId});

  Future<Validation<PlannedTrip>> planRoute({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
    String mode,
    bool arriveBy,
    bool weelchair,
    bool showIntermediateStops,
    String locale,
    int minTransferTime,
    bool? useCache});

  Future<Validation<List<AutocompletePlace>>> placeAutocomplete({
    required double lat,
    required double lng,
    required String text,
    String? culture,
    bool? useCache});

  Future<Validation<Map<String, dynamic>>> uploadTrackedLocations(
      {required Map<String,
          dynamic> trackedLocations});

  Future<Validation<ClaimPrizeResponse>> claimGamificationPrize({
    required String userId,
    required String inStopId,
    required String outStopId,
    String? otpFirstStopId,
    String? otpLastStopId,
  });

  Future<Validation<MimosaLeaderboard>> getRank({
    required String userId,
  });

  Future<Validation<UserAccessResponse>> userAccess({
    required String userId,
    bool suggestionsConsent = false,
    bool gamificationConsent = false,
    bool surveyConsent = false
  });
}