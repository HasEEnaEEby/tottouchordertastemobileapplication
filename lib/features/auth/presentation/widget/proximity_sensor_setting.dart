import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/proximity/proximity_cubit.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';

class ProximitySettingsScreen extends StatefulWidget {
  const ProximitySettingsScreen({super.key});

  @override
  State<ProximitySettingsScreen> createState() =>
      _ProximitySettingsScreenState();
}

class _ProximitySettingsScreenState extends State<ProximitySettingsScreen> {
  late SensorManager _sensorManager;

  bool _screenDimmingEnabled = true;
  bool _autoPauseEnabled = true;
  bool _touchBlockingEnabled = true;
  bool _proximitySensorEnabled = true;

  @override
  void initState() {
    super.initState();
    _sensorManager = GetIt.instance<SensorManager>();

    _screenDimmingEnabled = _sensorManager.isProximityScreenDimmingEnabled;
    _autoPauseEnabled = _sensorManager.isProximityAutoPauseEnabled;
    _touchBlockingEnabled = _sensorManager.isProximityTouchBlockingEnabled;
    _proximitySensorEnabled = _sensorManager.isProximitySensorActive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximity Sensor Settings'),
        elevation: 2,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildProximitySensorStatus(),
            const Divider(height: 32),
            _buildSwitchTile(
              title: 'Enable Proximity Sensor',
              subtitle: 'Use proximity sensor to control app behavior',
              value: _proximitySensorEnabled,
              onChanged: (value) {
                setState(() {
                  _proximitySensorEnabled = value;

                  if (value) {
                    _sensorManager.proximitySensorService.startListening();
                    context.read<ProximityCubit>().startProximitySensing();
                  } else {
                    _sensorManager.proximitySensorService.stopListening();
                    context.read<ProximityCubit>().stopProximitySensing();
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Proximity Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildSwitchTile(
              title: 'Screen Dimming',
              subtitle: 'Dim the screen when phone is near your face',
              value: _screenDimmingEnabled,
              onChanged: _proximitySensorEnabled
                  ? (value) {
                      setState(() {
                        _screenDimmingEnabled =
                            _sensorManager.toggleProximityScreenDimming();
                      });
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: 'Auto-Pause Media',
              subtitle: 'Pause media playback when phone is near your face',
              value: _autoPauseEnabled,
              onChanged: _proximitySensorEnabled
                  ? (value) {
                      setState(() {
                        _autoPauseEnabled =
                            _sensorManager.toggleProximityAutoPause();
                      });
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: 'Block Touches',
              subtitle:
                  'Prevent accidental touches when phone is near your face',
              value: _touchBlockingEnabled,
              onChanged: _proximitySensorEnabled
                  ? (value) {
                      setState(() {
                        _touchBlockingEnabled =
                            _sensorManager.toggleProximityTouchBlocking();
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 24),
            _buildProximityTestArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      dense: false,
      activeColor: Theme.of(context).colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Show the current proximity sensor status
  Widget _buildProximitySensorStatus() {
    return BlocBuilder<ProximityCubit, ProximityState>(
      builder: (context, state) {
        final isNear = state.isNear;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Proximity Sensor Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isNear ? Icons.phone_in_talk : Icons.phone_android,
                      size: 32,
                      color: isNear ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isNear ? 'Object Near' : 'No Object Detected',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isNear ? Colors.red : Colors.green,
                          ),
                        ),
                        Text(
                          isNear
                              ? 'Phone is likely near your face'
                              : 'Phone is in normal use position',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProximityTestArea() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Proximity Sensor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cover the top of your phone to see the proximity sensor in action',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            BlocBuilder<ProximityCubit, ProximityState>(
              builder: (context, state) {
                return Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: state.isNear
                        ? Colors.grey.shade800
                        : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    state.isNear ? 'SENSOR COVERED' : 'SENSOR NOT COVERED',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.isNear ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
