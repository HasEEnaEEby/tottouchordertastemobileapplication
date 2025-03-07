// lib/core/auth/auth_token_manager.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _emailVerifiedKey = 'email_verified';
  static const String _tokenExpiryKey =
      'token_expiry'; // Added for easier access

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
      debugPrint('💾 Saving new auth data...');

      // Extract and store token expiry time
      int? expiryTimestamp;
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          expiryTimestamp = payload['exp'];
          debugPrint(
              '📅 Token expiry extracted: ${DateTime.fromMillisecondsSinceEpoch(expiryTimestamp! * 1000)}');
        }
      } catch (e) {
        debugPrint('⚠️ Could not extract token expiry: $e');
      }

      await Future.wait([
        _prefs.setString(_tokenKey, token),
        _prefs.setString(_refreshTokenKey, refreshToken),
        _prefs.setString(_userDataKey, jsonEncode(userData)),
        _prefs.setBool(_emailVerifiedKey, userData['isEmailVerified'] ?? false),
        if (expiryTimestamp != null)
          _prefs.setInt(_tokenExpiryKey, expiryTimestamp),
      ]);

      // Verify data was saved
      final savedToken = getToken();
      debugPrint('✅ Token saved: ${savedToken != null ? 'Yes' : 'No'}');
      if (savedToken != null && savedToken.length > 20) {
        debugPrint('🔑 Token starts with: ${savedToken.substring(0, 20)}...');
      }

      debugPrint('✅ Auth data saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving auth data: $e');
      rethrow;
    }
  }

  String? getToken() => _prefs.getString(_tokenKey);
  String? getRefreshToken() => _prefs.getString(_refreshTokenKey);
  bool isEmailVerified() => _prefs.getBool(_emailVerifiedKey) ?? false;

  // Get token expiry date
  DateTime? getTokenExpiry() {
    final timestamp = _prefs.getInt(_tokenExpiryKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }

    // Fallback: try to extract from token if available
    final token = getToken();
    if (token != null) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        }
      } catch (e) {
        debugPrint('⚠️ Could not extract expiry from token: $e');
      }
    }
    return null;
  }

  // Check if token will expire soon (within 10 minutes)
  bool willTokenExpireSoon() {
    final expiry = getTokenExpiry();
    if (expiry == null)
      return true; // If we can't determine, assume it will expire

    final now = DateTime.now();
    final timeUntilExpiry = expiry.difference(now);

    // Token needs refresh if it expires in less than 10 minutes
    final needsRefresh = timeUntilExpiry.inMinutes < 10;

    debugPrint(
        '⏱️ Token expiry check: ${needsRefresh ? "Needs refresh" : "Still valid"}');
    debugPrint('⏱️ Time until expiry: ${timeUntilExpiry.inMinutes} minutes');

    return needsRefresh;
  }

  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }

  // Get specific user data field with type safety
  T? getUserDataField<T>(String key) {
    final userData = getUserData();
    if (userData != null && userData.containsKey(key)) {
      final value = userData[key];
      if (value is T) {
        return value;
      }
    }
    return null;
  }

  Future<void> clearAuthData() async {
    try {
      debugPrint('🧹 Clearing auth data...');
      await Future.wait([
        _prefs.remove(_tokenKey),
        _prefs.remove(_refreshTokenKey),
        _prefs.remove(_userDataKey),
        _prefs.remove(_emailVerifiedKey),
        _prefs.remove(_tokenExpiryKey),
      ]);
      debugPrint('✅ Auth data cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing auth data: $e');
      rethrow;
    }
  }

  bool hasValidToken() {
    final token = getToken();

    if (token == null) {
      debugPrint('🔍 Token check: None found');
      return false;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('🔍 Token check: Invalid format');
        return false;
      }

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      final isValid = DateTime.now().isBefore(expiry);

      debugPrint('🔍 Token check: ${isValid ? "Valid" : "Expired"}');
      debugPrint('📅 Token expiry: $expiry');
      debugPrint('📅 Current time: ${DateTime.now()}');
      debugPrint(
          '⏱️ Time remaining: ${expiry.difference(DateTime.now()).inMinutes} minutes');

      return isValid;
    } catch (e) {
      debugPrint('❌ Error validating token: $e');
      return false;
    }
  }

  // Update token after refresh
  Future<void> updateTokensAfterRefresh(
      String newToken, String newRefreshToken) async {
    try {
      debugPrint('🔄 Updating tokens after refresh...');

      // Extract and store token expiry time
      int? expiryTimestamp;
      try {
        final parts = newToken.split('.');
        if (parts.length == 3) {
          final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
          expiryTimestamp = payload['exp'];
        }
      } catch (e) {
        debugPrint('⚠️ Could not extract new token expiry: $e');
      }

      await Future.wait([
        _prefs.setString(_tokenKey, newToken),
        _prefs.setString(_refreshTokenKey, newRefreshToken),
        if (expiryTimestamp != null)
          _prefs.setInt(_tokenExpiryKey, expiryTimestamp),
      ]);

      debugPrint('✅ Tokens updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating tokens: $e');
      rethrow;
    }
  }

  Future<void> updateEmailVerificationStatus(bool isVerified) async {
    try {
      debugPrint('📧 Updating email verification status: $isVerified');
      final userData = getUserData();
      if (userData != null) {
        userData['isEmailVerified'] = isVerified;
        await _prefs.setBool(_emailVerifiedKey, isVerified);
        await _prefs.setString(_userDataKey, jsonEncode(userData));
        debugPrint('✅ Email verification status updated');
      } else {
        debugPrint(
            '⚠️ Could not update email verification: No user data found');
      }
    } catch (e) {
      debugPrint('❌ Error updating email verification status: $e');
      rethrow;
    }
  }
}
