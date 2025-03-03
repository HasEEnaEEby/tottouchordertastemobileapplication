import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/proximity_sensor_service.dart';

class ProximitySensorTestScreen extends StatefulWidget {
  const ProximitySensorTestScreen({super.key});

  @override
  State<ProximitySensorTestScreen> createState() =>
      _ProximitySensorTestScreenState();
}

class _ProximitySensorTestScreenState extends State<ProximitySensorTestScreen> {
  final ProximitySensorService _proximitySensorService =
      GetIt.instance<ProximitySensorService>();
  bool _isNear = false;

  @override
  void initState() {
    super.initState();
    _proximitySensorService.startListening();
    _proximitySensorService.addListener(_onProximityChanged);
  }

  void _onProximityChanged(bool isNear) {
    setState(() {
      _isNear = isNear;
    });
  }

  @override
  void dispose() {
    _proximitySensorService.removeListener(_onProximityChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximity Sensor Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isNear ? Icons.visibility_off : Icons.visibility,
              size: 100,
              color: _isNear ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              _isNear ? 'Object Detected Nearby!' : 'No Object Nearby',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 40),
            Text(
              'Current state: ${_isNear ? "NEAR" : "FAR"}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _isNear ? Colors.red : Colors.green,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'Cover the top part of your phone\nto test the proximity sensor',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
