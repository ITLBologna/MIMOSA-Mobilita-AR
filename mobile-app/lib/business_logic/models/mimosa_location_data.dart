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

class MimosaLocationData {
  MimosaLocationData({
    this.latitude,
    this.longitude,
    this.speed,
    this.heading,
    this.time,
    this.activity = 'UNKNOWN'
  });

  factory MimosaLocationData.fromMap(Map dataMap) {
    return MimosaLocationData(
      latitude: dataMap['latitude'],
      longitude: dataMap['longitude'],
      speed: dataMap['speed'],
      heading: dataMap['heading'],
      time: dataMap['time'],
      activity: dataMap['activity'] ?? 'UNKNOWN'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'heading': heading,
      'time': time,
      'activity': activity
    };
  }

  final String activity;

  /// Latitude in degrees
  final double? latitude;

  /// Longitude, in degrees
  final double? longitude;

  /// In meters/second
  ///
  /// Always 0 on Web
  final double? speed;

  /// Heading is the horizontal direction of travel of this device, in degrees
  ///
  /// Always 0 on Web
  final double? heading;

  /// timestamp of the LocationData
  final double? time;
}

extension MimosaLocationDataFromMap on Map<dynamic, Map> {
  List<MimosaLocationData> fromMapWithKeys() {
    return values
        .map((map) => MimosaLocationData.fromMap(map))
        .toList();
  }
}