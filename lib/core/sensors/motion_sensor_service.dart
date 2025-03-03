import 'package:sensors_plus/sensors_plus.dart';

class MotionSensorService {
  void startListening() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      print("Accelerometer - X: ${event.x}, Y: ${event.y}, Z: ${event.z}");
    });

    gyroscopeEvents.listen((GyroscopeEvent event) {
      print("Gyroscope - X: ${event.x}, Y: ${event.y}, Z: ${event.z}");
    });

    magnetometerEvents.listen((MagnetometerEvent event) {
      print("Magnetometer - X: ${event.x}, Y: ${event.y}, Z: ${event.z}");
    });
  }
}
