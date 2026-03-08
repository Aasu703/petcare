import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/core/services/storage/user_session_service.dart';

/// Manages sensor feature toggles
class SensorSettingsNotifier extends Notifier<SensorSettings> {
  late final UserSessionService _sessionService;

  @override
  SensorSettings build() {
    _sessionService = ref.watch(userSessionServiceProvider);
    return SensorSettings(
      proximityAlertEnabled: _sessionService.isProximitySensorEnabled(),
      autoBrightnessEnabled: _sessionService.isAutoBrightnessEnabled(),
      proximityThreshold: _sessionService.getProximityThreshold(),
    );
  }

  Future<void> toggleProximityAlert(bool enabled) async {
    await _sessionService.setProximitySensorEnabled(enabled);
    state = state.copyWith(proximityAlertEnabled: enabled);
  }

  Future<void> toggleAutoBrightness(bool enabled) async {
    await _sessionService.setAutoBrightnessEnabled(enabled);
    state = state.copyWith(autoBrightnessEnabled: enabled);
  }

  Future<void> setProximityThreshold(int threshold) async {
    await _sessionService.setProximityThreshold(threshold);
    state = state.copyWith(proximityThreshold: threshold);
  }
}

class SensorSettings {
  final bool proximityAlertEnabled;
  final bool autoBrightnessEnabled;
  final int proximityThreshold;

  SensorSettings({
    required this.proximityAlertEnabled,
    required this.autoBrightnessEnabled,
    this.proximityThreshold = 5, // Default in cm
  });

  SensorSettings copyWith({
    bool? proximityAlertEnabled,
    bool? autoBrightnessEnabled,
    int? proximityThreshold,
  }) {
    return SensorSettings(
      proximityAlertEnabled:
          proximityAlertEnabled ?? this.proximityAlertEnabled,
      autoBrightnessEnabled:
          autoBrightnessEnabled ?? this.autoBrightnessEnabled,
      proximityThreshold: proximityThreshold ?? this.proximityThreshold,
    );
  }
}

final sensorSettingsProvider =
    NotifierProvider<SensorSettingsNotifier, SensorSettings>(() {
      return SensorSettingsNotifier();
    });
