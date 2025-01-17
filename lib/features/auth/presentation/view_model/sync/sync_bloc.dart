import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {}

class SyncSuccess extends SyncState {}

class SyncFailure extends SyncState {
  final String error;
  SyncFailure(this.error);
}

abstract class SyncEvent {}

class StartSync extends SyncEvent {}

class ConnectivityChanged extends SyncEvent {
  final bool isConnected;
  ConnectivityChanged(this.isConnected);
}

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
    on<StartSync>(_onStartSync);
    on<ConnectivityChanged>(_onConnectivityChanged);

    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      (isConnected) => add(ConnectivityChanged(isConnected)),
    );
  }

  Future<void> _onStartSync(StartSync event, Emitter<SyncState> emit) async {
    emit(SyncInProgress());
    try {
      await _syncService.syncPendingItems();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(e.toString()));
    }
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<SyncState> emit,
  ) async {
    if (event.isConnected) {
      add(StartSync());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
