import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';

// State class for proximity
class ProximityState {
  final bool isNear;

  ProximityState({required this.isNear});

  @override
  String toString() => 'ProximityState(isNear: $isNear)';
}

/// A Cubit that manages the global proximity state throughout the app
class ProximityCubit extends Cubit<ProximityState> {
  final SensorManager _sensorManager;
  final Logger _logger = Logger('ProximityCubit');

  ProximityCubit()
      : _sensorManager = GetIt.instance<SensorManager>(),
        super(ProximityState(isNear: false)) {
    _initialize();
  }

  /// Initialize the proximity listener
  void _initialize() {
    _logger.info('Initializing proximity cubit');
    _sensorManager.proximitySensorService.addListener(_onProximityChanged);

    // Start listening to proximity changes
    _sensorManager.proximitySensorService.startListening();
  }

  /// Handle proximity change events
  void _onProximityChanged(bool isNear) {
    _logger.info('📱 Proximity state changed: ${isNear ? 'NEAR' : 'FAR'}');
    emit(ProximityState(isNear: isNear));
  }

  /// Start proximity sensing
  void startProximitySensing() {
    _logger.info('Starting proximity sensing');
    _sensorManager.proximitySensorService.startListening();
  }

  /// Stop proximity sensing
  void stopProximitySensing() {
    _logger.info('Stopping proximity sensing');
    _sensorManager.proximitySensorService.stopListening();
  }

  /// Toggle proximity-activated feature (e.g., auto-mute, auto-dim)
  /// Returns true if the feature is now enabled, false if disabled
  bool toggleProximityFeature(String featureKey, bool currentValue) {
    final newValue = !currentValue;
    _logger.info('Toggling proximity feature $featureKey to $newValue');
    return newValue;
  }

  @override
  Future<void> close() {
    _logger.info('Closing proximity cubit');
    _sensorManager.proximitySensorService.removeListener(_onProximityChanged);
    _sensorManager.proximitySensorService.stopListening();
    return super.close();
  }
}
