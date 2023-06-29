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
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:mimosa/business_logic/extensions_and_utils/debug_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/turf_extensions.dart';
import 'package:mimosa/business_logic/models/apis/buses_positions/buses_positions_infos.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/models/apis/trip.dart';
import 'package:mimosa/business_logic/services/interfaces/i_bus_position_tracker_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';
import 'package:mimosa/controllers/view_models/buses_positions_infos_vm.dart';
import 'package:mimosa/business_logic/extensions_and_utils/polyline_extension.dart';

class BusesPositionsTrackingController extends GetxController {
  BusesPositionsInfosVM? _busesInfos;
  Timer? _updatePositionTimer;
  final IBusesPositionsTrackerService tracker = serviceLocator.get<IBusesPositionsTrackerService>();
  Future<Validation<BusesPositionsInfos>> Function()? _trackBusesServiceCall;
  bool _callingServer = false;

  final int updatePositionInSeconds;
  final StreamController<List<BusPositionInfoVM>> _busPositionStreamController = StreamController<List<BusPositionInfoVM>>.broadcast();

  BusesPositionsTrackingController({
    this.updatePositionInSeconds = 1
  });

  Stream<List<BusPositionInfoVM>> get stream => _busPositionStreamController.stream;

  void trackBuses({required MimosaRoute route, required Trip trip}) {
    _busesInfos = BusesPositionsInfosVM(tripShortName: trip.shortName ?? route.shortName);
    _trackBusesServiceCall = () => tracker.getBusesPositionsInfo(route.id, trip.id);
    _updatePositionTimer = Timer.periodic(
        Duration(seconds: updatePositionInSeconds),
            (timer) {
          _trackBuses();
        });

    _trackBuses();
  }

  void stopTrack() {
    _busesInfos?.expiresAt = null;
    _busesInfos?.infos = [];
    _busPositionStreamController.add([]);
    _updatePositionTimer?.cancel();
  }

  void _trackBuses() {
    if((_busesInfos!.expiresAt == null || !DateTime.now().difference(_busesInfos!.expiresAt!).isNegative) && !_callingServer) {
      _callingServer = true;
      _trackBusesServiceCall?.call()
          .map((infos) {
            if(_busesInfos!.expiresAt == infos.expiresAt) {
              return _busesInfos!.infos;
            }

            _busesInfos!.expiresAt = infos.expiresAt;
            _busesInfos!.infos = infos
                                  .infos
                                  .map((i) => BusPositionInfoVM(
                                                tripShortName: i.trip.shortName ?? _busesInfos!.tripShortName,
                                                info: i,
                                                polyline: i.trip.shapePolyline.toPolyLine()
                                              )
                                  )
                                  .toList();

            // _busesInfos!.infos = _busesInfos!.infos.take(1).toList();
            _busesInfos!.infos
              .forEach((i) {
                // i.info.busPosition.latitude = 44.40886688232422;
                // i.info.busPosition.longitude = 11.570728302001953;
                // i.polyline = '}dsnGsdgdAfAiJfA{AZmAtAqE|@_@pMjIjIyg@Z}@FuC`@Fh@AfGWta@}BnE[Cy@|AgFhG{TnHmW`AaElGuUtGoUtAuEtD{Md@gBlC}MV_Ah@cBdC}F`@kAvD}MnEsPdHiWdBcGfFaRrG{T~HgZfEkOdCoI|A}Fr@cCpAcFrF_S`@cBl@yBXDNMBIB]Ee@@[zHyXp@gCJm@L?JGLY@_@EQfA_Ej@kBnCcKfAsDbG}Tz@sCNSDU?SX{Az@iChB{GxAkG|@yC^gAt@kB~AgD|BmEl@yA^mA|GwYjCmLbCiKZkAJu@VGNYHe@C[n@kCpD{MvAaFpGaVh@gCpLwb@nCeKzKs`@lDsMrGkUfAqDvE}PxByHbCcJl@qB^aBdOkj@x@uCL[p@u@HSBUEi@L}@lE}OjFkStEuPlBoGxE_Nf@}A^wA\\aBrAyId@oCTaAzAaFlGoR`AuDhJ_\\n@qBrNwh@fK{^bEcP|BmIjNgf@xDmN`DeLfBcGzE_QbC}InBwHzTcw@`EaOtHwWfD_MnLua@~@}C|DoNh@uBxCsKb@kBNy@\\cCh@gBj@c@`Bk@~JsEl@m@z@cBd@}AB_BFe@h@qCBWfBuHdBwGBeACQKUoBuDiA_Ca@Q`@WTUT_@Ro@nBwHhAcErB{GvAqFvCqKhEuN`IeYzMkf@lEwObAmDv@{Bz@qCvCsKfKi^nDqMlA_FdBmGzB{HnFgQ`EoNpKma@jKs^zIy[lEqOfIkXdL}a@hEaPjFsQtOui@tF_SzHeXzCeKfF{QvBcH^qB\\w@J]?WTc@Pi@hBiG|AwF~@{Cd@wBNc@HM@K^u@pCkKj@_BH_@dC}Iz@qCbBaG{CoBCOsDkJKu@@kAPqBdAwElBkGtDkLZmA|@cEuHyF'.toPolyLine();
                i.projectCoords();
              });

            return _busesInfos!.infos;
          })
          .fold(
              (failures) {
                _callingServer = false;
                debugPrint('Error loading buses positions');
              },
              (infos) {
                _busesInfos!.infos = infos;
                _interpolateBusesPositions();
                _callingServer = false;
              });
    }
    else {
      _interpolateBusesPositions();
    }
  }

  void _interpolateBusesPositions() {
    _busesInfos!.infos
        .where((info) => info.polyline.isNotEmpty)
        .forEach((info) {
          final now = DateTime.now();
          final elapsedTime = now.difference(info.updatedAt).inMilliseconds / 1000;
          final distance = elapsedTime * (info.info.busPosition.speedInMetersPerSecond * 80 / 100);

          final r = nextPointOnPolyline(info.polyline, info.projectedCoords, distance, info.indexOnPolyline);

          if(r.indexNearestPreviousPoint != -1) { // && (r.indexNearestPreviousPoint - info.indexOnPolyline).abs() < 10) {
            info.projectedCoords = r.latLon;
          }

          // debugPrint('label: ${info.info.label} - lat: ${info.info.busPosition.latitude} - lon: ${info.info.busPosition.longitude} - projlat: ${info.projectedCoords.latitude} - projlon: ${info.projectedCoords.longitude} - index = ${r.indexNearestPreviousPoint}');

          info.bearing = r.bearing;
          info.indexOnPolyline = r.indexNearestPreviousPoint;
          info.updatedAt = now;
        });

    _busPositionStreamController.add(_busesInfos!.infos);
  }

  @override
  void onInit() {
    _busPositionStreamController.add([]);
    super.onInit();
  }

  @override
  void onClose() {
    _updatePositionTimer?.cancel();
    _busPositionStreamController.close();
    super.onClose();
  }
}