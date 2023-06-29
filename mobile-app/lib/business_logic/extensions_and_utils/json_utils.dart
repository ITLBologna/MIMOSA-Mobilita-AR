
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

DateTime? toDateTime(String? value) {
  if(value != null)
  {
    return DateTime.parse(value);
  }

  return null;
}

List<T> listFromMap<T>(Map<String, dynamic> map, {String? key, required T Function(Map<String, dynamic>) fromMap}) {
  final m = key == null ? map : map[key];
  return m == null ? [] : List<T>.from(m?.map((x) => fromMap(x)));
}

List<T> simpleTypeListFromMap<T>(Map<String, dynamic> map, {required String key}) {
  return map[key] == null ? [] : List<T>.from(map[key]);
}

bool? toBool(Map<String, dynamic> map, String key)
{
  if(map[key] == null)
  {
    return null;
  }

  if(map[key] is int)
  {
    return map[key] > 0;
  }

  return map[key];
}

double toDouble(Map<String, dynamic> map, String key)
{
  if(map[key] == null)
  {
    return 0;
  }

  if(map[key] is int)
  {
    return (map[key] as int).toDouble();
  }

  return map[key];
}

/// Se value è un double lo ritorna altrimenti se è una stringa lo converte
double getDouble(dynamic value) {
  return value is String
      ? double.parse(value)
      : value;
}

/// Se value è un int lo ritorna altrimenti se è una stringa lo converte
int getInt(dynamic value) {
  return value is String
      ? int.parse(value)
      : value;
}

DateTime? getDateTimeFromMilliseconds(dynamic value) {
  if(value == null) {
    return null;
  }

  return DateTime.fromMillisecondsSinceEpoch(getInt(value));
}

int? hexToInt(dynamic hex) {
  if(hex == null) {
    return null;
  }

  var hexColor = hex as String;
  hexColor = hexColor.replaceAll('#', '');
  final replaceStr = (hexColor.contains('000') || hexColor == '0') ? '0' : 'F';
  hexColor = hexColor.padLeft(6, replaceStr);
  hexColor = 'FF$hexColor';
  return int.parse("0x$hexColor");
}

int whiteColorInt() => hexToInt('#FFF')!;
int blackColorInt() => hexToInt('#000')!;