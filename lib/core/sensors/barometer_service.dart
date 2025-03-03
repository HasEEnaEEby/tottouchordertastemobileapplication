import 'package:sensors_plus/sensors_plus.dart';

class BarometerService {
  void startListening() {
    accelerometerEvents.listen((event) {
      print("Simulating Barometer (Using Accelerometer) - X: ${event.x}");
    });
  }
}
