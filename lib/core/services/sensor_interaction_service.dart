import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/sensors/device_sensors_provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Service to handle sensor-based app interactions
class SensorInteractionService {
  final Ref ref;

  SensorInteractionService(this.ref);

  /// Start monitoring sensors and apply effects
  Future<void> initializeSensorMonitoring({
    required bool proximityAlertEnabled,
    required bool autoBrightnessEnabled,
    required BuildContext context,
  }) async {
    // Monitor proximity sensor
    if (proximityAlertEnabled) {
      _monitorProximitySensor(context);
    }

    // Monitor light sensor
    if (autoBrightnessEnabled) {
      _monitorLightSensor();
    }
  }

  /// Monitor proximity and show warning when too close
  void _monitorProximitySensor(BuildContext context) {
    // Listen to proximity sensor changes
    ref.listen(proximitySensorNearProvider, (previous, next) {
      if (next.hasValue && next.value == true) {
        // Phone is near face - show warning
        _showProximityWarning(context);
      }
    });
  }

  /// Automatically adjust brightness based on ambient light
  void _monitorLightSensor() {
    ref.listen(ambientLightLuxProvider, (previous, next) async {
      if (!next.hasValue || next.value == null) return;

      final luxValue = next.value!;

      // Adjust brightness based on lux level
      // Normal daylight: 10,000-25,000+ lux
      // Office: 320-500 lux
      // Twilight: 3.4 lux
      // Dark: <3.4 lux

      try {
        final brightness = _luxToBrightness(luxValue);
        await ScreenBrightness().setScreenBrightness(brightness);
      } catch (e) {
        debugPrint('Error adjusting brightness: $e');
      }
    });
  }

  /// Convert lux value to screen brightness (0.0 - 1.0)
  double _luxToBrightness(int lux) {
    // Map lux values to brightness
    // Very dark (<5 lux) -> 0.2 (20% brightness)
    // Dark (5-50 lux) -> 0.3-0.4
    // Dim (50-500 lux) -> 0.4-0.6
    // Normal (500-5000 lux) -> 0.6-0.8
    // Bright (5000+ lux) -> 0.8-1.0

    if (lux < 5) return 0.2;
    if (lux < 50) return 0.3 + (lux / 50) * 0.1;
    if (lux < 500) return 0.4 + ((lux - 50) / 450) * 0.2;
    if (lux < 5000) return 0.6 + ((lux - 500) / 4500) * 0.2;
    return 0.9; // Maximum brightness for very bright conditions
  }

  /// Show proximity warning when phone is too close to face
  void _showProximityWarning(BuildContext context) {
    // Use haptic feedback and visual warning
    HapticFeedback.heavyImpact();

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '⚠️ Phone Too Close!',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Move phone away from your face - eye safety!',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      entry.remove();
    });
  }
}

/// Provider for sensor interaction service
final sensorInteractionServiceProvider = Provider<SensorInteractionService>((
  ref,
) {
  return SensorInteractionService(ref);
});
