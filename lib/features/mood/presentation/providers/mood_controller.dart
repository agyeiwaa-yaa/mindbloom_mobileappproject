import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/core_providers.dart';
import '../../models/mood_entry.dart';

final moodControllerProvider =
    AsyncNotifierProvider<MoodController, List<MoodEntry>>(MoodController.new);

class MoodController extends AsyncNotifier<List<MoodEntry>> {
  @override
  Future<List<MoodEntry>> build() async {
    return ref.read(mindBloomRepositoryProvider).fetchMoods();
  }

  Future<void> addMood({
    required String mood,
    required int score,
    String? note,
    bool includeLocation = false,
  }) async {
    final location = includeLocation
        ? await ref.read(locationServiceProvider).getCurrentLocation()
        : null;
    final entry = MoodEntry(
      id: const Uuid().v4(),
      mood: mood,
      score: score,
      note: note,
      createdAt: DateTime.now(),
      locationName: location?.label,
      latitude: location?.latitude,
      longitude: location?.longitude,
    );
    await ref.read(mindBloomRepositoryProvider).saveMood(entry);
    state = AsyncData(await ref.read(mindBloomRepositoryProvider).fetchMoods());
  }

  Future<void> deleteMood(String id) async {
    await ref.read(mindBloomRepositoryProvider).deleteMood(id);
    state = AsyncData(await ref.read(mindBloomRepositoryProvider).fetchMoods());
  }
}
