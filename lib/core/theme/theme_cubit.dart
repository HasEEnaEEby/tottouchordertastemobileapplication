import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/light_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';

enum ThemePreference {
  light,
  dark,
  system,
  auto, // Mode that uses light sensor
}

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeBoxKey = "theme_preferences";
  static const String _themeModeKey = "theme_mode";
  static const String _themePreferenceKey = "theme_preference";

  ThemePreference _preference = ThemePreference.light;
  LightSensorService? _lightSensorService;
  // Getter for the current preference
  ThemePreference get preference => _preference;

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Toggle between light and dark themes and persist the preference.
  Future<void> toggleTheme() async {
    try {
      final newPreference = _preference == ThemePreference.light
          ? ThemePreference.dark
          : ThemePreference.light;

      await _setThemePreference(newPreference);
    } catch (e) {
      // Fallback to light theme if there's an error
      emit(ThemeMode.light);
    }
  }

  /// Set a specific theme preference
  Future<void> setThemePreference(ThemePreference preference) async {
    await _setThemePreference(preference);
  }

  /// Enable auto theme based on light sensor
  Future<void> enableAutoTheme() async {
    await _setThemePreference(ThemePreference.auto);
  }

  /// Update theme based on light sensor
  void updateThemeBasedOnLight(ThemeMode newThemeMode) {
    if (_preference == ThemePreference.auto) {
      emit(newThemeMode);
    }
  }

  /// Private method to set and save theme preference
  Future<void> _setThemePreference(ThemePreference preference) async {
    try {
      // Stop listening to light sensor if we were in auto mode
      if (_preference == ThemePreference.auto) {
        _stopLightSensor();
      }

      _preference = preference;

      // Save preference
      final box = await Hive.openBox(_themeBoxKey);
      await box.put(_themePreferenceKey, preference.index);

      // Update theme based on preference
      final ThemeMode newThemeMode;

      switch (preference) {
        case ThemePreference.light:
          newThemeMode = ThemeMode.light;
          break;
        case ThemePreference.dark:
          newThemeMode = ThemeMode.dark;
          break;
        case ThemePreference.system:
          newThemeMode = ThemeMode.system;
          break;
        case ThemePreference.auto:
          // Start listening to light sensor
          _startLightSensor();
          // Get the initial theme mode based on current light level
          newThemeMode = _getCurrentLightBasedTheme();
          break;
      }

      await box.put(_themeModeKey, newThemeMode.index);

      emit(newThemeMode);

      // Debug log the change
      debugPrint(
          'Theme preference set to $preference, theme mode is $newThemeMode');
    } catch (e) {
      debugPrint('Error setting theme preference: $e');
      // Fallback to light theme if there's an error
      emit(ThemeMode.light);
    }
  }

  // Get theme mode based on current light level
  ThemeMode _getCurrentLightBasedTheme() {
    try {
      if (_lightSensorService == null) {
        _initLightSensor();
      }

      if (_lightSensorService != null) {
        return _lightSensorService!.isDarkEnvironment
            ? ThemeMode.dark
            : ThemeMode.light;
      }

      // Fallback to system theme if light sensor not available
      return ThemeMode.system;
    } catch (e) {
      debugPrint('Error getting light-based theme: $e');
      return ThemeMode.system;
    }
  }

  // Initialize light sensor
  void _initLightSensor() {
    try {
      debugPrint('Initializing light sensor for ThemeCubit');
      final sensorManager = GetIt.instance<SensorManager>();
      _lightSensorService = sensorManager.lightSensorService;
      debugPrint('Light sensor initialized successfully');
    } catch (e) {
      debugPrint('Error initializing light sensor: $e');
      _lightSensorService = null;
    }
  }

  // Start listening to light sensor
  void _startLightSensor() {
    try {
      if (_lightSensorService == null) {
        _initLightSensor();
      }

      if (_lightSensorService != null) {
        debugPrint('Starting light sensor for auto theme');
        _lightSensorService!.startListening();

        // Add listener for light changes
        _lightSensorService!.addListener(_onLightChanged);

        debugPrint('Light sensor listening started for auto theme');
      }
    } catch (e) {
      debugPrint('Error starting light sensor: $e');
    }
  }

  // Stop listening to light sensor
  void _stopLightSensor() {
    try {
      if (_lightSensorService != null) {
        _lightSensorService!.removeListener(_onLightChanged);
      }

      debugPrint('Light sensor stopped for ThemeCubit');
    } catch (e) {
      debugPrint('Error stopping light sensor: $e');
    }
  }

  // Handle light changes
  void _onLightChanged(int lux) {
    if (_preference == ThemePreference.auto) {
      final isDark = _lightSensorService?.isDarkEnvironment ?? false;
      final newThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;

      debugPrint(
          'Light changed to $lux lux (${isDark ? "DARK" : "BRIGHT"}), updating theme to $newThemeMode');

      if (state != newThemeMode) {
        emit(newThemeMode);
      }
    }
  }

  /// Load the saved theme preference from Hive.
  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_themeBoxKey);

      // Load theme preference (auto, light, dark, system)
      final savedPreferenceIndex = box.get(_themePreferenceKey,
          defaultValue: ThemePreference.light.index);

      if (savedPreferenceIndex >= 0 &&
          savedPreferenceIndex < ThemePreference.values.length) {
        _preference = ThemePreference.values[savedPreferenceIndex];
      } else {
        _preference = ThemePreference.light;
      }

      // Load saved theme mode
      final savedThemeIndex =
          box.get(_themeModeKey, defaultValue: ThemeMode.light.index);

      // Use saved theme mode
      ThemeMode themeMode;
      if (savedThemeIndex >= 0 && savedThemeIndex < ThemeMode.values.length) {
        themeMode = ThemeMode.values[savedThemeIndex];
      } else {
        themeMode = ThemeMode.light;
      }

      // If auto mode is saved, start the light sensor
      if (_preference == ThemePreference.auto) {
        _startLightSensor();
        // Get theme based on current light
        themeMode = _getCurrentLightBasedTheme();
      }

      emit(themeMode);
      debugPrint('Theme loaded: preference=$_preference, mode=$themeMode');
    } catch (e) {
      debugPrint('Error loading theme: $e');
      // If there's an error loading theme, default to light theme
      _preference = ThemePreference.light;
      emit(ThemeMode.light);
    }
  }

  @override
  Future<void> close() {
    _stopLightSensor();
    return super.close();
  }
}
