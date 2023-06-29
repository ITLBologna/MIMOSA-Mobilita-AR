import 'package:geolocator/geolocator.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class ArSensor {
  final double heading;
  final double pitch;
  final Position? location;
  final NativeDeviceOrientation orientation;

  final double compassAccuracy;
  final bool compassNeedsCalibration;

  const ArSensor({
    required this.heading,
    required this.pitch,
    required this.orientation,
    required this.compassAccuracy,
    this.location,
    this.compassNeedsCalibration = false
  });

  ArSensor copyWith({
    double? heading,
    double? pitch
    }) {
    return ArSensor(
        heading: heading ?? this.heading,
        pitch: pitch ?? this.pitch,
        orientation: orientation,
        compassAccuracy: compassAccuracy,
        location: location,
        compassNeedsCalibration: compassNeedsCalibration
    );
  }
}
