import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/widgets/section_card.dart';
import '../providers/settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final lockActions = ref.read(appSessionProvider.notifier);
    final backendHealth = ref.watch(backendHealthProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Privacy & Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 18),
        settingsAsync.when(
          data: (settings) => Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Use this page to test privacy features. Set a passcode, enable biometrics, then tap "Lock app now" to see the lock screen immediately.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.plum),
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Biometric unlock'),
                      subtitle: const Text('Use fingerprint or face unlock where available'),
                      value: settings.biometricsEnabled,
                      onChanged: (value) async {
                        await ref.read(settingsControllerProvider.notifier).setBiometricsEnabled(value);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(settings.passcodeEnabled ? 'Change passcode' : 'Set passcode'),
                      subtitle: const Text('Fallback lock for personal wellness entries'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showPasscodeSheet(context, ref),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_clock_outlined),
                      title: const Text('Lock app now'),
                      subtitle: const Text('Quick way to test passcode or biometric unlock'),
                      onTap: lockActions.lock,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fingerprint),
                      title: const Text('Try biometric authentication'),
                      subtitle: const Text('Checks whether biometrics are available on this phone'),
                      onTap: () async {
                        final success = await ref.read(biometricServiceProvider).authenticate();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success ? 'Biometric authentication worked.' : 'Biometric authentication was unavailable or cancelled.',
                            ),
                          ),
                        );
                      },
                    ),
                    if (settings.passcodeEnabled)
                      TextButton(
                        onPressed: () => ref.read(settingsControllerProvider.notifier).disablePasscode(),
                        child: const Text('Disable passcode'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily journal reminder'),
                  subtitle: Text(
                    settings.journalReminderHour == null
                        ? 'Not scheduled'
                        : 'Scheduled at ${TimeOfDay(hour: settings.journalReminderHour!, minute: settings.journalReminderMinute ?? 0).format(context)}',
                  ),
                  trailing: const Icon(Icons.notifications_active_outlined),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.journalReminderHour ?? 20,
                        minute: settings.journalReminderMinute ?? 0,
                      ),
                    );
                    if (picked != null) {
                      await ref.read(settingsControllerProvider.notifier).setJournalReminder(
                            hour: picked.hour,
                            minute: picked.minute,
                          );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cloud_sync_outlined),
                      title: const Text('Remote sync status'),
                      subtitle: Text(
                        backendHealth.when(
                          data: (connected) => connected
                              ? 'Connected to your PHP backend. New entries should sync to MySQL.'
                              : 'Not connected yet. Add your deployed API URL below and test the connection.',
                          error: (error, stackTrace) => 'Backend check failed: $error',
                          loading: () => 'Checking backend connection...',
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.link_outlined),
                      title: const Text('Backend URL'),
                      subtitle: Text(
                        settings.apiBaseUrl?.isNotEmpty == true
                            ? settings.apiBaseUrl!
                            : 'Not configured',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showBackendSheet(context, ref, settings.apiBaseUrl),
                    ),
                  ],
                ),
              ),
            ],
          ),
          error: (error, _) => Text('Unable to load settings: $error'),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Future<void> _showPasscodeSheet(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set Passcode', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: '4+ digit passcode'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (controller.text.trim().length < 4) return;
                  await ref.read(settingsControllerProvider.notifier).setPasscode(controller.text.trim());
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Save passcode'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showBackendSheet(BuildContext context, WidgetRef ref, String? currentUrl) async {
    final controller = TextEditingController(text: currentUrl ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connect PHP Backend', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              const Text('Use the deployed folder URL, for example: https://your-domain.com/mindbloom_api'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'API base URL'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final url = controller.text.trim();
                  if (url.isEmpty) return;
                  await ref.read(settingsControllerProvider.notifier).setApiBaseUrl(url);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text('Save backend URL'),
              ),
            ],
          ),
        );
      },
    );
  }
}
