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
import 'package:mimosa/business_logic/models/apis/mimosa_leaderbord.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_rank.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/base_controllers/base_controller.dart';

class LeaderboardController extends BaseController<MimosaLeaderboard, MimosaLeaderboard, NoValue> {
  MimosaLeaderboard? mimosaLeaderboard;
  @override
  Future<Validation<MimosaLeaderboard>> internalGetDataFromServer(NoValue? requestData, {bool? useCache}) {
    final apiService = serviceLocator.get<IApisService>();
    final localStorage = serviceLocator.get<ILocalStorage>();

    return localStorage
        .getUserId()
        .bindFuture((userId) {
          return apiService.getRank(userId: userId);
        });
  }

  @override
  void internalManageData(MimosaLeaderboard serverData) {
    uiData = Valid(serverData);
    mimosaLeaderboard = serverData;
  }
}