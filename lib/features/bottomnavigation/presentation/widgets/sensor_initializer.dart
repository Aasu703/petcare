import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/sensor_settings_provider.dart';
import 'package:petcare/core/services/sensor_interaction_service.dart';

/// Wrapper widget to initialize and manage sensors app-wide
class SensorInitializer extends ConsumerWidget {
  final Widget child;

  const SensorInitializer({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch sensor settings - will initialize when they change
    ref.watch(sensorSettingsProvider);

    // Listen for changes and initialize sensors
    ref.listen(sensorSettingsProvider, (prev, next) async {
      final sensorService = ref.read(sensorInteractionServiceProvider);

      // Initialize/reinitialize sensors based on settings
      if (next.proximityAlertEnabled || next.autoBrightnessEnabled) {
        await sensorService.initializeSensorMonitoring(
          proximityAlertEnabled: next.proximityAlertEnabled,
          autoBrightnessEnabled: next.autoBrightnessEnabled,
          context: context,
        );
      }
    });

    return child;
  }
}
