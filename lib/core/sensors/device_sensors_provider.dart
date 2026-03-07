import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light/light.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

final ambientLightLuxProvider = StreamProvider<int?>((ref) async* {
  if (kIsWeb) {
    yield null;
    return;
  }

  try {
    yield* Light().lightSensorStream;
  } catch (_) {
    yield null;
  }
});

final proximitySensorNearProvider = StreamProvider<bool?>((ref) async* {
  if (kIsWeb) {
    yield null;
    return;
  }

  try {
    // ProximitySensor.events emits int: 0 = near, >0 = far
    yield* ProximitySensor.events.map((event) => event == 0);
  } catch (_) {
    yield null;
  }
});
