import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  // Check if biometric authentication is available on the device
  Future<bool> isDeviceSupportedBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      final availableBiometrics =
          await _localAuthentication.getAvailableBiometrics();

      debugPrint('Biometric Support:');
      debugPrint('- Can Check Biometrics: $canCheckBiometrics');
      debugPrint('- Available Biometrics: $availableBiometrics');

      return canCheckBiometrics && availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Biometric Check Error: $e');
      return false;
    }
  }

  // Retrieve available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuthentication.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate user with biometrics
  Future<bool> authenticateUser({
    String localizedReason = 'Please authenticate to proceed',
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      // First check if biometrics is supported
      if (!await isDeviceSupportedBiometrics()) {
        return false;
      }

      return await _localAuthentication.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
          ),
          const IOSAuthMessages(
            // Remove lockoutTitle
            goToSettingsButton: 'Settings',
            goToSettingsDescription: 'Please set up biometric authentication',
            cancelButton: 'Cancel',
          ),
        ],
      );
    } on PlatformException {
      return false;
    }
  }
}
