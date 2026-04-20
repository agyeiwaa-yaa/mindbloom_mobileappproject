import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../features/habits/models/habit.dart';
import '../../features/habits/models/habit_record.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/mood/models/mood_entry.dart';
import 'database_service.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    required DatabaseService databaseService,
    required StorageService storageService,
    http.Client? client,
  })  : _databaseService = databaseService,
        _storageService = storageService,
        _client = client ?? http.Client();

  final DatabaseService _databaseService;
  final StorageService _storageService;
  final http.Client _client;

  Future<String?> getBaseUrl() async {
    final saved = await _databaseService.getSetting('api_base_url');
    if (saved == null || saved.trim().isEmpty) return null;
    return _normalizeBaseUrl(saved);
  }

  Future<void> setBaseUrl(String url) async {
    await _databaseService.setSetting('api_base_url', _normalizeBaseUrl(url));
  }

  Future<bool> isConfigured() async => (await getBaseUrl()) != null;

  Future<String> getOrCreateUserId() async {
    final existing = await _databaseService.getSetting('remote_user_id');
    if (existing != null && existing.isNotEmpty) return existing;
    final id = const Uuid().v4();
    await _databaseService.setSetting('remote_user_id', id);
    return id;
  }

  Future<bool> ping() async {
    final baseUrl = await getBaseUrl();
    if (baseUrl == null) return false;
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/health.php'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> bootstrapUser() async {
    try {
      final baseUrl = await _requireBaseUrl();
      final userId = await getOrCreateUserId();
      await _postJson(
        Uri.parse('$baseUrl/bootstrap.php'),
        {
          'user_id': userId,
          'display_name': 'MindBloom User',
        },
      );
    } catch (_) {
      // Allow configuration to save even if the remote server is not reachable yet.
    }
  }

  Future<List<MoodEntry>> fetchMoods() async {
    final baseUrl = await _requireBaseUrl();
    await bootstrapUser();
    final userId = await getOrCreateUserId();
    final payload = await _getJson(Uri.parse('$baseUrl/moods.php?user_id=$userId'));
    final items = (payload['data'] as List<dynamic>)
        .map((item) => MoodEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<MoodEntry> saveMood(MoodEntry entry) async {
    final baseUrl = await _requireBaseUrl();
    await bootstrapUser();
    final userId = await getOrCreateUserId();
    final payload = await _postJson(
      Uri.parse('$baseUrl/moods.php'),
      {
        'user_id': userId,
        ...entry.toJson(),
      },
    );
    return MoodEntry.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<void> deleteMood(String moodId) async {
    final baseUrl = await _requireBaseUrl();
    final userId = await getOrCreateUserId();
    await _postJson(
      Uri.parse('$baseUrl/moods.php'),
      {
        'action': 'delete',
        'user_id': userId,
        'id': moodId,
      },
    );
  }

  Future<List<JournalEntry>> fetchJournals() async {
    final baseUrl = await _requireBaseUrl();
    await bootstrapUser();
    final userId = await getOrCreateUserId();
    final payload = await _getJson(Uri.parse('$baseUrl/journals.php?user_id=$userId'));
    final items = (payload['data'] as List<dynamic>)
        .map((item) => JournalEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<JournalEntry> saveJournal(JournalEntry entry) async {
    final baseUrl = await _requireBaseUrl();
    await bootstrapUser();
    final userId = await getOrCreateUserId();
    final path = entry.imagePath;
    final localImage = path != null && !path.startsWith('http') && await _storageService.fileExists(path);

    if (localImage) {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/journals.php'));
      request.fields.addAll({
        'user_id': userId,
        'id': entry.id,
        'title': entry.title,
        'content': entry.content,
        'mood': entry.mood ?? '',
        'created_at': entry.createdAt.toIso8601String(),
        'location_name': entry.locationName ?? '',
        'latitude': '${entry.latitude ?? ''}',
        'longitude': '${entry.longitude ?? ''}',
        'existing_image_path': entry.imagePath?.startsWith('http') == true ? entry.imagePath! : '',
      });
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        path,
        filename: p.basename(path),
      ));
      final streamed = await request.send().timeout(const Duration(seconds: 25));
      final response = await http.Response.fromStream(streamed);
      final payload = _decodeResponse(response);
      return JournalEntry.fromJson(payload['data'] as Map<String, dynamic>);
    }

    final payload = await _postJson(
      Uri.parse('$baseUrl/journals.php'),
      {
        'user_id': userId,
        ...entry.toJson(),
      },
    );
    return JournalEntry.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<void> deleteJournal(String journalId) async {
    final baseUrl = await _requireBaseUrl();
    final userId = await getOrCreateUserId();
    await _postJson(
      Uri.parse('$baseUrl/journals.php'),
      {
        'action': 'delete',
        'user_id': userId,
        'id': journalId,
      },
    );
  }

  Future<List<HabitRecord>> fetchHabitRecords() async {
    final baseUrl = await _requireBaseUrl();
    await bootstrapUser();
    final userId = await getOrCreateUserId();
    final payload = await _getJson(Uri.parse('$baseUrl/habits.php?user_id=$userId'));
    final data = payload['data'] as Map<String, dynamic>;
    final habits = (data['habits'] as List<dynamic>)
        .map((item) => Habit.fromJson(item as Map<String, dynamic>))
        .toList();
    final completions = (data['completions'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>).map((item) => item as String).toList(),
      ),
    );

    return habits
        .map(
          (habit) => HabitRecord(
            habit: habit,
            completedDates: completions[habit.id] ?? const [],
          ),
        )
        .toList();
  }

  Future<Habit> saveHabit(Habit habit) async {
    final baseUrl = await _requireBaseUrl();
    await bootstrapUser();
    final userId = await getOrCreateUserId();
    final payload = await _postJson(
      Uri.parse('$baseUrl/habits.php'),
      {
        'user_id': userId,
        ...habit.toJson(),
      },
    );
    return Habit.fromJson(payload['data'] as Map<String, dynamic>);
  }

  Future<void> archiveHabit(String habitId) async {
    final baseUrl = await _requireBaseUrl();
    final userId = await getOrCreateUserId();
    await _postJson(
      Uri.parse('$baseUrl/habits.php'),
      {
        'action': 'archive',
        'user_id': userId,
        'id': habitId,
      },
    );
  }

  Future<void> toggleHabitCompletion({
    required String habitId,
    required String completedOn,
  }) async {
    final baseUrl = await _requireBaseUrl();
    final userId = await getOrCreateUserId();
    await _postJson(
      Uri.parse('$baseUrl/habits.php'),
      {
        'action': 'toggle_completion',
        'user_id': userId,
        'habit_id': habitId,
        'completed_on': completedOn,
      },
    );
  }

  Future<String> _requireBaseUrl() async {
    final baseUrl = await getBaseUrl();
    if (baseUrl == null) {
      throw ApiException('Backend URL is not configured yet.');
    }
    return baseUrl;
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _postJson(Uri uri, Map<String, dynamic> body) async {
    final response = await _client
        .post(
          uri,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400 || payload['success'] != true) {
      throw ApiException((payload['message'] ?? 'Remote request failed').toString());
    }
    return payload;
  }

  String _normalizeBaseUrl(String url) {
    var normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
