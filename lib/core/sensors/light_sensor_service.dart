import 'dart:async';

import 'package:flutter/material.dart';
import 'package:light/light.dart';

// Define the light level enum
enum LightLevel { dark, dim, normal, bright, veryBright }

class LightSensorService {
  Light? _light;
  StreamSubscription<int>? _lightSubscription;
  int _currentLux = 0;
  final List<Function(int)> _listeners = [];

  static const int darkThreshold = 10;
  static const int dimThreshold = 50;
  static const int normalThreshold = 200;
  static const int brightThreshold = 1000;

  // Get the current light level
  int get currentLux => _currentLux;

  // Determine if the environment is dark
  bool get isDarkEnvironment => _currentLux < dimThreshold;

  // Get the current brightness level category
  LightLevel get currentBrightnessLevel {
    if (_currentLux < darkThreshold) return LightLevel.dark;
    if (_currentLux < dimThreshold) return LightLevel.dim;
    if (_currentLux < normalThreshold) return LightLevel.normal;
    if (_currentLux < brightThreshold) return LightLevel.bright;
    return LightLevel.veryBright;
  }

  void startListening() {
    try {
      debugPrint("🔆 ATTEMPTING to start light sensor...");
      if (_lightSubscription != null) {
        debugPrint("🔆 Light sensor already listening");
        return;
      }

      _light = Light();
      debugPrint("🔆 Light sensor initialized");

      _lightSubscription = _light?.lightSensorStream.listen((int luxValue) {
        debugPrint("🔆 Light sensor reading: $luxValue lux");
        if (_currentLux != luxValue) {
          _currentLux = luxValue;
          _notifyListeners();
        }
      });

      debugPrint("🔆 Light sensor listening started successfully");
    } catch (e) {
      debugPrint("❌ Error starting light sensor: $e");
    }
  }

  // Stop listening to light sensor events
  void stopListening() {
    _lightSubscription?.cancel();
    _lightSubscription = null;
    debugPrint("Light sensor listening stopped");
  }

  // Add a listener to be notified of light level changes
  void addListener(Function(int) listener) {
    _listeners.add(listener);
  }

  // Remove a previously added listener
  void removeListener(Function(int) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners of light level changes
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_currentLux);
    }
  }

  // Dispose resources when service is no longer needed
  void dispose() {
    stopListening();
    _listeners.clear();
  }

  // Get appropriate ThemeMode based on ambient light
  ThemeMode getRecommendedThemeMode() {
    return isDarkEnvironment ? ThemeMode.dark : ThemeMode.light;
  }

  // Get brightness category based on light level
  String getLightLevelDescription() {
    switch (currentBrightnessLevel) {
      case LightLevel.dark:
        return "Very dark";
      case LightLevel.dim:
        return "Dim";
      case LightLevel.normal:
        return "Normal indoor lighting";
      case LightLevel.bright:
        return "Bright";
      case LightLevel.veryBright:
        return "Very bright";
    }
  }
}
