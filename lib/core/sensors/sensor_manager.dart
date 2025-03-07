import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  final PedometerService pedometerService;
  final BiometricAuthService biometricAuthService;

  final Logger logger = Logger('SensorManager');

  // Track proximity feature states
  bool _isProximityScreenDimmingEnabled = true;
  bool _isProximityAutoPauseEnabled = true;
  bool _isProximityTouchBlockingEnabled = true;
  bool _isProximitySoundPauseEnabled = true; // New property for sound pausing

  // Track motion feature states
  bool _isShakeDetectionEnabled = true;
  bool _isRotationDetectionEnabled = true;
  bool _isShakeSoundEnabled = true;

  // Getters for feature states
  bool get isProximityScreenDimmingEnabled => _isProximityScreenDimmingEnabled;
  bool get isProximityAutoPauseEnabled => _isProximityAutoPauseEnabled;
  bool get isProximityTouchBlockingEnabled => _isProximityTouchBlockingEnabled;
  bool get isProximitySoundPauseEnabled => _isProximitySoundPauseEnabled;
  bool get isShakeDetectionEnabled => _isShakeDetectionEnabled;
  bool get isRotationDetectionEnabled => _isRotationDetectionEnabled;
  bool get isShakeSoundEnabled => _isShakeSoundEnabled;

  SensorManager({
    required this.motionSensorService,
    required this.locationService,
    required this.proximitySensorService,
    required this.lightSensorService,
    required this.pedometerService,
    required this.biometricAuthService,
  });

  void initializeAllSensors({
    bool startMotion = true,
    bool startProximity = true,
    bool startLight = true,
    bool force = false, // Add this parameter
  }) {
    if (force || startMotion) motionSensorService.startListening();
    if (force || startProximity) proximitySensorService.startListening();
    if (force || startLight) lightSensorService.startListening();
  }

  void disposeSensors() {
    debugPrint("Disposing all sensors...");
    proximitySensorService.stopListening();
    lightSensorService.stopListening();
    motionSensorService.stopListening();

    debugPrint("All sensors disposed");
  }

  // Method to handle screen dimming based on proximity
  void setupScreenDimming(BuildContext context) {
    debugPrint("Setting up proximity-based screen dimming");
    proximitySensorService.addListener((isNear) {
      if (isNear && _isProximityScreenDimmingEnabled) {
        debugPrint("Object near - screen should dim");
        // Implementation handled in UI layer
      } else {
        debugPrint("Object far - restore normal brightness");
        // Implementation handled in UI layer
      }
    });
  }

  // Setup media controls based on proximity sensor (e.g., pause video/audio)
  void setupMediaControls(Function(bool) onProximityChange) {
    debugPrint("Setting up proximity-based media controls");
    proximitySensorService.addListener((isNear) {
      if (_isProximityAutoPauseEnabled) {
        onProximityChange(isNear);
      }
    });
  }

  // Setup touch blocking based on proximity sensor
  void setupTouchBlocking(Function(bool) onProximityChange) {
    debugPrint("Setting up proximity-based touch blocking");
    proximitySensorService.addListener((isNear) {
      if (_isProximityTouchBlockingEnabled) {
        onProximityChange(isNear);
      }
    });
  }

  // Setup shake detection with custom callback
  void setupShakeDetection(Function() onShakeDetected) {
    debugPrint("Setting up shake detection");
    if (_isShakeDetectionEnabled) {
      motionSensorService.addShakeListener(onShakeDetected);
    }
  }

  // Setup rotation detection with custom callback
  void setupRotationDetection(Function(GyroscopeEvent) onRotationDetected) {
    debugPrint("Setting up rotation detection");
    if (_isRotationDetectionEnabled) {
      motionSensorService.addRotationListener(onRotationDetected);
    }
  }

  // Toggle proximity-based screen dimming
  bool toggleProximityScreenDimming() {
    _isProximityScreenDimmingEnabled = !_isProximityScreenDimmingEnabled;
    debugPrint(
        "Proximity screen dimming: ${_isProximityScreenDimmingEnabled ? 'ENABLED' : 'DISABLED'}");
    return _isProximityScreenDimmingEnabled;
  }

  // Toggle proximity-based auto-pause
  bool toggleProximityAutoPause() {
    _isProximityAutoPauseEnabled = !_isProximityAutoPauseEnabled;
    debugPrint(
        "Proximity auto-pause: ${_isProximityAutoPauseEnabled ? 'ENABLED' : 'DISABLED'}");
    return _isProximityAutoPauseEnabled;
  }

  // Toggle proximity-based touch blocking
  bool toggleProximityTouchBlocking() {
    _isProximityTouchBlockingEnabled = !_isProximityTouchBlockingEnabled;
    debugPrint(
        "Proximity touch blocking: ${_isProximityTouchBlockingEnabled ? 'ENABLED' : 'DISABLED'}");
    return _isProximityTouchBlockingEnabled;
  }

  // New method: Toggle proximity-based sound pause
  bool toggleProximitySoundPause() {
    _isProximitySoundPauseEnabled = !_isProximitySoundPauseEnabled;
    debugPrint(
        "Proximity sound pause: ${_isProximitySoundPauseEnabled ? 'ENABLED' : 'DISABLED'}");
    return _isProximitySoundPauseEnabled;
  }

  // Toggle shake detection
  bool toggleShakeDetection() {
    _isShakeDetectionEnabled = !_isShakeDetectionEnabled;
    debugPrint(
        "Shake detection: ${_isShakeDetectionEnabled ? 'ENABLED' : 'DISABLED'}");

    if (!_isShakeDetectionEnabled && !_isRotationDetectionEnabled) {
      motionSensorService.stopListening();
    } else if (_isShakeDetectionEnabled && !motionSensorService.isListening()) {
      motionSensorService.startListening();
    }

    return _isShakeDetectionEnabled;
  }

  // Toggle rotation detection
  bool toggleRotationDetection() {
    _isRotationDetectionEnabled = !_isRotationDetectionEnabled;
    debugPrint(
        "Rotation detection: ${_isRotationDetectionEnabled ? 'ENABLED' : 'DISABLED'}");

    if (!_isShakeDetectionEnabled && !_isRotationDetectionEnabled) {
      motionSensorService.stopListening();
    } else if (_isRotationDetectionEnabled &&
        !motionSensorService.isListening()) {
      motionSensorService.startListening();
    }

    return _isRotationDetectionEnabled;
  }

  bool toggleShakeSound() {
    _isShakeSoundEnabled = !_isShakeSoundEnabled;

    // Use the method from MotionSensorService instead of direct property assignment
    if (_isShakeSoundEnabled) {
      motionSensorService.enableSound();
    } else {
      motionSensorService.disableSound();
    }

    debugPrint("Shake sound: ${_isShakeSoundEnabled ? 'ENABLED' : 'DISABLED'}");
    return _isShakeSoundEnabled;
  }

  // Play shake sound manually (for testing)
  void playShakeSound() {
    if (_isShakeSoundEnabled) {
      motionSensorService.playShakeSound();
    }
  }

  // Method to handle device actions based on proximity
  void setupProximityActions(
    Function(bool) onProximityChange, {
    bool useForDimming = true,
    bool useForPauseMedia = true,
    bool useForTouchBlocking = true,
    bool useForSoundPause = true,
  }) {
    _isProximityScreenDimmingEnabled = useForDimming;
    _isProximityAutoPauseEnabled = useForPauseMedia;
    _isProximityTouchBlockingEnabled = useForTouchBlocking;
    _isProximitySoundPauseEnabled = useForSoundPause;

    proximitySensorService.addListener(onProximityChange);
  }

  // Authenticate user using biometrics
  Future<bool> authenticateUser() async {
    bool authenticated = await biometricAuthService.authenticateUser();
    debugPrint("User authentication: $authenticated");
    return authenticated;
  }

  // Method to check if proximity sensor is active
  bool isProximitySensorActive() {
    try {
      return proximitySensorService.isListening();
    } catch (e) {
      debugPrint("Error checking proximity sensor status: $e");
      return false;
    }
  }

  // Method to check if motion sensor is active
  bool isMotionSensorActive() {
    try {
      return motionSensorService.isListening();
    } catch (e) {
      debugPrint("Error checking motion sensor status: $e");
      return false;
    }
  }
}
