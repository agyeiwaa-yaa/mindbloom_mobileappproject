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

  Habit copyWith({
    String? id,
    String? name,
    String? iconKey,
    int? colorValue,
    int? targetPerWeek,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    DateTime? createdAt,
    bool? archived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      targetPerWeek: targetPerWeek ?? this.targetPerWeek,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_key': iconKey,
      'color_value': colorValue,
      'target_per_week': targetPerWeek,
      'reminder_enabled': reminderEnabled,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'created_at': createdAt.toIso8601String(),
      'archived': archived,
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

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      iconKey: json['icon_key'] as String,
      colorValue: (json['color_value'] as num).toInt(),
      targetPerWeek: (json['target_per_week'] as num).toInt(),
      reminderEnabled: json['reminder_enabled'] == true || json['reminder_enabled'] == 1,
      reminderHour: (json['reminder_hour'] as num?)?.toInt(),
      reminderMinute: (json['reminder_minute'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      archived: json['archived'] == true || json['archived'] == 1,
    );
  }
}
