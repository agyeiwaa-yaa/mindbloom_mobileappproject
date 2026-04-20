import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/streak_utils.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../models/habit_record.dart';
import '../providers/habits_controller.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsControllerProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Habits', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Build gentle consistency with routines that support your mind and body.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          habitsAsync.when(
            data: (records) {
              if (records.isEmpty) {
                return Column(
                  children: [
                    const EmptyState(
                      title: 'No habits yet',
                      subtitle: 'Start with water, sleep, gratitude, or movement.',
                      icon: Icons.task_alt_outlined,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.read(habitsControllerProvider.notifier).seedDefaultHabits(),
                      child: const Text('Load starter habits'),
                    ),
                  ],
                );
              }
              return Column(
                children: records.map((record) => _HabitTile(record: record)).toList(),
              );
            },
            error: (error, _) => Text('Unable to load habits: $error'),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habit/edit'),
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('New habit'),
      ),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.record});

  final HabitRecord record;

  static const _icons = {
    'water': Icons.water_drop_outlined,
    'spa': Icons.spa_outlined,
    'moon': Icons.nights_stay_outlined,
    'fitness': Icons.fitness_center_outlined,
    'gratitude': Icons.favorite_outline,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayKey = MindBloomDateUtils.dayKey(DateTime.now());
    final completedToday = record.completedDates.contains(todayKey);
    final streak = calculateCurrentStreak(record.completedDates);
    final rate = calculateCompletionRate(record.completedDates) * 100;
    final color = Color(record.habit.colorValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.16),
                  child: Icon(_icons[record.habit.iconKey] ?? Icons.task_alt_outlined, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.habit.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Streak $streak days • ${rate.toStringAsFixed(0)}% last 30 days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: completedToday,
                  onChanged: (_) => ref.read(habitsControllerProvider.notifier).toggleToday(record.habit.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (rate / 100).clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(99),
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.12),
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/habit/edit', extra: record.habit),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => ref.read(habitsControllerProvider.notifier).archiveHabit(record.habit.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
