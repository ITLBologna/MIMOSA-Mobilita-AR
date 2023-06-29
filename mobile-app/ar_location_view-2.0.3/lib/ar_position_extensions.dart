import 'package:geolocator/geolocator.dart';
import 'package:ar_location_view/ar_position.dart';

extension PositionExtension on Position {
  ArPosition toArPosition() {
    return ArPosition(
        longitude: longitude,
        latitude: latitude,
        timestamp: timestamp,
        accuracy: accuracy,
        altitude: altitude,
        heading: heading,
        speed: speed,
        speedAccuracy: speedAccuracy,
        floor: floor
    );
  }
}

extension ArPositionExtension on ArPosition {
  Position toPosition() {
    return Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: timestamp,
        accuracy: accuracy,
        altitude: altitude,
        heading: heading,
        speed: speed,
        speedAccuracy: speedAccuracy,
        floor: floor
    );
  }
}