import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request Camera Permission (Best Practice)
  static Future<bool> requestCameraPermission(BuildContext context) async {
    debugPrint('Checking camera permission...');

    PermissionStatus status = await Permission.camera.status;
    debugPrint('Initial Camera Permission Status: $status');

    if (status.isGranted) {
      debugPrint('✅ Camera permission already granted.');
      return true;
    }

    if (status.isDenied) {
      debugPrint('📌 Camera permission denied, requesting again...');
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      debugPrint('⛔ Camera permission permanently denied.');
      _showPermissionSettingsDialog(
        context,
        title: 'Camera Permission Required',
        message:
            'Camera access is required to scan QR codes. Please enable it in Settings.',
      );
      return false;
    }

    return status.isGranted;
  }

  /// Show a Permission Explanation Dialog Before Requesting
  static void showPermissionExplanation(
      BuildContext context, VoidCallback onRequest) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Access Needed'),
        content: const Text(
            'We need camera access to scan QR codes for table ordering. Please allow camera access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRequest(); // Proceed with requesting permission
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  /// Show a "Go to Settings" Dialog if Permission is Permanently Denied
  static void _showPermissionSettingsDialog(BuildContext context,
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings(); // Opens app settings for manual enable
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Request Location Permission (Same Pattern)
  static Future<bool> requestLocationPermission(BuildContext context) async {
    debugPrint('Checking location permission...');

    PermissionStatus status = await Permission.location.status;
    debugPrint('Initial Location Permission Status: $status');

    if (status.isGranted) {
      debugPrint('✅ Location permission already granted.');
      return true;
    }

    if (status.isDenied) {
      debugPrint('📌 Location permission denied, requesting again...');
      status = await Permission.location.request();
    }

    if (status.isPermanentlyDenied) {
      debugPrint('⛔ Location permission permanently denied.');
      _showPermissionSettingsDialog(
        context,
        title: 'Location Permission Required',
        message:
            'Location access is needed for restaurant services. Please enable it in Settings.',
      );
      return false;
    }

    return status.isGranted;
  }

  /// Detect if Running on iOS Simulator (For Mocking Camera Access)
  static bool isIOSSimulator() {
    if (!Platform.isIOS) return false;

    try {
      final env = Platform.environment;
      return env.containsKey('SIMULATOR_DEVICE_NAME') ||
          env.containsKey('SIMULATOR_HOST_HOME');
    } catch (e) {
      debugPrint('Error detecting iOS simulator: $e');
      return false;
    }
  }
}
