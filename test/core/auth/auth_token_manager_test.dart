import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';

// Generate mock for SharedPreferences
@GenerateMocks([SharedPreferences])
import 'auth_token_manager_test.mocks.dart';

void main() {
  late MockSharedPreferences mockPrefs;
  late AuthTokenManager authManager;

  // Sample test data
  final String validToken = createSampleJWT(
    expiryInSeconds: 3600, // 1 hour in future
    payload: {'sub': 'test-user', 'email': 'test@example.com'},
  );

  final String expiredToken = createSampleJWT(
    expiryInSeconds: -3600,
    payload: {'sub': 'test-user', 'email': 'test@example.com'},
  );

  const String refreshToken = 'refresh-token-12345';
  final Map<String, dynamic> userData = {
    'id': 'user123',
    'name': 'Test User',
    'email': 'test@example.com',
    'isEmailVerified': true,
  };

  setUp(() {
    mockPrefs = MockSharedPreferences();
    authManager = AuthTokenManager(mockPrefs);
  });

  group('AuthTokenManager', () {
    group('saveAuthData', () {
      test('should save auth data successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString('auth_token')).thenReturn(validToken);

        // Act
        await authManager.saveAuthData(
          token: validToken,
          refreshToken: refreshToken,
          userData: userData,
        );

        // Assert
        verify(mockPrefs.setString('auth_token', validToken)).called(1);
        verify(mockPrefs.setString('refresh_token', refreshToken)).called(1);
        verify(mockPrefs.setString('user_data', jsonEncode(userData)))
            .called(1);
        verify(mockPrefs.setBool('email_verified', true)).called(1);
        verify(mockPrefs.setInt('token_expiry', any)).called(1);
      });

      test('should handle exceptions when saving auth data', () async {
        // Arrange
        when(mockPrefs.setString(any, any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => authManager.saveAuthData(
            token: validToken,
            refreshToken: refreshToken,
            userData: userData,
          ),
          throwsException,
        );
      });
    });

    group('getToken & getRefreshToken', () {
      test('should retrieve token and refresh token', () {
        // Arrange
        when(mockPrefs.getString('auth_token')).thenReturn(validToken);
        when(mockPrefs.getString('refresh_token')).thenReturn(refreshToken);

        // Act
        final token = authManager.getToken();
        final retrievedRefreshToken = authManager.getRefreshToken();

        // Assert
        expect(token, equals(validToken));
        expect(retrievedRefreshToken, equals(refreshToken));
      });

      test('should return null when tokens are not stored', () {
        // Arrange
        when(mockPrefs.getString('auth_token')).thenReturn(null);
        when(mockPrefs.getString('refresh_token')).thenReturn(null);

        // Act
        final token = authManager.getToken();
        final retrievedRefreshToken = authManager.getRefreshToken();

        // Assert
        expect(token, isNull);
        expect(retrievedRefreshToken, isNull);
      });
    });

    group('getUserData', () {
      test('should retrieve and parse user data correctly', () {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(userData));

        // Act
        final retrievedUserData = authManager.getUserData();

        // Assert
        expect(retrievedUserData, equals(userData));
      });

      test('should return null when user data is not stored', () {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(null);

        // Act
        final retrievedUserData = authManager.getUserData();

        // Assert
        expect(retrievedUserData, isNull);
      });

      test('should handle invalid JSON when retrieving user data', () {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn('invalid-json');

        // Act
        final retrievedUserData = authManager.getUserData();

        // Assert
        expect(retrievedUserData, isNull);
      });
    });

    group('getUserDataField', () {
      test('should retrieve specific user data field with type safety', () {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(userData));

        // Act
        final userId = authManager.getUserDataField<String>('id');
        final isVerified =
            authManager.getUserDataField<bool>('isEmailVerified');

        // Assert
        expect(userId, equals('user123'));
        expect(isVerified, isTrue);
      });

      test('should return null for non-existent field', () {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(userData));

        // Act
        final nonExistentField =
            authManager.getUserDataField<String>('nonExistent');

        // Assert
        expect(nonExistentField, isNull);
      });

      test('should return null when type doesn\'t match', () {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(userData));

        // Act
        final idAsInt = authManager.getUserDataField<int>('id');

        // Assert
        expect(idAsInt, isNull);
      });
    });

    group('isEmailVerified', () {
      test('should return email verification status', () {
        // Arrange
        when(mockPrefs.getBool('email_verified')).thenReturn(true);

        // Act & Assert
        expect(authManager.isEmailVerified(), isTrue);
      });

      test('should return false when email verification status is not stored',
          () {
        // Arrange
        when(mockPrefs.getBool('email_verified')).thenReturn(null);

        // Act & Assert
        expect(authManager.isEmailVerified(), isFalse);
      });
    });

    group('getTokenExpiry', () {
      test('should retrieve token expiry from stored timestamp', () {
        // Arrange
        final now = DateTime.now();
        final expiryTimestamp =
            (now.millisecondsSinceEpoch / 1000).round() + 3600;

        when(mockPrefs.getInt('token_expiry')).thenReturn(expiryTimestamp);

        // Act
        final expiry = authManager.getTokenExpiry();

        // Assert
        expect(expiry!.isAfter(now.add(const Duration(minutes: 59))), isTrue);
        expect(expiry.isBefore(now.add(const Duration(minutes: 61))), isTrue);
      });

      test('should extract expiry from token when timestamp is not stored', () {
        // Arrange
        when(mockPrefs.getInt('token_expiry')).thenReturn(null);
        when(mockPrefs.getString('auth_token')).thenReturn(validToken);

        // Act
        final expiry = authManager.getTokenExpiry();

        // Assert
        expect(expiry, isNotNull);
        expect(expiry!.isAfter(DateTime.now()), isTrue);
      });

      test('should return null when no expiry information is available', () {
        // Arrange
        when(mockPrefs.getInt('token_expiry')).thenReturn(null);
        when(mockPrefs.getString('auth_token')).thenReturn(null);

        // Act
        final expiry = authManager.getTokenExpiry();

        // Assert
        expect(expiry, isNull);
      });
    });

    group('willTokenExpireSoon', () {
      test('should return true when token expires in less than 10 minutes', () {
        // Arrange
        final now = DateTime.now();
        final expiryTimestamp =
            (now.millisecondsSinceEpoch / 1000).round() + 300; // 5 minutes

        when(mockPrefs.getInt('token_expiry')).thenReturn(expiryTimestamp);

        // Act & Assert
        expect(authManager.willTokenExpireSoon(), isTrue);
      });

      test('should return false when token expires in more than 10 minutes',
          () {
        // Arrange
        final now = DateTime.now();
        final expiryTimestamp =
            (now.millisecondsSinceEpoch / 1000).round() + 900; // 15 minutes

        when(mockPrefs.getInt('token_expiry')).thenReturn(expiryTimestamp);

        // Act & Assert
        expect(authManager.willTokenExpireSoon(), isFalse);
      });

      test('should return true when no expiry information is available', () {
        // Arrange
        when(mockPrefs.getInt('token_expiry')).thenReturn(null);
        when(mockPrefs.getString('auth_token')).thenReturn(null);

        // Act & Assert
        expect(authManager.willTokenExpireSoon(), isTrue);
      });
    });

    group('hasValidToken', () {
      test('should return true for valid non-expired token', () {
        // Arrange
        when(mockPrefs.getString('auth_token')).thenReturn(validToken);

        // Act & Assert
        expect(authManager.hasValidToken(), isTrue);
      });

      test('should return false for expired token', () {
        // Arrange
        when(mockPrefs.getString('auth_token')).thenReturn(expiredToken);

        // Act & Assert
        expect(authManager.hasValidToken(), isFalse);
      });

      test('should return false when token is not available', () {
        // Arrange
        when(mockPrefs.getString('auth_token')).thenReturn(null);

        // Act & Assert
        expect(authManager.hasValidToken(), isFalse);
      });

      test('should return false for invalid token format', () {
        // Arrange
        when(mockPrefs.getString('auth_token')).thenReturn('invalid-token');

        // Act & Assert
        expect(authManager.hasValidToken(), isFalse);
      });
    });

    group('clearAuthData', () {
      test('should clear all auth data', () async {
        // Arrange
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await authManager.clearAuthData();

        // Assert
        verify(mockPrefs.remove('auth_token')).called(1);
        verify(mockPrefs.remove('refresh_token')).called(1);
        verify(mockPrefs.remove('user_data')).called(1);
        verify(mockPrefs.remove('email_verified')).called(1);
        verify(mockPrefs.remove('token_expiry')).called(1);
      });

      test('should handle exceptions when clearing auth data', () async {
        // Arrange
        when(mockPrefs.remove(any)).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(() => authManager.clearAuthData(), throwsException);
      });
    });

    group('updateTokensAfterRefresh', () {
      test('should update tokens and expiry after refresh', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setInt(any, any)).thenAnswer((_) async => true);

        final newToken = createSampleJWT(
          expiryInSeconds: 7200, // 2 hours in future
          payload: {'sub': 'test-user', 'email': 'test@example.com'},
        );
        const newRefreshToken = 'new-refresh-token-67890';

        // Act
        await authManager.updateTokensAfterRefresh(newToken, newRefreshToken);

        // Assert
        verify(mockPrefs.setString('auth_token', newToken)).called(1);
        verify(mockPrefs.setString('refresh_token', newRefreshToken)).called(1);
        verify(mockPrefs.setInt('token_expiry', any)).called(1);
      });

      test('should handle invalid token format during update', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        const invalidToken = 'invalid-token';
        const newRefreshToken = 'new-refresh-token-67890';

        // Act
        await authManager.updateTokensAfterRefresh(
            invalidToken, newRefreshToken);

        // Assert
        verify(mockPrefs.setString('auth_token', invalidToken)).called(1);
        verify(mockPrefs.setString('refresh_token', newRefreshToken)).called(1);
        verifyNever(mockPrefs.setInt('token_expiry', any));
      });
    });

    group('updateEmailVerificationStatus', () {
      test('should update email verification status and user data', () async {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(jsonEncode(userData));
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);

        // Act
        await authManager.updateEmailVerificationStatus(false);

        // Assert
        verify(mockPrefs.setBool('email_verified', false)).called(1);

        // Verify user data was updated with new verification status
        final Map<String, dynamic> updatedUserData = Map.from(userData);
        updatedUserData['isEmailVerified'] = false;
        verify(mockPrefs.setString('user_data', jsonEncode(updatedUserData)))
            .called(1);
      });

      test('should handle missing user data during email verification update',
          () async {
        // Arrange
        when(mockPrefs.getString('user_data')).thenReturn(null);

        // Act
        await authManager.updateEmailVerificationStatus(true);

        // Assert
        verifyNever(mockPrefs.setBool('email_verified', any));
        verifyNever(mockPrefs.setString('user_data', any));
      });
    });
  });
}

String createSampleJWT(
    {required int expiryInSeconds, required Map<String, dynamic> payload}) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final header = {'alg': 'HS256', 'typ': 'JWT'};

  final jwtPayload = {
    ...payload,
    'iat': now,
    'exp': now + expiryInSeconds,
  };

  final encodedHeader =
      base64Url.encode(utf8.encode(jsonEncode(header))).replaceAll('=', '');
  final encodedPayload =
      base64Url.encode(utf8.encode(jsonEncode(jwtPayload))).replaceAll('=', '');
  final signature =
      base64Url.encode(utf8.encode('dummy-signature')).replaceAll('=', '');

  return '$encodedHeader.$encodedPayload.$signature';
}
