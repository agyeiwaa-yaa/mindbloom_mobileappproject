class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.mood,
    required this.score,
    required this.createdAt,
    this.note,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String mood;
  final int score;
  final String? note;
  final DateTime createdAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'mood': mood,
      'score': score,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory MoodEntry.fromMap(Map<String, Object?> map) {
    return MoodEntry(
      id: map['id'] as String,
      mood: map['mood'] as String,
      score: map['score'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      locationName: map['location_name'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }
}
