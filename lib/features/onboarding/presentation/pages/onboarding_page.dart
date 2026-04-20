import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_controller.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F4EE), Color(0xFFECE3D4), Color(0xFFDCE7DF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  'MindBloom',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A supportive daily space for mood tracking, journaling, habits, and quiet progress.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                const _FeatureLine(icon: Icons.favorite_outline, text: 'Daily mood tracking with notes'),
                const _FeatureLine(icon: Icons.menu_book_outlined, text: 'Journal entries with photo memories'),
                const _FeatureLine(icon: Icons.task_alt_outlined, text: 'Habit streaks and reminders'),
                const _FeatureLine(icon: Icons.lock_outline, text: 'Biometric or passcode privacy'),
                const Spacer(),
                FilledButton(
                  onPressed: () => ref.read(settingsControllerProvider.notifier).completeOnboarding(),
                  child: const Text('Enter MindBloom'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
