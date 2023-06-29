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
import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String systemLocaleFormat({required BuildContext context}) {
    final code = Localizations.localeOf(context).languageCode;
    return DateFormat('EEEE, d MMMM, y', code).format(this);
  }

  bool isToday() {
    final today = DateTime.now();
    return today.year == year && today.month == month && today.day == day;
  }

  String toRelative({DateTime? dateTime, required BuildContext context}) {
    final dateToCheck = dateTime ?? DateTime.now();
    var dateDiff = dateToCheck.difference(this);

    if (dateDiff.inDays == 0) {
      if(dateDiff.inHours < 1) {
        if(dateDiff.inMinutes < 1) {
          if(dateDiff.inSeconds < 1) {
            return 'Now';
          }
          else {
            return '${dateDiff.inSeconds} seconds ago';
          }
        }
        else if (dateDiff.inMinutes == 1) {
          return '1 minute ago';
        }
        else {
          return '${dateDiff.inMinutes} minutes ago';
        }
      }
      else if(dateDiff.inHours == 1) {
        return '1 hours ago';
      }
      else {
        return '${dateDiff.inHours} hours ago';
      }
    }
    else if (dateDiff.inDays > 0)
    {
      if(dateDiff.inDays == 1)
      {
        return 'Yesterday';
      }

      if (dateDiff.inDays <= 30)
      {
        return '${dateDiff.inDays} days ago';
      }

      final months = dateDiff.inDays ~/ 30;
      if(months == 1)
      {
        return "1 mese fa";
      }

      if (months < 12)
      {
        return "$months mesi fa";
      }

      return systemLocaleFormat(context: context);
    }

    return "now";
  }

  String intToTwoDigitString(int i) => i.toString().padLeft(2, '0');
  DateTime getNextDateWithTimeString(String timeString) {
    final dateStr = '$year${intToTwoDigitString(month)}${intToTwoDigitString(day)} $timeString';
    final newDate = DateTime.parse(dateStr);
    if(newDate.compareTo(this) == -1) {
      return newDate.add(const Duration(days: 1));
    }

    return newDate;
  }

  String toTimeString() {
    return '${intToTwoDigitString(hour)}:${intToTwoDigitString(minute)}:${intToTwoDigitString(second)}';
  }

  String format(String? format, BuildContext? context) {
    String? languageCode;
    if(context != null) {
      languageCode = Localizations.localeOf(context).languageCode;
    }
    return DateFormat(format, languageCode).format(this);
  }

  Duration? getDifference(DateTime? other) {
    return other == null
        ? null
        : difference(other);
  }
}

extension DateExtOnString on String {
  DateTime fromTime() {
    return DateTime.parse(this);
  }
}

String formatDate(DateTime? date, String format)
{
  final DateFormat formatter = DateFormat(format);
  return date != null
      ? formatter.format(date)
      : '';
}

String? nullableFormatDate(DateTime? date, String format)
{
  final DateFormat formatter = DateFormat(format);
  return date != null
      ? formatter.format(date)
      : null;
}
