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

  MoodEntry copyWith({
    String? id,
    String? mood,
    int? score,
    String? note,
    DateTime? createdAt,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      score: score ?? this.score,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

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

  Map<String, dynamic> toJson() {
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

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      mood: json['mood'] as String,
      score: (json['score'] as num).toInt(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      locationName: json['location_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
