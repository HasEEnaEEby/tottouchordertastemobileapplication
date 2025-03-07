import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;

  Future<bool> checkConnectivityWithTimeout({Duration timeout});
  Future<void> waitForConnection({Duration? timeout, Duration checkInterval});

  void dispose();
}

class NetworkInfoImpl implements NetworkInfo {
  /// The internet connection checker
  final InternetConnectionChecker connectionChecker;

  /// Broadcast controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();

  /// Subscription to connection status changes
  StreamSubscription? _subscription;

  /// Timer for periodic connection checks
  Timer? _periodicCheck;

  /// Constructor initializes connectivity listener and periodic checks
  NetworkInfoImpl(this.connectionChecker) {
    _initConnectivityListener();
    _startPeriodicCheck();
  }

  /// Sets up a listener for connectivity status changes
  void _initConnectivityListener() {
    _subscription = connectionChecker.onStatusChange.listen((status) {
      final isConnected = status == InternetConnectionStatus.connected;
      _connectivityController.add(isConnected);
    });
  }

  /// Starts a periodic check of internet connectivity
  void _startPeriodicCheck() {
    _periodicCheck = Timer.periodic(const Duration(seconds: 30), (_) async {
      final connection = await isConnected;
      if (!_connectivityController.isClosed) {
        _connectivityController.add(connection);
      }
    });
  }

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;

  @override
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  @override
  Future<bool> checkConnectivityWithTimeout({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      return await connectionChecker.hasConnection
          .timeout(timeout, onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> waitForConnection({
    Duration? timeout,
    Duration checkInterval = const Duration(seconds: 1),
  }) async {
    final startTime = DateTime.now();

    while (!(await isConnected)) {
      if (timeout != null && DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Connection timeout');
      }
      await Future.delayed(checkInterval);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _periodicCheck?.cancel();
    _connectivityController.close();
  }
}

/// Custom network-related exceptions
class NetworkException implements Exception {
  /// Error message
  final String message;

  /// Optional duration associated with the exception
  final Duration? duration;

  /// Constructor
  const NetworkException(this.message, {this.duration});

  @override
  String toString() =>
      'NetworkException: $message${duration != null ? ' (Duration: $duration)' : ''}';
}

/// Timeout exception for network operations
class TimeoutException extends NetworkException {
  /// Constructor
  TimeoutException(super.message);
}

/// Exception for no internet connection
class NoInternetException extends NetworkException {
  /// Constructor with optional custom message
  NoInternetException([super.message = 'No internet connection available']);
}

/// Extension methods for NetworkInfo
extension NetworkInfoX on NetworkInfo {
  /// Performs an operation with connection checking
  Future<T> withConnection<T>({
    required Future<T> Function() onConnected,
    Future<T> Function()? onNotConnected,
    Duration? timeout,
  }) async {
    try {
      if (timeout != null) {
        final hasConnection =
            await checkConnectivityWithTimeout(timeout: timeout);
        if (!hasConnection) {
          if (onNotConnected != null) {
            return onNotConnected();
          }
          throw TimeoutException(
              'Connection timeout after ${timeout.inSeconds} seconds');
        }
      } else {
        final isConnected = await this.isConnected;
        if (!isConnected) {
          if (onNotConnected != null) {
            return onNotConnected();
          }
          throw NoInternetException();
        }
      }
      return onConnected();
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException('Error checking connection: $e');
    }
  }
}

/// Helper class for network-related UI and utility methods
class NetworkHelper {
  /// Default timeout duration
  static const Duration defaultTimeout = Duration(seconds: 10);

  /// Default retry interval
  static const Duration defaultRetryInterval = Duration(seconds: 2);

  /// Shows a no internet connection dialog
  static Future<void> showNoInternetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Checks internet connectivity with optional user feedback
  static Future<bool> checkInternetWithFeedback(
    BuildContext context, {
    bool showDialog = true,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      final networkInfo = GetIt.instance<NetworkInfo>();
      final isConnected = await networkInfo.checkConnectivityWithTimeout(
        timeout: timeout,
      );

      if (!isConnected && showDialog) {
        if (context.mounted) {
          await showNoInternetDialog(context);
        }
      }
      return isConnected;
    } catch (e) {
      return false;
    }
  }

  /// Waits for internet connection with optional user feedback
  static Future<bool> waitForInternetWithFeedback(
    BuildContext context, {
    Duration? timeout,
    Duration retryInterval = defaultRetryInterval,
    bool showDialog = true,
  }) async {
    try {
      final networkInfo = GetIt.instance<NetworkInfo>();
      await networkInfo.waitForConnection(
        timeout: timeout,
        checkInterval: retryInterval,
      );
      return true;
    } on TimeoutException {
      if (showDialog && context.mounted) {
        await showNoInternetDialog(context);
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Singleton instance for dependency injection
final getIt = GetIt.instance;

/// Initialize network-related dependencies
Future<void> initNetwork() async {
  final connectionChecker = InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 5),
    checkInterval: const Duration(seconds: 30),
  );

  if (!getIt.isRegistered<InternetConnectionChecker>()) {
    getIt.registerSingleton<InternetConnectionChecker>(connectionChecker);
  }
}
