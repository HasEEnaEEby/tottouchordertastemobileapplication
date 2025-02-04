import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;

  static const String keyIsFirstTime = 'isFirstTime';
  static const String keyAuthToken = 'authToken';
  static const String keyUserId = 'userId';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserType = 'userType';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyOnboardingCompleted = 'onboardingCompleted';
  static const String keyThemeMode = 'themeMode';
  static const String keyLanguage = 'language';
  static const String keyUserPreferences = 'userPreferences';

  SharedPreferencesService(this._prefs);

  Future<bool> isFirstTime() async {
    return _prefs.getBool(keyIsFirstTime) ?? true;
  }

  Future<void> setFirstTime(bool value) async {
    await _prefs.setBool(keyIsFirstTime, value);
  }

  Future<String?> getAuthToken() async {
    return _prefs.getString(keyAuthToken);
  }

  Future<void> setAuthToken(String token) async {
    await _prefs.setString(keyAuthToken, token);
  }

  Future<void> removeAuthToken() async {
    await _prefs.remove(keyAuthToken);
  }

  Future<void> setUserId(String userId) async {
    await _prefs.setString(keyUserId, userId);
  }

  String? getUserId() {
    return _prefs.getString(keyUserId);
  }

  Future<void> setUserEmail(String email) async {
    await _prefs.setString(keyUserEmail, email);
  }

  String? getUserEmail() {
    return _prefs.getString(keyUserEmail);
  }

  Future<void> setUserType(String type) async {
    await _prefs.setString(keyUserType, type);
  }

  String? getUserType() {
    return _prefs.getString(keyUserType);
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(keyIsLoggedIn, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(keyIsLoggedIn) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(keyOnboardingCompleted, value);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(keyOnboardingCompleted) ?? false;
  }

  // Theme Management
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(keyThemeMode, mode);
  }

  String getThemeMode() {
    return _prefs.getString(keyThemeMode) ?? 'system';
  }

  // Language Preference
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(keyLanguage, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(keyLanguage) ?? 'en';
  }

  // Complex Object Storage
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final String jsonString = json.encode(preferences);
    await _prefs.setString(keyUserPreferences, jsonString);
  }

  Map<String, dynamic>? getUserPreferences() {
    final String? jsonString = _prefs.getString(keyUserPreferences);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear All Data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Clear Only User Data (for logout)
  Future<void> clearUserData() async {
    await _prefs.remove(keyAuthToken);
    await _prefs.remove(keyUserId);
    await _prefs.remove(keyUserEmail);
    await _prefs.remove(keyUserType);
    await _prefs.remove(keyIsLoggedIn);
    await _prefs.remove(keyUserPreferences);
  }

  bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }
}
