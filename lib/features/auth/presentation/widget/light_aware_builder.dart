import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/light_sensor_service.dart';

class LightAwareBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, LightLevel lightLevel) builder;

  const LightAwareBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<LightAwareBuilder> createState() => _LightAwareBuilderState();
}

class _LightAwareBuilderState extends State<LightAwareBuilder> {
  final LightSensorService _lightSensorService =
      GetIt.instance<LightSensorService>();
  late LightLevel _currentLightLevel;

  @override
  void initState() {
    super.initState();
    _currentLightLevel = _lightSensorService.currentBrightnessLevel;
    _lightSensorService.startListening();
    _lightSensorService.addListener(_onLightLevelChanged);
  }

  void _onLightLevelChanged(int lux) {
    final newLevel = _lightSensorService.currentBrightnessLevel;
    if (_currentLightLevel != newLevel) {
      setState(() {
        _currentLightLevel = newLevel;
      });
    }
  }

  @override
  void dispose() {
    _lightSensorService.removeListener(_onLightLevelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentLightLevel);
  }
}
