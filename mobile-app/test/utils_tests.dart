import 'package:bitapp_functional_dart/bitapp_functional_dart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimosa/business_logic/extensions_and_utils/json_utils.dart';
import 'package:mimosa/business_logic/services/apis/apis_service.dart';
import 'package:mimosa/business_logic/services/service_locator.dart';

MimosaApisService? apiService;

void main() {
  setUp(() async {

  });

  tearDown(() async {

  });

  test('TEST hexToInt', () async {
    expect(Color(hexToInt('#000')!), Colors.black);
    expect(Color(hexToInt('#FFF')!), Colors.white);
  });

  test('TEST date time', () async {
    debugPrint(DateTime.parse('12:21:34').toString());
  });
}