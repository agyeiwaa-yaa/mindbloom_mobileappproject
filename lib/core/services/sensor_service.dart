import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ActivitySnapshot {
  const ActivitySnapshot({
    required this.motionLevel,
    required this.label,
    required this.bloomScore,
    required this.wellnessPrompt,
    required this.shakeDetected,
  });

  final double motionLevel;
  final String label;
  final int bloomScore;
  final String wellnessPrompt;
  final bool shakeDetected;
}

class SensorService {
  Stream<ActivitySnapshot> activityStream() async* {
    final window = <double>[];
    await for (final event in accelerometerEventStream()) {
      final magnitude = sqrt((event.x * event.x) + (event.y * event.y) + (event.z * event.z));
      final normalized = (magnitude - 9.8).abs();
      window.add(normalized);
      if (window.length > 8) {
        window.removeAt(0);
      }
      final averaged = window.reduce((a, b) => a + b) / window.length;
      final bloomScore = ((averaged.clamp(0, 5) / 5) * 100).round();
      final shakeDetected = normalized > 4.2;
      yield ActivitySnapshot(
        motionLevel: averaged,
        label: _labelForMotion(averaged),
        bloomScore: bloomScore,
        wellnessPrompt: _promptForMotion(averaged, shakeDetected),
        shakeDetected: shakeDetected,
      );
    }
  }

  String _labelForMotion(double motionLevel) {
    if (motionLevel < 0.5) return 'Grounded and still';
    if (motionLevel < 1.3) return 'Gentle movement';
    if (motionLevel < 2.8) return 'Active flow';
    return 'Burst of energy';
  }

  String _promptForMotion(double motionLevel, bool shakeDetected) {
    if (shakeDetected) {
      return 'Shake detected. This is a great moment to log how your body and mood feel right now.';
    }
    if (motionLevel < 0.5) {
      return 'You seem settled. Try a 30-second breathing pause or gratitude note while you are still.';
    }
    if (motionLevel < 1.3) {
      return 'Nice steady movement. A quick check-in now can help link calm activity with your mood.';
    }
    if (motionLevel < 2.8) {
      return 'You are moving with some energy. Consider marking an exercise or water habit after this burst.';
    }
    return 'Lots of motion right now. When things settle, capture a journal note about what energized you.';
  }
}
