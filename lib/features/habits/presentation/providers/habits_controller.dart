import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../models/habit.dart';
import '../../models/habit_record.dart';

final habitsControllerProvider =
    AsyncNotifierProvider<HabitsController, List<HabitRecord>>(HabitsController.new);

class HabitsController extends AsyncNotifier<List<HabitRecord>> {
  @override
  Future<List<HabitRecord>> build() async {
    return ref.read(mindBloomRepositoryProvider).fetchHabitRecords();
  }

  Future<void> saveHabit(Habit habit) async {
    await ref.read(mindBloomRepositoryProvider).saveHabit(habit);
    await _syncHabitReminder(habit, ref.read(notificationServiceProvider));
    state = AsyncData(await ref.read(mindBloomRepositoryProvider).fetchHabitRecords());
  }

  Future<void> archiveHabit(String habitId) async {
    await ref.read(mindBloomRepositoryProvider).archiveHabit(habitId);
    await ref.read(notificationServiceProvider).cancel(habitId.hashCode);
    state = AsyncData(await ref.read(mindBloomRepositoryProvider).fetchHabitRecords());
  }

  Future<void> toggleToday(String habitId) async {
    await ref.read(mindBloomRepositoryProvider).toggleHabitCompletion(
          habitId: habitId,
          dayKey: MindBloomDateUtils.dayKey(DateTime.now()),
        );
    state = AsyncData(await ref.read(mindBloomRepositoryProvider).fetchHabitRecords());
  }

  Future<void> seedDefaultHabits() async {
    final current = await ref.read(databaseServiceProvider).fetchHabits();
    if (current.isNotEmpty) return;
    final defaults = [
      Habit(
        id: const Uuid().v4(),
        name: 'Drink water',
        iconKey: 'water',
        colorValue: 0xFF8AB6D6,
        targetPerWeek: 7,
        createdAt: DateTime.now(),
      ),
      Habit(
        id: const Uuid().v4(),
        name: 'Meditate',
        iconKey: 'spa',
        colorValue: 0xFF7B9E87,
        targetPerWeek: 5,
        createdAt: DateTime.now(),
      ),
      Habit(
        id: const Uuid().v4(),
        name: 'Sleep well',
        iconKey: 'moon',
        colorValue: 0xFFE6A57E,
        targetPerWeek: 7,
        createdAt: DateTime.now(),
      ),
    ];
    for (final habit in defaults) {
      await ref.read(mindBloomRepositoryProvider).saveHabit(habit);
    }
    state = AsyncData(await ref.read(mindBloomRepositoryProvider).fetchHabitRecords());
  }

  Future<void> _syncHabitReminder(Habit habit, NotificationService service) async {
    if (!habit.reminderEnabled || habit.reminderHour == null || habit.reminderMinute == null) {
      await service.cancel(habit.id.hashCode);
      return;
    }
    await service.scheduleDaily(
      id: habit.id.hashCode,
      title: 'MindBloom habit reminder',
      body: 'Time for "${habit.name}"',
      hour: habit.reminderHour!,
      minute: habit.reminderMinute!,
    );
  }
}
