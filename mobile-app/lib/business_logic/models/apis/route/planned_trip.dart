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

import 'package:mimosa/business_logic/models/apis/route/plan.dart';
import 'package:mimosa/business_logic/models/apis/route/request_parameters.dart';

class PlannedTrip {
  final RequestParameters? requestParameters;
  final Plan? plan;

  PlannedTrip({
    this.requestParameters,
    this.plan,
    });

  static PlannedTrip fromMap(Map<String, dynamic> map) {
    return PlannedTrip(
      requestParameters: RequestParameters.fromMap(map['requestParameters']),
      plan: Plan.fromMap(map['plan']),
    );
  }

  static PlannedTrip fromJson(String data) {
    return PlannedTrip.fromMap(json.decode(data) as Map<String, dynamic>);
  }
}