import 'package:flutter/material.dart';

import 'barometer_service.dart';
import 'biometric_auth_service.dart';
import 'light_sensor_service.dart';
import 'location_service.dart';
import 'motion_sensor_service.dart';
import 'pedometer_service.dart';
import 'proximity_sensor_service.dart';

class SensorManager {
  final MotionSensorService motionSensorService;
  final LocationService locationService;
  final ProximitySensorService proximitySensorService;
  final LightSensorService lightSensorService;
  final BarometerService barometerService;
  final PedometerService pedometerService;
  final BiometricAuthService biometricAuthService;

  SensorManager({
    required this.motionSensorService,
    required this.locationService,
    required this.proximitySensorService,
    required this.lightSensorService,
    required this.barometerService,
    required this.pedometerService,
    required this.biometricAuthService,
  });

  void initializeAllSensors() {
    debugPrint("Initializing all sensors...");
    motionSensorService.startListening();
    proximitySensorService.startListening();
    barometerService.startListening();
    pedometerService.startListening();
    debugPrint("All sensors initialized");
  }

  void disposeSensors() {
    debugPrint("Disposing all sensors...");
    proximitySensorService.stopListening();
    debugPrint("All sensors disposed");
  }

  // Method to handle screen dimming based on proximity
  void setupScreenDimming(BuildContext context) {
    proximitySensorService.addListener((isNear) {
      if (isNear) {
        debugPrint("Object near - screen should dim");
      } else {
        debugPrint("Object far - restore normal brightness");
      }
    });
  }

  // Method to handle device actions based on proximity
  void setupProximityActions(Function(bool) onProximityChange) {
    proximitySensorService.addListener(onProximityChange);
  }

  // Updated to match the new method signature in BiometricAuthService
  Future<bool> authenticateUser() async {
    bool authenticated = await biometricAuthService.authenticateUser();
    debugPrint("User authentication: $authenticated");
    return authenticated;
  }
}
