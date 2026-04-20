class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.mood,
    this.imagePath,
    this.locationName,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final String content;
  final String? mood;
  final String? imagePath;
  final DateTime createdAt;
  final String? locationName;
  final double? latitude;
  final double? longitude;

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    String? mood,
    String? imagePath,
    DateTime? createdAt,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'mood': mood,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory JournalEntry.fromMap(Map<String, Object?> map) {
    return JournalEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      mood: map['mood'] as String?,
      imagePath: map['image_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      locationName: map['location_name'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String?,
      imagePath: json['image_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      locationName: json['location_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
