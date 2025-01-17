import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async => await connectionChecker.hasConnection;

  @override
  Stream<bool> get onConnectivityChanged =>
      connectionChecker.onStatusChange.map(
        (status) => status == InternetConnectionStatus.connected,
      );

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
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class NoInternetException implements Exception {
  final String message;

  NoInternetException([this.message = 'No internet connection available']);

  @override
  String toString() => 'NoInternetException: $message';
}

extension NetworkInfoX on NetworkInfo {
  Future<T> withConnection<T>({
    required Future<T> Function() onConnected,
    Future<T> Function()? onNotConnected,
    Duration? timeout,
  }) async {
    final isConnected = await this.isConnected;
    if (isConnected) {
      return onConnected();
    } else if (onNotConnected != null) {
      return onNotConnected();
    } else {
      throw NoInternetException();
    }
  }
}

class NetworkHelper {
  static Future<void> showNoInternetDialog(context) async {}

  static Future<bool> checkInternetWithFeedback(
    context, {
    bool showDialog = true,
  }) async {
    final networkInfo = GetIt.instance<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;

    if (!isConnected && showDialog) {
      await showNoInternetDialog(context);
    }
    return isConnected;
  }
}

final getIt = GetIt.instance;

Future<void> init() async {
  final connectionChecker = InternetConnectionChecker();
  getIt.registerSingleton<InternetConnectionChecker>(connectionChecker);

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<InternetConnectionChecker>()),
  );
}
