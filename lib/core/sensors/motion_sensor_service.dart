import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MotionSensorService {
  // Sensor stream subscriptions
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Current sensor values
  AccelerometerEvent? _currentAccelerometer;
  GyroscopeEvent? _currentGyroscope;
  MagnetometerEvent? _currentMagnetometer;

  // Sensor event listeners
  final List<Function(AccelerometerEvent)> _accelerometerListeners = [];
  final List<Function(GyroscopeEvent)> _gyroscopeListeners = [];
  final List<Function(MagnetometerEvent)> _magnetometerListeners = [];

  static const double _shakeThreshold = 15.0;
  static const double _rotationThreshold = 3.5;
  static const Duration _shakeCooldown = Duration(milliseconds: 1500);

  // Shake and rotation tracking
  DateTime? _lastShakeTime;
  final List<Function()> _shakeListeners = [];
  final List<Function(GyroscopeEvent)> _rotationListeners = [];

  // Audio configuration
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  static const String _shakeSoundPath =
      'assets/sounds/french-elegance-288828.mp3';

  // Shake detection parameters
  double _lastAccelerationMagnitude = 0.0;

  // Proximity state tracking
  bool _isProximityNear = false;

  // Logging and debugging
  bool _isDebugMode = true; // Set to true by default for better debugging

  MotionSensorService({bool debugMode = true}) {
    _isDebugMode = debugMode;
    _initializeAudio();
  }

  void handleProximityChange(bool isNear) {
    bool previousState = _isProximityNear;
    _isProximityNear = isNear;

    _debugPrint(
        "📱 Motion service received proximity change: ${isNear ? 'NEAR' : 'FAR'}");

    // If proximity becomes near and audio is playing, stop it
    if (isNear && !previousState) {
      if (_audioPlayer.playing) {
        _debugPrint(
            "📱 Proximity near detected while audio playing - stopping sound");
        _audioPlayer
            .stop(); // Use stop instead of pause to fully terminate playback
      }
    }
  }

  Future<void> _initializeAudio() async {
    try {
      _debugPrint('🔊 Starting audio initialization: $_shakeSoundPath');

      // Configure audio source with comprehensive error handling
      await _audioPlayer.setAudioSource(
        AudioSource.asset(_shakeSoundPath),
        initialPosition: Duration.zero,
        preload: true,
      );

      // Configure additional audio settings
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setSpeed(1.0);

      _debugPrint('🔊 Audio initialized successfully: $_shakeSoundPath');
    } catch (e) {
      _debugPrint('❌ Audio initialization error: $e');

      // Try alternative initialization
      try {
        _debugPrint('🔄 Trying alternative method to load audio...');
        await _audioPlayer.setAsset(_shakeSoundPath);
        _debugPrint('✅ Alternative audio loading succeeded');
      } catch (altError) {
        _debugPrint('❌ Alternative loading failed: $altError');
      }
    }
  }

  // Enhanced debug printing
  void _debugPrint(String message) {
    if (_isDebugMode) {
      debugPrint(message);
    }
  }

  // Start sensor listening with comprehensive event handling
  void startListening() {
    if (isListening()) return;

    // Accelerometer event handling
    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _currentAccelerometer = event;

        // Enhanced shake detection
        if (_detectShake(event)) {
          _notifyShakeDetected();
        }

        // Notify accelerometer listeners
        for (var listener in _accelerometerListeners) {
          listener(event);
        }
      },
      onError: (error) => _debugPrint('🚨 Accelerometer error: $error'),
      cancelOnError: false,
    );

    // Gyroscope event handling
    _gyroscopeSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        _currentGyroscope = event;

        // Rotation detection
        if (_detectSignificantRotation(event)) {
          _notifySignificantRotation(event);
        }

        // Notify gyroscope listeners
        for (var listener in _gyroscopeListeners) {
          listener(event);
        }
      },
      onError: (error) => _debugPrint('🚨 Gyroscope error: $error'),
      cancelOnError: false,
    );

    // Magnetometer event handling
    _magnetometerSubscription = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        _currentMagnetometer = event;

        // Notify magnetometer listeners
        for (var listener in _magnetometerListeners) {
          listener(event);
        }
      },
      onError: (error) => _debugPrint('🚨 Magnetometer error: $error'),
      cancelOnError: false,
    );

    _debugPrint("🌐 Motion sensor listening started");
  }

  // Stop sensor listening
  void stopListening() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _magnetometerSubscription?.cancel();

    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _magnetometerSubscription = null;

    _debugPrint("🛑 Motion sensor listening stopped");
  }

  // Check if sensors are currently listening
  bool isListening() {
    return _accelerometerSubscription != null ||
        _gyroscopeSubscription != null ||
        _magnetometerSubscription != null;
  }

  // Enhanced shake detection algorithm
  bool _detectShake(AccelerometerEvent event) {
    // Check cooldown to prevent rapid successive shake detections
    if (_lastShakeTime != null &&
        DateTime.now().difference(_lastShakeTime!) < _shakeCooldown) {
      return false;
    }

    // Calculate acceleration magnitude using Pythagorean theorem
    final currentAccelerationMagnitude =
        math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    // Detect significant change in acceleration
    final accelerationChange =
        (currentAccelerationMagnitude - _lastAccelerationMagnitude).abs();
    _lastAccelerationMagnitude = currentAccelerationMagnitude;

    // Check if acceleration exceeds threshold and shows significant change
    if (currentAccelerationMagnitude > _shakeThreshold &&
        accelerationChange > 5.0) {
      _lastShakeTime = DateTime.now();
      _debugPrint(
          '🤝 Shake detected! Acceleration: $currentAccelerationMagnitude');
      return true;
    }
    return false;
  }

  // Rotation detection logic
  bool _detectSignificantRotation(GyroscopeEvent event) {
    final rotationRate =
        math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    return rotationRate > _rotationThreshold;
  }

  Future<void> playShakeSound() async {
    // Check proximity first - don't play sound if device is near face/pocket
    if (_isProximityNear) {
      _debugPrint("📱 Proximity is near - not playing shake sound");
      return;
    }

    if (!_isSoundEnabled) {
      _debugPrint("🔇 Sound is disabled");
      return;
    }

    try {
      _debugPrint("🔊 Attempting to play shake sound");

      // Check if audio is initialized
      if (_audioPlayer.audioSource == null) {
        _debugPrint("🔄 Audio source not initialized, reinitializing...");
        await _initializeAudio();
      }

      // Stop any current playback
      await _audioPlayer.stop();

      // Reset to start
      await _audioPlayer.seek(Duration.zero);

      // Play sound
      await _audioPlayer.play();
      _debugPrint("✅ Shake sound playing");
    } catch (e) {
      _debugPrint('❌ Sound playback error: $e');

      // Try to reinitialize audio on error
      _debugPrint('🔄 Attempting to reinitialize audio...');
      try {
        await _initializeAudio();
      } catch (reinitError) {
        _debugPrint('❌ Audio reinitialization failed: $reinitError');
      }
    }
  }

  // Shake listener management
  void addShakeListener(Function() listener) {
    _shakeListeners.add(listener);
  }

  void removeShakeListener(Function() listener) {
    _shakeListeners.remove(listener);
  }

  void _notifyShakeDetected() {
    _debugPrint("🤝 Shake detected! About to play sound");

    // Play sound asynchronously
    playShakeSound().then((_) {
      _debugPrint("✅ Sound played successfully");
    }).catchError((error) {
      _debugPrint('❌ Shake sound error: $error');
    });

    // Notify all shake listeners
    for (var listener in _shakeListeners) {
      _debugPrint("🔔 Calling shake listener");
      listener();
    }
  }

  // Rotation listener management
  void addRotationListener(Function(GyroscopeEvent) listener) {
    _rotationListeners.add(listener);
  }

  void removeRotationListener(Function(GyroscopeEvent) listener) {
    _rotationListeners.remove(listener);
  }

  // Internal rotation notification
  void _notifySignificantRotation(GyroscopeEvent event) {
    _debugPrint("🔄 Significant rotation detected!");
    for (var listener in _rotationListeners) {
      listener(event);
    }
  }

  // Sensor value getters
  AccelerometerEvent? get currentAccelerometer => _currentAccelerometer;
  GyroscopeEvent? get currentGyroscope => _currentGyroscope;
  MagnetometerEvent? get currentMagnetometer => _currentMagnetometer;

  // Sound control methods
  bool get isSoundEnabled => _isSoundEnabled;

  void enableSound() {
    _isSoundEnabled = true;
    _debugPrint("🔊 Sound enabled");
  }

  void disableSound() {
    _isSoundEnabled = false;
    _debugPrint("🔇 Sound disabled");
  }

  // Check if audio is currently playing
  bool get isAudioPlaying => _audioPlayer.playing;

  // Resource cleanup
  void dispose() {
    // Stop listening to sensors
    stopListening();

    // Dispose audio player
    _audioPlayer.dispose();

    // Clear all listeners
    _accelerometerListeners.clear();
    _gyroscopeListeners.clear();
    _magnetometerListeners.clear();
    _shakeListeners.clear();
    _rotationListeners.clear();

    _debugPrint("🧹 Motion sensor service disposed");
  }

  // Additional sensor listener management methods
  void addAccelerometerListener(Function(AccelerometerEvent) listener) {
    _accelerometerListeners.add(listener);
  }

  void removeAccelerometerListener(Function(AccelerometerEvent) listener) {
    _accelerometerListeners.remove(listener);
  }

  void addGyroscopeListener(Function(GyroscopeEvent) listener) {
    _gyroscopeListeners.add(listener);
  }

  void removeGyroscopeListener(Function(GyroscopeEvent) listener) {
    _gyroscopeListeners.remove(listener);
  }

  void addMagnetometerListener(Function(MagnetometerEvent) listener) {
    _magnetometerListeners.add(listener);
  }

  void removeMagnetometerListener(Function(MagnetometerEvent) listener) {
    _magnetometerListeners.remove(listener);
  }
}
