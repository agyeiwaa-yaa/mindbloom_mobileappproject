class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.targetPerWeek,
    required this.createdAt,
    this.reminderEnabled = false,
    this.reminderHour,
    this.reminderMinute,
    this.archived = false,
  });

  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final int targetPerWeek;
  final bool reminderEnabled;
  final int? reminderHour;
  final int? reminderMinute;
  final DateTime createdAt;
  final bool archived;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_key': iconKey,
      'color_value': colorValue,
      'target_per_week': targetPerWeek,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'created_at': createdAt.toIso8601String(),
      'archived': archived ? 1 : 0,
    };
  }

  factory Habit.fromMap(Map<String, Object?> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      iconKey: map['icon_key'] as String,
      colorValue: map['color_value'] as int,
      targetPerWeek: map['target_per_week'] as int,
      reminderEnabled: (map['reminder_enabled'] as int? ?? 0) == 1,
      reminderHour: map['reminder_hour'] as int?,
      reminderMinute: map['reminder_minute'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      archived: (map['archived'] as int? ?? 0) == 1,
    );
  }
}
