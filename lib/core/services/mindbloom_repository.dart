import '../../features/habits/models/habit.dart';
import '../../features/habits/models/habit_record.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/mood/models/mood_entry.dart';
import 'api_service.dart';
import 'database_service.dart';

class MindBloomRepository {
  MindBloomRepository({
    required DatabaseService databaseService,
    required ApiService apiService,
  })  : _databaseService = databaseService,
        _apiService = apiService;

  final DatabaseService _databaseService;
  final ApiService _apiService;

  Future<List<MoodEntry>> fetchMoods() async {
    if (await _apiService.ping()) {
      final remote = await _apiService.fetchMoods();
      await _databaseService.replaceMoods(remote);
      return remote;
    }
    return _databaseService.fetchMoods();
  }

  Future<void> saveMood(MoodEntry entry) async {
    if (await _apiService.ping()) {
      final remote = await _apiService.saveMood(entry);
      await _databaseService.upsertMood(remote);
      return;
    }
    await _databaseService.upsertMood(entry);
  }

  Future<void> deleteMood(String id) async {
    if (await _apiService.ping()) {
      await _apiService.deleteMood(id);
    }
    await _databaseService.deleteMood(id);
  }

  Future<List<JournalEntry>> fetchJournals() async {
    if (await _apiService.ping()) {
      final remote = await _apiService.fetchJournals();
      await _databaseService.replaceJournals(remote);
      return remote;
    }
    return _databaseService.fetchJournals();
  }

  Future<void> saveJournal(JournalEntry entry) async {
    if (await _apiService.ping()) {
      final remote = await _apiService.saveJournal(entry);
      await _databaseService.upsertJournal(remote);
      return;
    }
    await _databaseService.upsertJournal(entry);
  }

  Future<void> deleteJournal(String id) async {
    if (await _apiService.ping()) {
      await _apiService.deleteJournal(id);
    }
    await _databaseService.deleteJournal(id);
  }

  Future<List<HabitRecord>> fetchHabitRecords() async {
    if (await _apiService.ping()) {
      final remote = await _apiService.fetchHabitRecords();
      await _databaseService.replaceHabits(remote);
      return remote;
    }
    return _databaseService.fetchHabitRecords();
  }

  Future<void> saveHabit(Habit habit) async {
    if (await _apiService.ping()) {
      final remote = await _apiService.saveHabit(habit);
      await _databaseService.upsertHabit(remote);
      return;
    }
    await _databaseService.upsertHabit(habit);
  }

  Future<void> archiveHabit(String habitId) async {
    if (await _apiService.ping()) {
      await _apiService.archiveHabit(habitId);
    }
    await _databaseService.archiveHabit(habitId);
  }

  Future<void> toggleHabitCompletion({
    required String habitId,
    required String dayKey,
  }) async {
    if (await _apiService.ping()) {
      await _apiService.toggleHabitCompletion(
        habitId: habitId,
        completedOn: dayKey,
      );
    }
    await _databaseService.toggleHabitCompletion(habitId: habitId, dayKey: dayKey);
  }

  Future<void> syncLocalCacheToRemote() async {
    if (!await _apiService.ping()) return;

    final moods = await _databaseService.fetchMoods();
    for (final mood in moods) {
      final remote = await _apiService.saveMood(mood);
      await _databaseService.upsertMood(remote);
    }

    final journals = await _databaseService.fetchJournals();
    for (final journal in journals) {
      final remote = await _apiService.saveJournal(journal);
      await _databaseService.upsertJournal(remote);
    }

    final records = await _databaseService.fetchHabitRecords();
    for (final record in records) {
      final remoteHabit = await _apiService.saveHabit(record.habit);
      await _databaseService.upsertHabit(remoteHabit);
      for (final day in record.completedDates) {
        await _apiService.toggleHabitCompletion(
          habitId: record.habit.id,
          completedOn: day,
        );
      }
    }

    final remoteRecords = await _apiService.fetchHabitRecords();
    await _databaseService.replaceHabits(remoteRecords);
  }
}
