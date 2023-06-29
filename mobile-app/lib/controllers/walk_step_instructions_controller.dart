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

import 'package:flutter/material.dart';
import 'package:mimosa/business_logic/models/apis/route/walk_step.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WalkStepInstructionsController {
  static String getInstructions(WalkStep step, {required BuildContext context}) {
    final loc = AppLocalizations.of(context)!;

    final absoluteDir = parseAbsoluteDirection(step.absoluteDirection, context: context);
    final relativeDir = parseRelativeDirection(step.relativeDirection, context: context);
    final streetName = parseStreetName(step.streetName, context: context);

    if (step.relativeDirection == 'DEPART') {
      return loc.walk_step_depart_instruction(absoluteDir, streetName);
    } else {
      if(step.stayOn == true) {
        return loc.walk_step_stay_on_instruction(relativeDir, streetName);
      }
      else {
        return loc.walk_step_take_instruction(relativeDir, streetName);
      }
    }
  }

  static String parseRelativeDirection(direction, {required BuildContext context}) {
    final loc = AppLocalizations.of(context)!;
    switch (direction) {
      case 'CONTINUE':
        return loc.walk_step_continue;
      case 'LEFT':
        return loc.walk_step_left;
      case 'RIGHT':
        return loc.walk_step_right;
      case 'SLIGHTLY_LEFT':
        return loc.walk_step_slightly_left;
      case 'SLIGHTLY_RIGHT':
        return loc.walk_step_slightly_right;
      case 'HARD_LEFT':
        return loc.walk_step_hard_left;
      case 'HARD_RIGHT':
        return loc.walk_step_hard_right;
      case 'UTURN_LEFT':
        return loc.walk_step_uturn_left;
      case 'UTURN_RIGHT':
        return loc.walk_step_uturn_right;
      case 'CIRCLE_COUNTERCLOCKWISE':
        return loc.walk_step_circle_counterclockwise;
      case 'CIRCLE_CLOCKWISE':
        return loc.walk_step_circle_clockwise;
      default:
        return direction;
    }
  }

  static String parseAbsoluteDirection(direction, {required BuildContext context}) {
    final loc = AppLocalizations.of(context)!;
    switch (direction) {
      case 'NORTH':
        return loc.walk_step_north;
      case 'NORTHEAST':
        return loc.walk_step_northeast;
      case 'EAST':
        return loc.walk_step_east;
      case 'SOUTHEAST':
        return loc.walk_step_southeast;
      case 'SOUTH':
        return loc.walk_step_south;
      case 'SOUTHWEST':
        return loc.walk_step_southwest;
      case 'WEST':
        return loc.walk_step_west;
      case 'NORTHWEST':
        return loc.walk_step_northwest;
      default:
        return direction;
    }
  }

  static String parseStreetName(streetName, {required BuildContext context}) {
    final loc = AppLocalizations.of(context)!;
    switch (streetName) {
      case 'path':
        return loc.walk_step_path;
      case 'bike path':
        return loc.walk_step_bike_path;
      case 'service road':
        return loc.walk_step_service_road;
      case 'footbridge':
        return loc.walk_step_footbridge;
      case 'steps':
        return loc.walk_step_steps;
      case 'sidewalk':
        return loc.walk_step_sidewalk;
      case 'road':
        return loc.walk_step_road;
      case 'parking aisle':
        return loc.walk_step_parking_isle;
      case 'link':
        return loc.walk_step_link;
      case 'open area':
        return loc.walk_step_open_area;
      default:
        return streetName;
    }
  }
}

