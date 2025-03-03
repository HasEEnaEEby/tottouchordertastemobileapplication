import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class ProximitySensorService {
  StreamSubscription<int>? _proximitySubscription;
  bool _isNear = false;
  final List<Function(bool)> _listeners = [];

  // Get the current proximity state
  bool get isNear => _isNear;

  // Start listening to proximity sensor events
  void startListening() {
    if (_proximitySubscription != null) return;

    _proximitySubscription = ProximitySensor.events.listen((int event) {
      // In proximity sensors, 0 typically means far and non-zero means near
      final bool isNear = event > 0;

      if (_isNear != isNear) {
        _isNear = isNear;
        _notifyListeners();
        debugPrint("Proximity changed: ${isNear ? 'NEAR' : 'FAR'}");
      }
    });

    debugPrint("Proximity sensor listening started");
  }

  // Stop listening to proximity sensor events
  void stopListening() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
    debugPrint("Proximity sensor listening stopped");
  }

  // Add a listener to be notified of proximity changes
  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  // Remove a previously added listener
  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners of proximity changes
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_isNear);
    }
  }

  // Dispose resources when service is no longer needed
  void dispose() {
    stopListening();
    _listeners.clear();
  }
}
