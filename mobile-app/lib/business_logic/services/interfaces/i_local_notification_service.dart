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

enum NotificationRepeatInterval {
  everyMinute,

  /// Hourly interval.
  hourly,

  /// Daily interval.
  daily,

  /// Weekly interval.
  weekly
}

abstract class ILocalNotificationService {
  Future<bool?> initialize();
  Future<bool?> requestPermissions();
  Future schedulePeriodicalNotification({
    required int id,
    required String title,
    required String body,
    required NotificationRepeatInterval interval
  });

  Future<List> getPendingNotifications();
  Future scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration});

  Future cancelNotification(int id);
  Future cancelAllNotifications();
}