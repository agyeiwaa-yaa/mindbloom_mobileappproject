import 'habit.dart';

class HabitRecord {
  const HabitRecord({
    required this.habit,
    required this.completedDates,
  });

  final Habit habit;
  final List<String> completedDates;
}
