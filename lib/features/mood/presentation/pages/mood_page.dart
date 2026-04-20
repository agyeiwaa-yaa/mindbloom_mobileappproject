import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/mood_controller.dart';

class MoodPage extends ConsumerStatefulWidget {
  const MoodPage({super.key});

  @override
  ConsumerState<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends ConsumerState<MoodPage> {
  final _noteController = TextEditingController();
  String _selectedMood = 'Calm';
  bool _includeLocation = false;

  static const _moods = [
    ('Joyful', 5, Icons.wb_sunny_outlined, Color(0xFFF7A8C5)),
    ('Calm', 4, Icons.spa_outlined, Color(0xFFD95C8A)),
    ('Okay', 3, Icons.cloud_queue_outlined, Color(0xFFE7A4BF)),
    ('Low', 2, Icons.nights_stay_outlined, Color(0xFFC06C92)),
    ('Stressed', 1, Icons.bolt_outlined, Color(0xFF8E3A59)),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moods = ref.watch(moodControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Mood Check-In', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Log how today feels in a way that is quick, private, and gentle.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blush,
                      AppColors.rose.withValues(alpha: 0.45),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling right now?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.plum,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pick one mood and add a short note if you want context for later.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.plum),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _moods
                    .map(
                      (item) {
                        final selected = _selectedMood == item.$1;
                        return ChoiceChip(
                          selected: selected,
                          backgroundColor: item.$4.withValues(alpha: 0.12),
                          selectedColor: item.$4,
                          side: BorderSide(color: item.$4.withValues(alpha: 0.5)),
                          label: Text(
                            item.$1,
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          avatar: Icon(item.$3, size: 18, color: selected ? Colors.white : item.$4),
                          onSelected: (_) => setState(() => _selectedMood = item.$1),
                        );
                      },
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Optional note',
                  hintText: 'What may have influenced your mood today?',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _includeLocation,
                title: const Text('Attach current location'),
                subtitle: const Text('Shows where you felt calmest on the dashboard'),
                onChanged: (value) => setState(() => _includeLocation = value),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () async {
                  final selected = _moods.firstWhere((item) => item.$1 == _selectedMood);
                  await ref.read(moodControllerProvider.notifier).addMood(
                        mood: selected.$1,
                        score: selected.$2,
                        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                        includeLocation: _includeLocation,
                      );
                  _noteController.clear();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mood saved')),
                  );
                },
                child: const Text('Save mood'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        moods.when(
          data: (entries) {
            if (entries.isEmpty) {
              return const EmptyState(
                title: 'No mood entries yet',
                subtitle: 'Start with a simple daily check-in to build your emotional history.',
                icon: Icons.favorite_outline,
              );
            }
            return Column(
              children: entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            entry.mood,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          subtitle: Text(
                            [
                              MindBloomDateUtils.prettyDateTime(entry.createdAt),
                              if ((entry.note ?? '').isNotEmpty) entry.note!,
                              if ((entry.locationName ?? '').isNotEmpty) entry.locationName!,
                            ].join(' • '),
                          ),
                          trailing: IconButton(
                            onPressed: () => ref.read(moodControllerProvider.notifier).deleteMood(entry.id),
                            icon: const Icon(Icons.delete_outline, color: AppColors.plum),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
          error: (error, _) => Text('Unable to load moods: $error'),
          loading: () => const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          )),
        ),
      ],
    );
  }
}
