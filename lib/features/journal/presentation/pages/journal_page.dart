import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../models/journal_entry.dart';
import '../providers/journal_controller.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  String _query = '';
  String _selectedMood = 'All';

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalControllerProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Journal', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Capture reflections, gratitude moments, and the stories behind your mood.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => _query = value.toLowerCase()),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search journal entries',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: ['All', 'Joyful', 'Calm', 'Okay', 'Low', 'Stressed']
                .map(
                  (mood) => ChoiceChip(
                    label: Text(mood),
                    selected: _selectedMood == mood,
                    onSelected: (_) => setState(() => _selectedMood = mood),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          journalAsync.when(
            data: (entries) {
              final filtered = entries.where((entry) {
                final queryMatches = _query.isEmpty ||
                    entry.title.toLowerCase().contains(_query) ||
                    entry.content.toLowerCase().contains(_query);
                final moodMatches = _selectedMood == 'All' || entry.mood == _selectedMood;
                return queryMatches && moodMatches;
              }).toList();

              if (filtered.isEmpty) {
                return const EmptyState(
                  title: 'Your journal is quiet',
                  subtitle: 'Create an entry to build a supportive record of your days.',
                  icon: Icons.menu_book_outlined,
                );
              }

              final imageEntries = filtered.where((entry) => (entry.imagePath ?? '').isNotEmpty).toList();
              return Column(
                children: [
                  if (imageEntries.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Photo memories', style: Theme.of(context).textTheme.titleMedium),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: imageEntries.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) => _JournalImageCard(entry: imageEntries[index]),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  ...filtered.map((entry) => _JournalTile(entry: entry)),
                ],
              );
            },
            error: (error, _) => Text('Unable to load journal entries: $error'),
            loading: () => const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
          ),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/edit'),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('New entry'),
      ),
    );
  }
}

class _JournalImageCard extends StatelessWidget {
  const _JournalImageCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final imagePath = entry.imagePath!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 120,
        child: imagePath.startsWith('http')
            ? Image.network(imagePath, fit: BoxFit.cover)
            : Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
      ),
    );
  }
}

class _JournalTile extends ConsumerWidget {
  const _JournalTile({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = (entry.imagePath ?? '').isNotEmpty;
    final isRemoteImage = hasImage && entry.imagePath!.startsWith('http');
    final imageExists = isRemoteImage || (hasImage ? File(entry.imagePath!).existsSync() : false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => context.push('/journal/edit', extra: entry),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageExists)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: isRemoteImage
                      ? Image.network(
                          entry.imagePath!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        )
                      : Image.file(
                          File(entry.imagePath!),
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                        ),
                ),
              if (hasImage && !imageExists)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'This image is no longer available on the device. New journal photos will now be saved permanently.',
                  ),
                ),
              if (hasImage) const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  IconButton(
                    onPressed: () => ref.read(journalControllerProvider.notifier).deleteEntry(entry.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                entry.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                [
                  MindBloomDateUtils.prettyDateTime(entry.createdAt),
                  if ((entry.mood ?? '').isNotEmpty) entry.mood!,
                  if ((entry.locationName ?? '').isNotEmpty) entry.locationName!,
                ].join(' • '),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
