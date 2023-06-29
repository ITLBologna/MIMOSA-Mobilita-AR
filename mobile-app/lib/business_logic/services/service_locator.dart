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

import 'package:get_it/get_it.dart';
import 'package:mimosa/business_logic/models/apis/trip_stop.dart';
import 'package:mimosa/business_logic/services/annotations/direction_annotations_service.dart';
import 'package:mimosa/business_logic/services/annotations/trip_stop_annotations_service.dart';
import 'package:mimosa/business_logic/services/apis/agencies_service.dart';
import 'package:mimosa/business_logic/services/apis/api_routes_service.dart';
import 'package:mimosa/business_logic/services/apis/apis_service.dart';
import 'package:mimosa/business_logic/services/apis/buses_positions_infos_service.dart';
import 'package:mimosa/business_logic/services/autocomplete_places_service.dart';
import 'package:mimosa/business_logic/services/geolocation_service.dart';
import 'package:mimosa/business_logic/services/configuration_service.dart';
import 'package:mimosa/business_logic/services/apis/api_stops_service.dart';
import 'package:mimosa/business_logic/services/fixed_stops_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_agencies_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_annotations_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_apis.dart';
import 'package:mimosa/business_logic/services/interfaces/i_autocomplete_place_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_bus_position_tracker_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_configuration_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_directions_annotations_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_notification_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_location_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_next_runs_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_routes_service.dart';
import 'package:mimosa/business_logic/services/interfaces/i_local_storage.dart';
import 'package:mimosa/business_logic/services/interfaces/i_stops_service.dart';
import 'package:mimosa/business_logic/services/local_notification_service.dart';
import 'package:mimosa/business_logic/services/local_storage_service.dart';
import 'package:mimosa/business_logic/services/apis/next_runs_service.dart';
import 'package:mimosa/business_logic/services/services_constants.dart';

final GetIt serviceLocator = GetIt.instance;

Future<IConfigurationService> setupServiceLocator({String? configurationType}) {
  serviceLocator.registerLazySingleton<IConfigurationService>(() => ConfigurationService());
  return serviceLocator
      .get<IConfigurationService>()
      .loadSettings(configurationType: configurationType)
      .then((value) {
        serviceLocator.registerLazySingleton<IAnnotationsService<TripStop>>(() => TripStopAnnotationsService(apiStopsServiceInstanceName), instanceName: apiStopsServiceInstanceName);
        serviceLocator.registerLazySingleton<IAnnotationsService<TripStop>>(() => TripStopAnnotationsService(fixedStopsServiceInstanceName), instanceName: fixedStopsServiceInstanceName);

        serviceLocator.registerLazySingleton<IApisService>(() => MimosaApisService());
        // serviceLocator.registerLazySingleton<IBackgroundLocationService>(() => BackgroundLocationService());
        serviceLocator.registerLazySingleton<ILocationService>(() => GeoLocationService());
        serviceLocator.registerLazySingleton<ILocalStorage>(() => LocalStorage());

        serviceLocator.registerLazySingleton<IStopsService>(() => ApiStopsService(), instanceName: apiStopsServiceInstanceName);
        serviceLocator.registerLazySingleton<IStopsService>(() => FixedStopsService(), instanceName: fixedStopsServiceInstanceName);
        serviceLocator.registerLazySingleton<IRoutesService>(() => ApiRoutesService());
        serviceLocator.registerLazySingleton<IAgenciesService>(() => AgenciesService());

        // serviceLocator.registerLazySingleton<IAutocompletePlaceService>(() => MockAutocompletePlacesService());
        // serviceLocator.registerLazySingleton<IBusesPositionsTrackerService>(() => MockBusPositionTrackingService());
        serviceLocator.registerLazySingleton<IBusesPositionsTrackerService>(() => BusesPositionsInfosTrackingService());
        serviceLocator.registerLazySingleton<INextRunsService>(() => NextRunsService());

        serviceLocator.registerLazySingleton<IAutocompletePlaceService>(() => AutocompletePlacesService());
        serviceLocator.registerLazySingleton<IDirectionsAnnotationsService>(() => DirectionsAnnotationsService());

        serviceLocator.registerLazySingleton<ILocalNotificationService>(() => LocalNotificationService());
        return serviceLocator.get<IConfigurationService>();
      });
}
