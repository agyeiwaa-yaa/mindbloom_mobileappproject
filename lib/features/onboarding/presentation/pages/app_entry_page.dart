import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/presentation/pages/home_shell_page.dart';
import '../../../settings/presentation/providers/settings_controller.dart';
import 'lock_page.dart';
import 'onboarding_page.dart';

class AppEntryPage extends ConsumerWidget {
  const AppEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final unlocked = ref.watch(appSessionProvider);
    return settingsAsync.when(
      data: (settings) {
        final needsLock = settings.passcodeEnabled || settings.biometricsEnabled;
        if (!settings.onboardingComplete) {
          return const OnboardingPage();
        }
        if (needsLock && !unlocked) {
          return const LockPage();
        }
        return const HomeShellPage();
      },
      error: (error, _) => Scaffold(
        body: Center(child: Text('Unable to start app: $error')),
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
