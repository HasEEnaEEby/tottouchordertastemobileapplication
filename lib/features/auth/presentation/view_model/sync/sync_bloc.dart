import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';

// Logging setup
final _logger = Logger('SyncBloc');

// Sync States
abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {
  final SyncStatus? status;
  SyncSuccess({this.status});
}

class SyncFailure extends SyncState {
  final String error;
  final SyncStatus? status;
  SyncFailure(this.error, {this.status});
}

// Sync Events
abstract class SyncEvent {}

class StartSync extends SyncEvent {}

class ConnectivityChanged extends SyncEvent {
  final bool isConnected;
  ConnectivityChanged(this.isConnected);
}

class RetryFailedSyncs extends SyncEvent {}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncService _syncService;
  final NetworkInfo _networkInfo;
  StreamSubscription? _connectivitySubscription;

  SyncBloc({
    required SyncService syncService,
    required NetworkInfo networkInfo,
  })  : _syncService = syncService,
        _networkInfo = networkInfo,
        super(SyncInitial()) {
    // Register event handlers
    on<StartSync>(_onStartSync);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<RetryFailedSyncs>(_onRetryFailedSyncs);

    // Listen to connectivity changes
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      (isConnected) => add(ConnectivityChanged(isConnected)),
    );
  }

  // Start sync method
  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());
    try {
      // Log pending items before sync
      final pendingItems = await _syncService.getPendingSyncs();
      _logger.info('Pending Sync Items: ${pendingItems.length}');

      // Perform sync
      await _syncService.syncPendingItems();

      // Get final sync status
      final status = await _syncService.getSyncStatus();

      emit(SyncSuccess(status: status));
    } catch (e) {
      _logger.severe('Sync Error', e);

      // Get sync status even if sync failed
      final status = await _syncService.getSyncStatus();
      emit(SyncFailure(e.toString(), status: status));
    }
  }

  // Handle connectivity changes
  Future<void> _onConnectivityChanged(
      ConnectivityChanged event, Emitter<SyncState> emit) async {
    if (event.isConnected) {
      _logger.info('Network connected, initiating sync');
      add(StartSync());
    }
  }

  // Retry failed syncs
  Future<void> _onRetryFailedSyncs(
      RetryFailedSyncs event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());
    try {
      await _syncService.retryFailedSyncs();

      // Get final sync status
      final status = await _syncService.getSyncStatus();

      emit(SyncSuccess(status: status));
    } catch (e) {
      _logger.severe('Failed Sync Retry', e);

      // Get sync status even if retry failed
      final status = await _syncService.getSyncStatus();
      emit(SyncFailure(e.toString(), status: status));
    }
  }

  // Cleanup resources
  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
