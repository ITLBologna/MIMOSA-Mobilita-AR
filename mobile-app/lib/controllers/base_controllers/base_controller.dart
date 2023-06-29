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
import 'package:get/get.dart';

/// Classe di base per i controllers. Il controller chiede dei dati al server
/// che restituirà un json o un dato convertibile in R e poi
/// li trasforma nel tipo di dato finale T. Siccome la richiesta al server può fallire,
/// entrambi i dati sono contenuti in un contenitore di tipo Validation.
/// N.B.: T e R potrebbero  essere dello stesso tipo
abstract class BaseController<T, R, RD> extends GetxController {
  Validation<T> uiData = StateError('Dato ancora non richiesto').toInvalid();
  bool executing = true;
  StreamSubscription? _ongoingRequest;

  
  Future<void> manageRequest(RD? requestData, {bool? useCache}) {
    cancelOngoingRequest();

    _ongoingRequest =
        internalGetDataFromServer(requestData, useCache: useCache ?? true)
          .asStream()
          .listen((event) {
              event.fold(
                      (failures) {
                        executing = false;
                        uiData = failures.first.toInvalid();
                        update();
                      },
                      (serverData) {
                        executing = false;
                        internalManageData(serverData);
                        update();
                      });
            });

    return _ongoingRequest!.asFuture();      
  }

  Future<void>? cancelOngoingRequest()
  {
    return _ongoingRequest?.cancel();
  }

  Future<Validation<R>> internalGetDataFromServer(RD? requestData, {bool? useCache});

  void internalManageData(R serverData);

  void invalidateData() => uiData = StateError('Dato ancora non richiesto').toInvalid();

  void forceReloadDataAndUpdateUI (RD requestData) {
    invalidateData();
    manageRequest(requestData, useCache: false);
    update();
  }
}

