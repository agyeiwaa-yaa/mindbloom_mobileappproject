import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/habits/models/habit.dart';
import '../../features/habits/models/habit_record.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/mood/models/mood_entry.dart';
import '../../features/settings/models/reminder_item.dart';

class DatabaseService {
  static const _databaseName = 'mindbloom.db';
  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mood_entries(
            id TEXT PRIMARY KEY,
            mood TEXT NOT NULL,
            score INTEGER NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL,
            location_name TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE journal_entries(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            mood TEXT,
            image_path TEXT,
            created_at TEXT NOT NULL,
            location_name TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE habits(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon_key TEXT NOT NULL,
            color_value INTEGER NOT NULL,
            target_per_week INTEGER NOT NULL,
            reminder_enabled INTEGER NOT NULL DEFAULT 0,
            reminder_hour INTEGER,
            reminder_minute INTEGER,
            created_at TEXT NOT NULL,
            archived INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_completions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            habit_id TEXT NOT NULL,
            completed_on TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE reminders(
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL,
            type TEXT NOT NULL,
            reference_id TEXT,
            enabled INTEGER NOT NULL DEFAULT 1
          )
        ''');
        await db.execute('''
          CREATE TABLE app_settings(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> dispose() async {
    if (_database != null) {
      await _database!.close();
    }
  }

  Future<List<MoodEntry>> fetchMoods() async {
    final db = await database;
    final rows = await db.query('mood_entries', orderBy: 'created_at DESC');
    return rows.map(MoodEntry.fromMap).toList();
  }

  Future<void> upsertMood(MoodEntry entry) async {
    final db = await database;
    await db.insert(
      'mood_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMood(String id) async {
    final db = await database;
    await db.delete('mood_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<JournalEntry>> fetchJournals() async {
    final db = await database;
    final rows = await db.query('journal_entries', orderBy: 'created_at DESC');
    return rows.map(JournalEntry.fromMap).toList();
  }

  Future<void> upsertJournal(JournalEntry entry) async {
    final db = await database;
    await db.insert(
      'journal_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteJournal(String id) async {
    final db = await database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Habit>> fetchHabits() async {
    final db = await database;
    final rows = await db.query('habits', where: 'archived = 0', orderBy: 'created_at DESC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<void> upsertHabit(Habit habit) async {
    final db = await database;
    await db.insert(
      'habits',
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> archiveHabit(String id) async {
    final db = await database;
    await db.update('habits', {'archived': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> fetchHabitCompletionDates(String habitId) async {
    final db = await database;
    final rows = await db.query(
      'habit_completions',
      columns: ['completed_on'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_on DESC',
    );
    return rows.map((row) => row['completed_on'] as String).toList();
  }

  Future<Map<String, List<String>>> fetchAllHabitCompletionDates() async {
    final db = await database;
    final rows = await db.query('habit_completions');
    final result = <String, List<String>>{};
    for (final row in rows) {
      final habitId = row['habit_id'] as String;
      result.putIfAbsent(habitId, () => []);
      result[habitId]!.add(row['completed_on'] as String);
    }
    return result;
  }

  Future<void> toggleHabitCompletion({
    required String habitId,
    required String dayKey,
  }) async {
    final db = await database;
    final existing = await db.query(
      'habit_completions',
      where: 'habit_id = ? AND completed_on = ?',
      whereArgs: [habitId, dayKey],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      await db.delete(
        'habit_completions',
        where: 'habit_id = ? AND completed_on = ?',
        whereArgs: [habitId, dayKey],
      );
    } else {
      await db.insert(
        'habit_completions',
        {'habit_id': habitId, 'completed_on': dayKey},
      );
    }
  }

  Future<List<ReminderItem>> fetchReminders() async {
    final db = await database;
    final rows = await db.query('reminders', orderBy: 'hour ASC, minute ASC');
    return rows.map(ReminderItem.fromMap).toList();
  }

  Future<void> upsertReminder(ReminderItem reminder) async {
    final db = await database;
    await db.insert(
      'reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('app_settings', where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HabitRecord>> fetchHabitRecords() async {
    final habits = await fetchHabits();
    final completions = await fetchAllHabitCompletionDates();
    return habits
        .map(
          (habit) => HabitRecord(
            habit: habit,
            completedDates: completions[habit.id] ?? [],
          ),
        )
        .toList();
  }
}
