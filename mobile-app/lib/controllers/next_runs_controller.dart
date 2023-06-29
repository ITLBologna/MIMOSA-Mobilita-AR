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
import 'package:mimosa/business_logic/models/apis/next_runs/run.dart';
import 'package:mimosa/business_logic/models/apis/next_runs/runs.dart';
import 'package:mimosa/business_logic/services/interfaces/i_next_runs_service.dart';
import 'package:mimosa/controllers/base_controllers/base_controller.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

class NextRunsQueryData {
  final String routeId;
  final String stopId;
  final int nResults;

  const NextRunsQueryData({
    required this.routeId,
    required this.stopId,
    required this.nResults
  });

  @override
  String toString() => '${routeId}_${stopId}_$nResults';
}

class _Cache {
  DateTime? expiresAt;  
  bool isLoading = true;
  Runs? runs;

  bool get cacheExpired => expiresAt == null || expiresAt!.difference(DateTime.now()).isNegative;
}

class NextRunsController {
  final service = serviceLocator.get<INextRunsService>();
  final Map<String, _Cache> _cachedData = {};

  bool isCacheExpired(NextRunsQueryData queryData) {
    final cache = _cachedData[queryData.toString()];
    return cache?.cacheExpired ?? true;
  }

  List<Run> getValidRuns(NextRunsQueryData queryData) {
    final cache = _cachedData[queryData.toString()];
    if(cache?.runs == null) {
      return [];
    }

    return cache!.runs!.runs.where((r) => (r.liveTime ?? r.scheduledTime)?.difference(DateTime.now()).isNegative == false).toList();
  }

  Future<Validation<List<Run>>> getRuns(NextRunsQueryData? requestData, {bool? useCache}) {
    query() => service
        .getNextRuns(routeId: requestData!.routeId, stopId: requestData.stopId, nResults: requestData.nResults)
        .map((runs) {
      final c = _cachedData[requestData.toString()]!;
      c.runs = runs;
      c.expiresAt = runs.expiresAt;
      c.isLoading = false;

      return runs.runs;
    });

    final cache = _cachedData[requestData!.toString()];
    if(cache == null) {
      _cachedData[requestData.toString()] = _Cache();
      return query();
    }
    else if(cache.cacheExpired && !cache.isLoading) {
      cache.isLoading = true;
      return query();
    }

    return Valid(getValidRuns(requestData)).toFuture();
  }
}