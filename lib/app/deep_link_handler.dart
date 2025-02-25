import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:uni_links2/uni_links.dart';

import '../../features/auth/presentation/view/verify_email_view.dart';

class DeepLinkHandler {
  static final Logger _logger = Logger('DeepLinkHandler');
  static StreamSubscription? _linkSubscription;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isInitialized = false;

  static Future<void> init({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    // Prevent multiple initializations
    if (_isInitialized) return;

    try {
      _navigatorKey = navigatorKey;
      _isInitialized = true;

      // Handle any initial deep link
      await _handleInitialLink();

      // Start listening for incoming links
      _startLinkListener();

      _logger.info('Deep Link Handler initialized successfully');
    } catch (e, stackTrace) {
      _logger.severe('Failed to initialize DeepLinkHandler', e, stackTrace);
      developer.log(
        'Deep Link Initialization Error',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Start listening to incoming links
  static void _startLinkListener() {
    try {
      _linkSubscription = uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri);
          }
        },
        onError: (error) {
          _logger.warning('Deep link stream error', error);
          developer.log(
            'Deep Link Stream Error',
            error: error,
          );
        },
        cancelOnError: false,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error setting up link listener', e, stackTrace);
      developer.log(
        'Deep Link Listener Setup Error',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Handle initial link when app starts
  static Future<void> _handleInitialLink() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _logger.info('Initial deep link found: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (e, stackTrace) {
      _logger.warning('Error handling initial link', e, stackTrace);
      developer.log(
        'Initial Deep Link Handling Error',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Process incoming deep links
  static void _handleDeepLink(Uri uri) {
    _logger.info('Received deep link: $uri');
    developer.log(
      'Deep Link Received',
      error: uri.toString(),
    );

    // Check for verification links
    if (_isVerificationLink(uri)) {
      // Extract token from the link
      final token = _extractToken(uri);

      // Extract email if available
      final email = uri.queryParameters['email'];

      if (token != null) {
        _navigateToVerifyEmail(token, email);
      } else {
        _logger.warning('No token found in deep link');
      }
    } else {
      _logger
          .info('Unhandled deep link scheme/host: ${uri.scheme}://${uri.host}');
    }
  }

  // Check if the URI is a verification link
  static bool _isVerificationLink(Uri uri) {
    // Handle tot:// scheme
    if (uri.scheme == 'tot' && uri.host == 'verify-email') {
      return true;
    }

    // Handle localhost http links
    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host == 'localhost' &&
        uri.path.contains('/verify-email')) {
      return true;
    }

    return false;
  }

  // Extract verification token from URI
  static String? _extractToken(Uri uri) {
    try {
      // For tot:// scheme
      if (uri.scheme == 'tot') {
        // Try extracting token from path segments
        if (uri.pathSegments.length > 1) {
          return uri.pathSegments[1];
        }

        // Try extracting from query parameters
        return uri.queryParameters['token'];
      }

      // For localhost links
      if ((uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host == 'localhost') {
        // Try extracting from path segments
        final pathSegments = uri.pathSegments;
        final verifyIndex = pathSegments.indexOf('verify-email');
        if (verifyIndex != -1 && verifyIndex + 1 < pathSegments.length) {
          return pathSegments[verifyIndex + 1];
        }

        // Try extracting from query parameters
        return uri.queryParameters['token'];
      }

      return null;
    } catch (e) {
      _logger.warning('Error extracting token', e);
      return null;
    }
  }

  // Navigate to email verification screen
  static void _navigateToVerifyEmail(String token, String? email) {
    if (_navigatorKey?.currentState != null) {
      _navigatorKey!.currentState!.push(
        MaterialPageRoute(
          builder: (_) => VerifyEmailView(
            token: token,
            email: email ?? '',
          ),
        ),
      );
    } else {
      _logger.warning('Unable to navigate - navigator key is null');
      developer.log(
        'Navigation Failed',
        error: 'Navigator key is null',
      );
    }
  }

  // Cleanup method
  static void dispose() {
    _linkSubscription?.cancel();
    _navigatorKey = null;
    _isInitialized = false;
  }
}
