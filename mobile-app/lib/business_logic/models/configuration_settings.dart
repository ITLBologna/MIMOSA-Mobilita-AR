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
import 'package:mimosa/business_logic/extensions_and_utils/errors_utils.dart';
import 'package:mimosa/business_logic/extensions_and_utils/iterable_extensions.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_notification_service.dart';

class ConfigurationSettings {
  final int cacheDurationInSeconds;
  final String configType;
  final String privacyPolicyUrl;
  final String surveyAddress;
  final NotificationRepeatInterval remindToUseNotificationRepeatInterval;
  final ApiSettings apiSettings;
  final StopsSettings stopsSettings;
  final StopsSettings tripStopsSettings;
  final BusesSettings busesSettings;
  final ArSettings arSettings;
  final TrackingSettings trackingSettings;
  final GamificationSettings gamificationSettings;
  final DynamicSettings dynamicSettings;

  ConfigurationSettings({
    this.configType = 'defaultSettings',
    required this.remindToUseNotificationRepeatInterval,
    required this.privacyPolicyUrl,
    required this.surveyAddress,
    required this.apiSettings,
    required this.stopsSettings,
    required this.tripStopsSettings,
    required this.busesSettings,
    required this.arSettings,
    required this.trackingSettings,
    required this.cacheDurationInSeconds,
    required this.gamificationSettings,
    required this.dynamicSettings
  });

  factory ConfigurationSettings.fromMap(Map<String, dynamic> map, String? configurationType) {
    final configType = configurationType ?? map['defaultConfigurationType'];
    String apiBasePath = const String.fromEnvironment('API_BASE_PATH');
    String surveyAddress = const String.fromEnvironment("SURVEY_ADDRESS");

    return ConfigurationSettings(
      configType: configType,
      privacyPolicyUrl: map['privacyPolicyUrl'],
      remindToUseNotificationRepeatInterval: NotificationRepeatInterval
          .values
          .getFirstWhere((v) => v.name == map[configType]['remindToUseNotificationRepeatInterval'])
          ?? NotificationRepeatInterval.weekly,
      surveyAddress: surveyAddress,
      apiSettings: ApiSettings.fromMap(map[configType]['apis'], apiBasePath),
      stopsSettings: StopsSettings.fromMap(map[configType]['stops']),
      tripStopsSettings: StopsSettings.fromMap(map[configType]['tripStops']),
      busesSettings: BusesSettings.fromMap(map[configType]['buses']),
      arSettings: ArSettings.fromMap(map[configType]['ar']),
      trackingSettings: TrackingSettings.fromMap(map[configType]['tracking']),
      gamificationSettings: GamificationSettings.fromMap(map[configType]['gamification']),
      cacheDurationInSeconds: map['cacheDurationInSeconds'],
      dynamicSettings: DynamicSettings()
    );
  }

  factory ConfigurationSettings.fromJson(String source, String? configurationType)
      => ConfigurationSettings.fromMap(json.decode(source), configurationType);
}

class ApiSettings {
  final String basePath;
  final bool doRequestsInIsolate;
  final bool useHttps;

  ApiSettings({
    required this.basePath,
    required this.doRequestsInIsolate,
    required this.useHttps
  });

  static ApiSettings fromMap(Map<String, dynamic> map, String apiBasePath) {
    return fromNullableMap(map, apiBasePath)!;
  }

  static ApiSettings? fromNullableMap(Map<String, dynamic>? map, String apiBasePath) {
    try {
      return map == null
          ? null
          : ApiSettings(
              basePath: apiBasePath,
              doRequestsInIsolate: map['doRequestsInIsolate'],
              useHttps: map['useHttps']
            );
    }
    catch(e)
    {
      rethrowJsonToModelMappingError(e, 'ApiSettings');
      return null;
    }
  }

  factory ApiSettings.fromJson(String source, String apiBasePath) => ApiSettings.fromMap(json.decode(source), apiBasePath);
}

class StopsSettings {
  final double maxDistanceInMeters;
  final int maxPoi;
  final int minPoi;

  StopsSettings({
    required this.maxDistanceInMeters,
    required this.maxPoi,
    required this.minPoi,
  });

  static StopsSettings fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static StopsSettings? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : StopsSettings(
              maxDistanceInMeters: map['maxDistanceInMeters'],
              maxPoi: map['maxPoi'],
              minPoi: map['minPoi'],
            );
    }
    catch(e)
    {
      rethrowJsonToModelMappingError(e, 'StopsSettings');
      return null;
    }
  }

  factory StopsSettings.fromJson(String source) => StopsSettings.fromMap(json.decode(source));
}

class BusesSettings {
  final double maxDistanceInMeters;

  BusesSettings({
    required this.maxDistanceInMeters,
  });

