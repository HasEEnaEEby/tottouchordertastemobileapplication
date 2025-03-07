import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class ProximitySensorService {
  StreamSubscription<int>? _proximitySubscription;
  bool _isNear = false;
  final List<Function(bool)> _listeners = [];

  bool get isNear => _isNear;

  void startListening() {
    if (_proximitySubscription != null) return;

    _proximitySubscription = ProximitySensor.events.listen((int event) {

      final bool isNear = event > 0;

      if (_isNear != isNear) {
        _isNear = isNear;
        _notifyListeners();
        debugPrint("Proximity changed: ${isNear ? 'NEAR' : 'FAR'}");
      }
    });

    debugPrint("Proximity sensor listening started");
  }

  void stopListening() {
    _proximitySubscription?.cancel();
    _proximitySubscription = null;
    debugPrint("Proximity sensor listening stopped");
  }

  void addListener(Function(bool) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(bool) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_isNear);
    }
  }
  bool isListening() {
    return _proximitySubscription != null;
  }

  void dispose() {
    stopListening();
    _listeners.clear();
  }
}
