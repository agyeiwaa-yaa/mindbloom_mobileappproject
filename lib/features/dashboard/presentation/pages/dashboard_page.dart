import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/services/sensor_service.dart';
import '../../../../core/utils/streak_utils.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../habits/presentation/providers/habits_controller.dart';
import '../../../journal/presentation/providers/journal_controller.dart';
import '../../../mood/models/mood_entry.dart';
import '../../../mood/presentation/providers/mood_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moods = ref.watch(moodControllerProvider).asData?.value ?? [];
    final journals = ref.watch(journalControllerProvider).asData?.value ?? [];
    final habits = ref.watch(habitsControllerProvider).asData?.value ?? [];
    final activityAsync = ref.watch(activityProvider);

    final averageMood = moods.isEmpty
        ? 0.0
        : moods.map((entry) => entry.score).reduce((a, b) => a + b) / moods.length;
    final strongestHabitStreak = habits.isEmpty
        ? 0
        : habits.map((record) => calculateCurrentStreak(record.completedDates)).reduce((a, b) => a > b ? a : b);

    final moodSpots = moods.take(7).toList().reversed.toList();
    final locationInsights = _buildLocationInsight(moods);
    final latestActivity = activityAsync.asData?.value;
    final mapMoods = moods.where((entry) => entry.latitude != null && entry.longitude != null).toList();
    final bestMood = mapMoods.isEmpty
        ? null
        : mapMoods.reduce((a, b) => a.score >= b.score ? a : b);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.berry,
                AppColors.plum,
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s wellness snapshot',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'A calm overview of your mood, consistency, and reflection habits.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _StatCard(title: 'Average Mood', value: averageMood == 0 ? '--' : averageMood.toStringAsFixed(1)),
            _StatCard(title: 'Journal Entries', value: '${journals.length}'),
            _StatCard(title: 'Best Habit Streak', value: '$strongestHabitStreak days'),
            _StatCard(
              title: 'Activity Signal',
              value: latestActivity?.label ?? 'Pending',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (moodSpots.isNotEmpty)
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood trend', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 18),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      minY: 1,
                      maxY: 5,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            for (var i = 0; i < moodSpots.length; i++)
                              FlSpot(i.toDouble(), moodSpots[i].score.toDouble()),
                          ],
                          isCurved: true,
                          color: Theme.of(context).colorScheme.primary,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Location insight', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(locationInsights),
            ],
          ),
        ),
        if (mapMoods.isNotEmpty) ...[
          const SizedBox(height: 12),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mood map', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  bestMood == null
                      ? 'Attach location to mood entries to see your calmest places.'
                      : 'The highlighted point marks one of your highest mood check-ins.',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 240,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(bestMood!.latitude!, bestMood.longitude!),
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.maamebasoah.mindbloom',
                        ),
                        MarkerLayer(
                          markers: mapMoods
                              .map(
                                (entry) => Marker(
                                  point: LatLng(entry.latitude!, entry.longitude!),
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.location_on,
                                    color: entry.id == bestMood.id ? AppColors.berry : _moodColor(entry.score),
                                    size: entry.id == bestMood.id ? 40 : 32,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        RichAttributionWidget(
                          attributions: const [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        SectionCard(
          child: _SensorStoryCard(snapshot: latestActivity),
        ),
      ],
    );
  }

  String _buildLocationInsight(List<MoodEntry> moods) {
    final byLocation = <String, List<int>>{};
    for (final mood in moods) {
      final location = mood.locationName;
      if (location == null || location.isEmpty) continue;
      byLocation.putIfAbsent(location, () => []);
      byLocation[location]!.add(mood.score);
    }
    if (byLocation.isEmpty) {
      return 'Enable location on check-ins to discover which environments support your calmest moments.';
    }
    final best = byLocation.entries.reduce((a, b) {
      final aAvg = a.value.reduce((x, y) => x + y) / a.value.length;
      final bAvg = b.value.reduce((x, y) => x + y) / b.value.length;
      return aAvg >= bAvg ? a : b;
    });
    return 'You tend to feel best around ${best.key}, based on your saved mood entries there.';
  }

  Color _moodColor(int score) {
    switch (score) {
      case 5:
        return AppColors.gold;
      case 4:
        return AppColors.berry;
      case 3:
        return AppColors.rose;
      case 2:
        return AppColors.coral;
      default:
        return AppColors.plum;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.plum,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

final activityProvider = StreamProvider((ref) {
  return ref.read(sensorServiceProvider).activityStream();
});

class _SensorStoryCard extends StatelessWidget {
  const _SensorStoryCard({required this.snapshot});

  final ActivitySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final prompt = snapshot?.wellnessPrompt ?? 'Move the phone a little and MindBloom will turn that motion into a small wellness suggestion.';
    final energy = (snapshot?.bloomScore ?? 0) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor activity', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          snapshot == null
              ? 'The accelerometer is ready. Once the device moves, this section will estimate your motion state and suggest a small next step.'
              : 'Current motion state: ${snapshot!.label} (${snapshot!.motionLevel.toStringAsFixed(2)}).',
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bloom energy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: energy.clamp(0, 1),
                      backgroundColor: AppColors.blush,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.berry),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '${snapshot?.bloomScore ?? 0}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.plum,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.blush.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            prompt,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
        if (snapshot?.shakeDetected == true) ...[
          const SizedBox(height: 10),
          Text(
            'Shake moments are treated like a quick energy spike, which can help you decide whether to log a mood, mark a habit, or add a short journal note.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ],
    );
  }
}
