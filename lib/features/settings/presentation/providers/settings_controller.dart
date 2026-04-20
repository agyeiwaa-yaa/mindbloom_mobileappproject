import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../features/settings/models/app_settings_state.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettingsState>(SettingsController.new);

final appSessionProvider =
    NotifierProvider<AppSessionController, bool>(AppSessionController.new);

class SettingsController extends AsyncNotifier<AppSettingsState> {
  static const _passcodeKey = 'mindbloom_passcode';

  @override
  Future<AppSettingsState> build() async {
    final db = ref.read(databaseServiceProvider);
    final onboarding = await db.getSetting('onboarding_complete') == 'true';
    final biometrics = await db.getSetting('biometrics_enabled') == 'true';
    final passcode = await db.getSetting('passcode_enabled') == 'true';
    final reminderHour = int.tryParse((await db.getSetting('journal_reminder_hour')) ?? '');
    final reminderMinute = int.tryParse((await db.getSetting('journal_reminder_minute')) ?? '');
    return AppSettingsState(
      onboardingComplete: onboarding,
      biometricsEnabled: biometrics,
      passcodeEnabled: passcode,
      journalReminderHour: reminderHour,
      journalReminderMinute: reminderMinute,
    );
  }

  Future<void> completeOnboarding() async {
    await ref.read(databaseServiceProvider).setSetting('onboarding_complete', 'true');
    state = AsyncData((await future).copyWith(onboardingComplete: true));
    ref.read(appSessionProvider.notifier).unlock();
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await ref.read(databaseServiceProvider).setSetting('biometrics_enabled', enabled.toString());
    state = AsyncData((await future).copyWith(biometricsEnabled: enabled));
  }

  Future<void> setPasscode(String code) async {
    await ref.read(secureStorageProvider).write(key: _passcodeKey, value: code);
    await ref.read(databaseServiceProvider).setSetting('passcode_enabled', 'true');
    state = AsyncData((await future).copyWith(passcodeEnabled: true));
  }

  Future<void> disablePasscode() async {
    await ref.read(secureStorageProvider).delete(key: _passcodeKey);
    await ref.read(databaseServiceProvider).setSetting('passcode_enabled', 'false');
    state = AsyncData((await future).copyWith(passcodeEnabled: false));
  }

  Future<bool> validatePasscode(String attempt) async {
    final saved = await ref.read(secureStorageProvider).read(key: _passcodeKey);
    return saved != null && saved == attempt;
  }

  Future<void> setJournalReminder({required int hour, required int minute}) async {
    await ref.read(databaseServiceProvider).setSetting('journal_reminder_hour', '$hour');
    await ref.read(databaseServiceProvider).setSetting('journal_reminder_minute', '$minute');
    await ref.read(notificationServiceProvider).scheduleDaily(
          id: 9001,
          title: 'MindBloom journal reminder',
          body: 'Take a minute to check in with yourself today.',
          hour: hour,
          minute: minute,
        );
    state = AsyncData((await future).copyWith(
      journalReminderHour: hour,
      journalReminderMinute: minute,
    ));
  }
}

class AppSessionController extends Notifier<bool> {
  @override
  bool build() => false;

  void unlock() => state = true;

  void lock() => state = false;
}
