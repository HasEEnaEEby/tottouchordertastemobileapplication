// lib/core/auth/auth_token_manager.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _emailVerifiedKey = 'email_verified';

  final SharedPreferences _prefs;

  // Simplified constructor
  AuthTokenManager(this._prefs);

  // Store tokens and user data
  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required Map<String, dynamic> userData,
  }) async {
    try {
      debugPrint('Saving new auth data...');
      await Future.wait([
        _prefs.setString(_tokenKey, token),
        _prefs.setString(_refreshTokenKey, refreshToken),
        _prefs.setString(_userDataKey, jsonEncode(userData)),
        _prefs.setBool(_emailVerifiedKey, userData['isEmailVerified'] ?? false),
      ]);

      // Verify data was saved
      final savedToken = getToken();
      debugPrint('Saved token verified: ${savedToken != null}');

      debugPrint('Auth data saved successfully');
    } catch (e) {
      debugPrint('Error saving auth data: $e');
      rethrow;
    }
  }

  String? getToken() => _prefs.getString(_tokenKey);
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);
  bool isEmailVerified() => _prefs.getBool(_emailVerifiedKey) ?? false;

  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _prefs.remove(_tokenKey),
        _prefs.remove(_refreshTokenKey),
        _prefs.remove(_userDataKey),
        _prefs.remove(_emailVerifiedKey),
      ]);
      debugPrint('Auth data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      rethrow;
    }
  }

  bool hasValidToken() {
    final token = getToken();
    debugPrint('Checking token: ${token?.substring(0, 20)}...'); // Add this

    if (token == null) {
      debugPrint('Token is null'); // Add this
      return false;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      final isValid = DateTime.now().isBefore(expiry);

      debugPrint('Token expiry: $expiry'); // Add this
      debugPrint('Current time: ${DateTime.now()}'); // Add this
      debugPrint('Token validity: $isValid'); // Add this

      return isValid;
    } catch (e) {
      debugPrint('Error validating token: $e'); // Add this
      return false;
    }
  }

  Future<void> updateEmailVerificationStatus(bool isVerified) async {
    try {
      final userData = getUserData();
      if (userData != null) {
        userData['isEmailVerified'] = isVerified;
        await _prefs.setBool(_emailVerifiedKey, isVerified);
        await saveAuthData(
          token: getToken()!,
          refreshToken: getRefreshToken()!,
          userData: userData,
        );
      }
    } catch (e) {
      debugPrint('Error updating email verification status: $e');
      rethrow;
    }
  }
}
