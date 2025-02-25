import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

const String themeBoxKey = "theme_preferences";
const String themeModeKey = "isDarkMode";

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  /// Toggle between light and dark themes and persist the preference.
  void toggleTheme() async {
    final isCurrentlyLight = state == ThemeMode.light;
    final box = await Hive.openBox(themeBoxKey);
    box.put(themeModeKey, isCurrentlyLight); // Save preference
    emit(isCurrentlyLight ? ThemeMode.dark : ThemeMode.light);
  }

  /// Load the saved theme preference from Hive.
  Future<void> _loadTheme() async {
    final box = await Hive.openBox(themeBoxKey);
    final isDark = box.get(themeModeKey, defaultValue: false) as bool;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
