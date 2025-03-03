import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/light_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';

class ThemeSettingsWidget extends StatelessWidget {
  const ThemeSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Theme Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        RadioListTile<ThemePreference>(
          title: const Text("Light Theme"),
          subtitle: const Text("Always use light theme"),
          value: ThemePreference.light,
          groupValue: themeCubit.preference,
          onChanged: (value) {
            if (value != null) {
              themeCubit.setThemePreference(value);
            }
          },
        ),
        RadioListTile<ThemePreference>(
          title: const Text("Dark Theme"),
          subtitle: const Text("Always use dark theme"),
          value: ThemePreference.dark,
          groupValue: themeCubit.preference,
          onChanged: (value) {
            if (value != null) {
              themeCubit.setThemePreference(value);
            }
          },
        ),
        RadioListTile<ThemePreference>(
          title: const Text("System Theme"),
          subtitle: const Text("Follow system theme settings"),
          value: ThemePreference.system,
          groupValue: themeCubit.preference,
          onChanged: (value) {
            if (value != null) {
              themeCubit.setThemePreference(value);
            }
          },
        ),
        RadioListTile<ThemePreference>(
          title: const Text("Auto (Light Sensor)"),
          subtitle: const Text("Adjust theme based on ambient light"),
          value: ThemePreference.auto,
          groupValue: themeCubit.preference,
          onChanged: (value) {
            if (value != null) {
              themeCubit.setThemePreference(value);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Current environment: ${_getCurrentLightInfo(context)}",
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  String _getCurrentLightInfo(BuildContext context) {
    final lightSensorService = GetIt.instance<LightSensorService>();
    final lux = lightSensorService.currentLux;

    if (lux < LightSensorService.darkThreshold) {
      return "Very dark ($lux lux)";
    } else if (lux < LightSensorService.dimThreshold) {
      return "Dim ($lux lux)";
    } else if (lux < LightSensorService.normalThreshold) {
      return "Normal indoor lighting ($lux lux)";
    } else if (lux < LightSensorService.brightThreshold) {
      return "Bright ($lux lux)";
    } else {
      return "Very bright ($lux lux)";
    }
  }
}
