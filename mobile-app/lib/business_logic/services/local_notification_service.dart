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

import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService implements ILocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future _configureLocalTimeZone() {
    tz.initializeTimeZones();
    return FlutterTimezone
        .getLocalTimezone()
        .then((value) {
          tz.setLocalLocation(tz.getLocation(value));
        });
  }

  @override
  Future<bool?> initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (
          int id,
          String? title,
          String? body,
          String? payload
      ) {},
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    return
      _configureLocalTimeZone()
      .then((value) =>
        flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {},
        )
      );
  }

  @override
  Future<bool?> requestPermissions() {
    if(Platform.isIOS) {
      final i = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return i != null
              ? i.requestPermissions(
                  alert: true,
                  badge: true,
                  sound: true,
                )
              : Future.value(false);
    }
    else {
      final i = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      return i != null
              ? i.requestPermission()
              : Future.value(false);
    }
  }

  @override
  Future<List> getPendingNotifications() {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  @override
  Future scheduleNotification({
    required int id,
    required String title,
    required String body,
    required Duration duration
  }) {
    return flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(duration),
        NotificationDetails(
            android: AndroidNotificationDetails(
                '$id id', '$id name',
                channelDescription: '$id description',
                priority: Priority.high,
                importance: Importance.high,
                fullScreenIntent: true)),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  @override
  Future schedulePeriodicalNotification({
    required int id,
    required String title,
    required String body,
    required NotificationRepeatInterval interval
  }) {
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
          '$id id',
          '$id name',
          channelDescription: '$id description'
      );

      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      return flutterLocalNotificationsPlugin
          .periodicallyShow(
            id,
            title,
            body,
            RepeatInterval.values.getFirstWhere((e) => e.name == interval.name) ?? RepeatInterval.everyMinute,
            notificationDetails,
            androidAllowWhileIdle: true
          );
  }

  @override
  Future cancelAllNotifications() {
    return flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Future cancelNotification(int id) {
    return flutterLocalNotificationsPlugin.cancel(id);
  }
}