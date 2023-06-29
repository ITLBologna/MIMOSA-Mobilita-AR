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
import 'package:mimosa/business_logic/models/apis/buses_positions/bus_position_info.dart';
import 'package:mimosa/business_logic/models/apis/mimosa_route.dart';
import 'package:mimosa/business_logic/services/interfaces/i_bus_position_tracker_service.dart';

// class MockBusPositionTrackingService implements IBusesPositionsTrackerService {
//   @override
//   Future<Validation<List<BusPositionInfo>>> getBusesPositionsInfo(String routeId, int directionId) {
//     return Valid(
//             [BusPositionInfo(
//               busPosition: BusPosition(
//                   latitude: routeId == '20' ? 44.49042202085787 : 44.503421,
//                   longitude: routeId == '20' ? 11.324679105541009 : 11.340556,
//                   // latitude: routeId == '21' ? 44.49194112826065 : 44.492456759480504,
//                   // longitude: routeId == '21' ? 11.335012640530891 : 11.348255069366255,
//                   bearing: 118.88658,
//                   speedInMetersPerSecond: 24.0610685,
//               ),
//               vehicleId: '$routeId-$directionId',
//               updatedAt: DateTime.now(),
//               routeId: routeId,
//               routeShortName: routeId,
//               tripId: directionId.toString(),
//               polylineString: ''
//             )]
//           ).toFuture();
//   }
// }