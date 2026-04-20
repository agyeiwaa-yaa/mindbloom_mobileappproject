int calculateCurrentStreak(List<String> dayKeys) {
  if (dayKeys.isEmpty) return 0;
  final sorted = [...dayKeys]..sort((a, b) => b.compareTo(a));
  final unique = sorted.toSet().toList()..sort((a, b) => b.compareTo(a));

  var streak = 0;
  var cursor = DateTime.now();
  for (final key in unique) {
    final expected = '${cursor.year.toString().padLeft(4, '0')}-'
        '${cursor.month.toString().padLeft(2, '0')}-'
        '${cursor.day.toString().padLeft(2, '0')}';
    if (key == expected) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
      continue;
    }
    if (streak == 0) {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayKey = '${yesterday.year.toString().padLeft(4, '0')}-'
          '${yesterday.month.toString().padLeft(2, '0')}-'
          '${yesterday.day.toString().padLeft(2, '0')}';
      if (key == yesterdayKey) {
        streak++;
        cursor = yesterday.subtract(const Duration(days: 1));
        continue;
      }
    }
    break;
  }
  return streak;
}

double calculateCompletionRate(List<String> dayKeys, {int totalDays = 30}) {
  if (totalDays <= 0) return 0;
  final unique = dayKeys.toSet().length;
  return (unique / totalDays).clamp(0, 1);
}
