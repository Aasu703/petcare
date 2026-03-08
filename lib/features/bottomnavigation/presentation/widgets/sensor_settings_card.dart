import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/providers/sensor_settings_provider.dart';
import 'package:petcare/core/sensors/device_sensors_provider.dart';

class SensorSettingsCard extends ConsumerWidget {
  const SensorSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorSettings = ref.watch(sensorSettingsProvider);
    final proximityStatus = ref.watch(proximitySensorNearProvider);
    final ambientLight = ref.watch(ambientLightLuxProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sensors_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Smart Sensors',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.cyan.shade600,
                    ),
                  ),
                  Text(
                    'Intelligent device monitoring',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Proximity Sensor Toggle
        _buildSensorCard(
          context,
          icon: Icons.face_retouching_natural_rounded,
          title: '👤 Proximity Alert',
          subtitle: 'Warns when phone is too close to your face',
          isEnabled: sensorSettings.proximityAlertEnabled,
          sensorReading: proximityStatus.maybeWhen(
            data: (data) => data == true ? '🔴 TOO CLOSE!' : '✅ Safe distance',
            orElse: () => 'Checking...',
          ),
          onToggle: (enabled) async {
            HapticFeedback.mediumImpact();
            await ref
                .read(sensorSettingsProvider.notifier)
                .toggleProximityAlert(enabled);
          },
          color: Colors.deepOrange,
        ),
        const SizedBox(height: 12),

        // Auto Brightness Toggle
        _buildSensorCard(
          context,
          icon: Icons.brightness_4_rounded,
          title: '💡 Auto Brightness',
          subtitle: 'Adjusts screen brightness based on light',
          isEnabled: sensorSettings.autoBrightnessEnabled,
          sensorReading: ambientLight.maybeWhen(
            data: (data) => data != null
                ? '${data} lux - ${_getLuxDescription(data)}'
                : 'Reading...',
            orElse: () => 'Unavailable',
          ),
          onToggle: (enabled) async {
            HapticFeedback.mediumImpact();
            await ref
                .read(sensorSettingsProvider.notifier)
                .toggleAutoBrightness(enabled);
          },
          color: Colors.amber,
        ),
        const SizedBox(height: 12),

        // Light Meter Visualization
        if (ambientLight.maybeWhen(
          data: (data) => data != null,
          orElse: () => false,
        ))
          _buildLightMeterVisualization(context, ambientLight),
      ],
    );
  }

  Widget _buildSensorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required String sensorReading,
    required Function(bool) onToggle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isEnabled ? color.withOpacity(0.08) : Colors.grey.withOpacity(0.05),
            isEnabled ? color.withOpacity(0.04) : Colors.grey.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? color.withOpacity(0.3) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onToggle(!isEnabled),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Toggle Switch
                    AnimatedScale(
                      scale: isEnabled ? 1.0 : 0.9,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        width: 50,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isEnabled
                              ? color.withOpacity(0.3)
                              : Colors.grey.shade300,
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: isEnabled
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isEnabled ? color : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isEnabled ? color : Colors.grey)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isEnabled
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sensor Reading
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sensorReading,
                          style: TextStyle(
                            fontSize: 12,
                            color: isEnabled ? color : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightMeterVisualization(
    BuildContext context,
    dynamic ambientLight,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.08),
            Colors.orange.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Light Meter',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.amber.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ambientLight.maybeWhen(
              data: (value) {
                if (value == null) return const SizedBox();
                final percentage = _luxToPercentage(value);
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(
                                Color.lerp(
                                      Colors.blue.shade600,
                                      Colors.red.shade600,
                                      percentage / 100,
                                    ) ??
                                    Colors.amber,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getLuxDescription(value),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              },
              orElse: () => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  String _getLuxDescription(int lux) {
    if (lux < 5) return 'Very Dark 🌑';
    if (lux < 50) return 'Dark 🌙';
    if (lux < 500) return 'Dim 🌅';
    if (lux < 5000) return 'Well Lit 🌤️';
    if (lux < 25000) return 'Bright ☀️';
    return 'Very Bright 🔆';
  }

  double _luxToPercentage(int lux) {
    // Map 0-25000 lux to 0-100%
    return (lux / 25000 * 100).clamp(0, 100);
  }
}