  static BusesSettings fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static BusesSettings? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : BusesSettings(
              maxDistanceInMeters: map['maxDistanceInMeters'],
            );
    }
    catch(e)
    {
      rethrowJsonToModelMappingError(e, 'BusesSettings');
      return null;
    }
  }

  factory BusesSettings.fromJson(String source) => BusesSettings.fromMap(json.decode(source));
}

class ArSettings {
  final int dyAnnotationsOffsetInScreenPercent;
  final double metersAfterWhichNotifyLocationChange;
  final double pinStopWhenCloserThanMeters;
  final double markDirectionAsBurnedWhenCloserThanMeters;
  final int stopArWhenInBackgroundAfterSeconds;
  final int updateUserPositionAfterSeconds;

  ArSettings({
    required this.dyAnnotationsOffsetInScreenPercent,
    required this.metersAfterWhichNotifyLocationChange,
    required this.pinStopWhenCloserThanMeters,
    required this.markDirectionAsBurnedWhenCloserThanMeters,
    required this.stopArWhenInBackgroundAfterSeconds,
    required this.updateUserPositionAfterSeconds
  });

  static ArSettings fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static ArSettings? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : ArSettings(
              dyAnnotationsOffsetInScreenPercent: map['dyAnnotationsOffsetInScreenPercent'],
              metersAfterWhichNotifyLocationChange: map['metersAfterWhichNotifyLocationChange'],
              pinStopWhenCloserThanMeters: map['pinStopWhenCloserThanMeters'],
              markDirectionAsBurnedWhenCloserThanMeters: map['markDirectionAsBurnedWhenCloserThanMeters'],
              stopArWhenInBackgroundAfterSeconds: map['stopArWhenInBackgroundAfterSeconds'],
              updateUserPositionAfterSeconds: map['updateUserPositionAfterSeconds'],
            );
    }
    catch(e)
    {
      rethrowJsonToModelMappingError(e, 'ArSettings');
      return null;
    }
  }

  factory ArSettings.fromJson(String source) => ArSettings.fromMap(json.decode(source));
}

class TrackingSettings {
  final int uploadCheckIntervalInSeconds;
  final int notificationsIntervalInMillisec;
  final int maxEntriesToUpload;
  final int minNumberOfTarckingDataToUpload;
  final int maxTimeBetweenUploadsInHours;
  final int minDistanceToTrackInMeters;
  final int distanceFilterInMeters;
  final bool enabled;

  const TrackingSettings({
    required this.enabled,
    required this.uploadCheckIntervalInSeconds,
    required this.notificationsIntervalInMillisec,
    required this.distanceFilterInMeters,
    required this.maxEntriesToUpload,
    required this.minNumberOfTarckingDataToUpload,
    required this.maxTimeBetweenUploadsInHours,
    required this.minDistanceToTrackInMeters
  });

  static TrackingSettings fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static TrackingSettings? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : TrackingSettings(
            enabled: map['enabled'],
            uploadCheckIntervalInSeconds: map['uploadCheckIntervalInSeconds'],
            notificationsIntervalInMillisec: map['notificationsIntervalInMillisec'],
            distanceFilterInMeters: map['distanceFilterInMeters'],
            maxEntriesToUpload: map['maxEntriesToUpload'],
            minNumberOfTarckingDataToUpload: map['minNumberOfTarckingDataToUpload'],
            maxTimeBetweenUploadsInHours: map['maxTimeBetweenUploadsInHours'],
            minDistanceToTrackInMeters: map['minDistanceToTrackInMeters'],
          );
    }
    catch(e)
    {
      rethrowJsonToModelMappingError(e, 'TrackingSettings');
      return null;
    }
  }

  factory TrackingSettings.fromJson(String source) => TrackingSettings.fromMap(json.decode(source));
}

class GamificationSettings {
  final double checkInCheckOutMaxDistanceInMeters;
  final int remindPlayNotificationAfterMinutes;

  GamificationSettings({
    required this.checkInCheckOutMaxDistanceInMeters,
    required this.remindPlayNotificationAfterMinutes
  });

  static GamificationSettings fromMap(Map<String, dynamic> map) {
    return fromNullableMap(map)!;
  }

  static GamificationSettings? fromNullableMap(Map<String, dynamic>? map) {
    try {
      return map == null
          ? null
          : GamificationSettings(
              checkInCheckOutMaxDistanceInMeters: map['checkInCheckOutMaxDistanceInMeters'],
              remindPlayNotificationAfterMinutes: map['remindPlayNotificationAfterMinutes'],
            );
    }
    catch(e)
    {
      rethrowJsonToModelMappingError(e, 'GamificationSettings');
      return null;
    }
  }

  factory GamificationSettings.fromJson(String source) => GamificationSettings.fromMap(json.decode(source));
}

class DynamicSettings {
  bool forceAndroidLocationManager = false;
  bool useLocationStream = false;
  bool useGeolocationStream = false;
}