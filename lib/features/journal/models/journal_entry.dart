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
}
