import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimosa/business_logic/services/apis/apis_service.dart';
import 'package:mimosa/business_logic/services/local_storage_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

MimosaApisService? apiService;

void main() {
  setUp(() async {

  });

  tearDown(() async {

  });

  // test('TEST UPLOAD TRACKED LOCATIONS', () async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   apiService = MimosaApisService();
  //   await setupServiceLocator();
  //
  //   await apiService
  //       !.uploadTrackedLocations(
  //         trackedLocations: {
  //           "user_id": "2",
  //           "tracking_data": [
  //             {
  //               "posix_time": 1669799100,
  //               "lat": 43.0009877,
  //               "lon": 11.4567788,
  //               "speed" : 2,
  //               "heading" : 2,
  //               "activity" : "STILL"
  //
  //             },
  //             {
  //               "posix_time": 1669799300,
  //               "lat": 53.0009877,
  //               "lon": 22.4567788,
  //               "speed" : 2,
  //               "heading" : 2,
  //               "activity" : "STILL"
  //             }
  //           ]
  //         }
  //     )
  //     .fold(
  //         (failures) => fail('Success expected'),
  //         (res) {
  //           expect(res['data'][0]['user_id'], '2');
  //         });
  // });
  //
  // test('TEST PLAN ROUTE', () async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   apiService = MimosaApisService();
  //   serviceLocator.reset();
  //   await setupServiceLocator();
  //   await apiService
  //       !.planRoute(
  //           fromLat: 44.489383179286676,
  //           fromLng: 11.358908830808275,
  //           toLat: 44.49997499416335,
  //           toLng: 11.324748216794717,
  //           mode: 'TRANSIT,WALK',
  //           arriveBy: false,
  //           weelchair: false,
  //           showIntermediateStops: true,
  //           locale: 'it',
  //           minTransferTime: 0
  //       )
  //       .fold(
  //           (failures)
  //               => fail('Success expected'),
  //           (route) {
  //
  //           });
  // });
  //
  // test('TEST AUTOCOMPLETE', () async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   apiService = MimosaApisService();
  //   serviceLocator.reset();
  //   await setupServiceLocator();
  //
  //   await apiService
  //     !.placeAutocomplete(
  //       lat: 44.489383179286676,
  //       lng: 11.358908830808275,
  //       text: 'Marconi'
  //   )
  //   .fold(
  //     (failures)
  //       => fail('Success expected'),
  //     (places) {
  //       expect(places.length, 10);
  //     });
  // });

  test('TEST NEXT RUNS', () async {
    WidgetsFlutterBinding.ensureInitialized();
    apiService = MimosaApisService();
    await setupServiceLocator();

    await apiService
    !.getNextRuns(
        stopId: 'BO_459',
        routeId: 'BO_21',
        nResults: 4
    )
        .fold(
            (failures)
        => fail('Success expected'),
            (runs) {
          expect(runs.runs.length, 4);
        });
  });

}