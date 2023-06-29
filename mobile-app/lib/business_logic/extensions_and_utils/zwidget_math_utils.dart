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

import 'dart:math';

double getArrowRotationRadiansFromBearings({
  required double userBearing,
  required double bearing
}) {
  var rotation = (bearing - userBearing).abs();
  if(bearing < userBearing) {
    rotation = 360 - rotation;
  }

  // Arrow icon is rotated to 90 degrees so adjust!
  rotation -= 90;

  if(rotation < 0) {
    rotation += 360;
  }

  // ZWidget has a strange coordinates mapping
  // the 1st quarter goes from 0 to 90
  if(rotation > 270 && rotation <= 360) {
    rotation = 360 - rotation;
  }
  // The 4th quarter from 0 to -90
  else if(rotation > 0 && rotation <= 90) {
    rotation *= -1;
  }
  // The 2nd from 180 to 270 and 3rd to 90 to 180 so we don't need to adjust anything for these quarters

  return rotation * pi / 180;
}