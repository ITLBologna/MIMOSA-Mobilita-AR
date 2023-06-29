import 'dart:async';
import 'package:ar_location_view/ar_position.dart';

abstract class IArLocationService
{
  StreamSubscription<ArPosition> listenToPosition(void Function(ArPosition) callback);
  Future<ArPosition> getLastPosition();
}

