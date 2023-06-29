import 'dart:io';

import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimosa/business_logic/services/local_storage_service.dart';

LocalStorage storage = LocalStorage();
void main() {
  setUp(() async {
    await storage.init(relativePath: './test');
  });

  tearDown(() async {
    await storage.deleteStorage();
  });

  test('DATABASE INIT AND DELETE TESTS', () async {
    final dbFile = File('./test/mimosa_bad_keys.hive');
    bool exists = await dbFile.exists();
    expect(exists, true);

    await storage.deleteStorage();
    exists = await dbFile.exists();
    expect(exists, false);
  });

  test('User Id', () async {
    final uid = await storage
            .getUserId()
            .fold(
              (failures) => fail('Expected success'),
              (val) => val);
    final uid2 = await storage
        .getUserId()
        .fold(
            (failures) => fail('Success expected'),
            (val) => val);
    expect(uid2, uid);
  });

  test('CRUDS', () async {
    await storage.storeLocationData('id1', {'id': 'id1', 'numero': 1});
    await storage
            .getLocationData('id1')
            .fold(
              (failures)
                => fail('Success expected'),
              (val) => expect(val['numero'], 1));

    await storage.storeLocationData('id1', {'id': 'id1', 'numero': 101});
    await storage
        .getLocationsData()
        .fold(
          (failures)
            => fail('Success expected'),
          (val) {
            expect(val.keys.length, 1);
            expect(val['id1'], {'id': 'id1', 'numero': 101});

          }
        );

    await storage.storeLocationData('id1', {'id': 'id1', 'numero': 1});

    await storage.storeLocationData('id2', {'id': 'id2', 'numero': 2});
    await storage
            .getLocationsData()
            .fold(
              (failures)
                => fail('Success expected'),
              (val) {
                expect(val.keys.length, 2);
                expect(val['id1'], {'id': 'id1', 'numero': 1});

              }
            );
    await storage
        .getLocationsData()
        .bindFuture((map) => storage.deleteLocations(map.keys))
        .bindFuture((_) => storage.getLocationsData())
        .fold(
            (failures) => fail('Success expected'),
            (val) => expect(val.keys.length, 0)
        );
  });
}