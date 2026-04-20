import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ActivitySnapshot {
  const ActivitySnapshot({
    required this.motionLevel,
    required this.label,
  });

  final double motionLevel;
  final String label;
}

class SensorService {
  Stream<ActivitySnapshot> activityStream() async* {
    await for (final event in accelerometerEventStream()) {
      final magnitude = sqrt((event.x * event.x) + (event.y * event.y) + (event.z * event.z));
      final normalized = (magnitude - 9.8).abs();
      yield ActivitySnapshot(
        motionLevel: normalized,
        label: normalized < 1.2 ? 'Calm / still' : 'Moving around',
      );
    }
  }
}
