class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.title,
    required this.body,
    required this.hour,
    required this.minute,
    required this.type,
    this.referenceId,
    this.enabled = true,
  });

  final String id;
  final String title;
  final String body;
  final int hour;
  final int minute;
  final String type;
  final String? referenceId;
  final bool enabled;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'hour': hour,
      'minute': minute,
      'type': type,
      'reference_id': referenceId,
      'enabled': enabled ? 1 : 0,
    };
  }

  factory ReminderItem.fromMap(Map<String, Object?> map) {
    return ReminderItem(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      type: map['type'] as String,
      referenceId: map['reference_id'] as String?,
      enabled: (map['enabled'] as int? ?? 1) == 1,
    );
  }
}
