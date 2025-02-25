import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  final SharedPreferences _prefs;

  // 🔹 Authentication keys
  static const String keyAuthToken = 'authToken';
  static const String keyAuthTokenExpiry = 'authTokenExpiry';
  static const String keyUserId = 'userId';
  static const String keyUserEmail = 'userEmail';
  static const String keyUserType = 'userType';
  static const String keyIsLoggedIn = 'isLoggedIn';

  // 🔹 App Preferences keys
  static const String keyIsFirstTime = 'isFirstTime';
  static const String keyOnboardingCompleted = 'onboardingCompleted';
  static const String keyThemeMode = 'themeMode';
  static const String keyLanguage = 'language';
  static const String keyUserPreferences = 'userPreferences';

  SharedPreferencesService(this._prefs);

  // ==================================================
  // 🔹 AUTH TOKEN MANAGEMENT
  // ==================================================

  /// ✅ Save the authentication token along with an expiry time
  Future<void> setAuthToken(String token, {int expiresIn = 3600}) async {
    final expiryTime =
        DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    await _prefs.setString(keyAuthToken, token);
    await _prefs.setInt(keyAuthTokenExpiry, expiryTime);
  }

  /// ✅ Check if the authentication token has expired
  bool isAuthTokenExpired() {
    final int? expiryTime = _prefs.getInt(keyAuthTokenExpiry);
    if (expiryTime == null) return true; // No expiry time means expired
    return DateTime.now().millisecondsSinceEpoch > expiryTime;
  }

  /// ✅ Retrieve the auth token safely (removes it if expired)
  Future<String?> getAuthToken() async {
    if (isAuthTokenExpired()) {
      await removeAuthToken();
      return null;
    }
    return _prefs.getString(keyAuthToken);
  }

  /// ✅ Remove the authentication token (used for logout)
  Future<void> removeAuthToken() async {
    await _prefs.remove(keyAuthToken);
    await _prefs.remove(keyAuthTokenExpiry);
  }

  // ==================================================
  // 🔹 USER SESSION MANAGEMENT
  // ==================================================

  /// ✅ Store User ID
  Future<void> setUserId(String userId) async {
    await _prefs.setString(keyUserId, userId);
  }

  /// ✅ Retrieve User ID
  String? getUserId() {
    return _prefs.getString(keyUserId);
  }

  /// ✅ Store User Email
  Future<void> setUserEmail(String email) async {
    await _prefs.setString(keyUserEmail, email);
  }

  /// ✅ Retrieve User Email
  String? getUserEmail() {
    return _prefs.getString(keyUserEmail);
  }

  /// ✅ Store User Type (Customer, Admin, etc.)
  Future<void> setUserType(String type) async {
    await _prefs.setString(keyUserType, type);
  }

  /// ✅ Retrieve User Type
  String? getUserType() {
    return _prefs.getString(keyUserType);
  }

  /// ✅ Set Logged-in Status
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(keyIsLoggedIn, value);
  }

  /// ✅ Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // ==================================================
  // 🔹 APP PREFERENCES MANAGEMENT
  // ==================================================

  /// ✅ Set First-Time App Launch
  Future<void> setFirstTime(bool value) async {
    await _prefs.setBool(keyIsFirstTime, value);
  }

  /// ✅ Check if it's the first-time launch
  Future<bool> isFirstTime() async {
    return _prefs.getBool(keyIsFirstTime) ?? true;
  }

  /// ✅ Set Onboarding Completion
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(keyOnboardingCompleted, value);
  }

  /// ✅ Check if Onboarding is Completed
  bool isOnboardingCompleted() {
    return _prefs.getBool(keyOnboardingCompleted) ?? false;
  }

  /// ✅ Set Theme Mode (light/dark/system)
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(keyThemeMode, mode);
  }

  /// ✅ Get Theme Mode
  String getThemeMode() {
    return _prefs.getString(keyThemeMode) ?? 'system';
  }

  /// ✅ Set Preferred Language
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(keyLanguage, languageCode);
  }

  /// ✅ Get Preferred Language
  String getLanguage() {
    return _prefs.getString(keyLanguage) ?? 'en';
  }

  // ==================================================
  // 🔹 COMPLEX OBJECT STORAGE
  // ==================================================

  /// ✅ Save user preferences as JSON
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final String jsonString = json.encode(preferences);
    await _prefs.setString(keyUserPreferences, jsonString);
  }

  /// ✅ Retrieve user preferences
  Map<String, dynamic>? getUserPreferences() {
    final String? jsonString = _prefs.getString(keyUserPreferences);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // ==================================================
  // 🔹 DATA CLEARING METHODS
  // ==================================================

  /// ✅ Clear all stored preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// ✅ Clear only user-related data (for logout)
  Future<void> clearUserData() async {
    await _prefs.remove(keyAuthToken);
    await _prefs.remove(keyAuthTokenExpiry);
    await _prefs.remove(keyUserId);
    await _prefs.remove(keyUserEmail);
    await _prefs.remove(keyUserType);
    await _prefs.remove(keyIsLoggedIn);
    await _prefs.remove(keyUserPreferences);
  }

  // ==================================================
  // 🔹 GENERIC GETTERS & SETTERS
  // ==================================================

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
