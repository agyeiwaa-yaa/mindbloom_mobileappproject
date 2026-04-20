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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cloud_sync_outlined),
                      title: const Text('Remote sync status'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          _SyncStatusBadge(backendHealth: backendHealth),
                          const SizedBox(height: 10),
                          Text(
                            backendHealth.when(
                              data: (connected) => connected
                                  ? 'Connected to your PHP backend. New entries should sync to your MySQL database.'
                                  : settings.apiBaseUrl?.isNotEmpty == true
                                      ? 'The API URL is saved, but the health check is failing. Confirm the URL ends with /api and that health.php opens in a browser.'
                                      : 'No backend URL is configured yet. Add your deployed API folder URL below to turn on real remote sync.',
                              error: (error, stackTrace) => 'Backend check failed: $error',
                              loading: () => 'Checking backend connection...',
                            ),
                          ),
                        ],
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () async {
                            ref.invalidate(backendHealthProvider);
                            final connected = await ref.read(backendHealthProvider.future);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  connected
                                      ? 'Backend connection worked. Remote sync is ready.'
                                      : 'Still not connected. Check the URL, config.php, schema import, and uploads folder permissions.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.wifi_find),
                          label: const Text('Test connection'),
                        ),
                        if (settings.apiBaseUrl?.isNotEmpty == true)
                          TextButton.icon(
                            onPressed: () async {
                              await ref.read(settingsControllerProvider.notifier).clearApiBaseUrl();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Backend URL cleared. The app will stay in local-only mode until you reconnect.')),
                              );
                            },
                            icon: const Icon(Icons.link_off),
                            label: const Text('Clear URL'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.blush.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Deployment checklist',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8),
                          Text('1. Upload the backend/api folder to your hosting.'),
                          Text('2. Create api/config.php on the server with your MySQL credentials.'),
                          Text('3. Import backend/sql/schema.sql into phpMyAdmin.'),
                          Text('4. Open your deployed health.php in a browser and confirm it returns success.'),
                          Text('5. Paste the folder URL ending in /api here.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.blush),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What URL should I use?', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 8),
                          const Text('Use the public folder that contains health.php, moods.php, journals.php, and habits.php.'),
                          const SizedBox(height: 8),
                          SelectableText(
                            'Example: https://your-domain.com/mindbloom_api/api',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.plum),
                          ),
                          const SizedBox(height: 8),
                          const Text('Your phpMyAdmin page is not the API URL. It is only the database management page.'),
                        ],
                      ),
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
              const Text('Use the deployed API folder URL that ends with /api.'),
              const SizedBox(height: 8),
              const Text('Example: https://your-domain.com/mindbloom_api/api'),
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
                  final connected = await ref.read(backendHealthProvider.future);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        connected
                            ? 'Backend connected successfully.'
                            : 'URL saved, but the server is not reachable yet. Check health.php and config.php on your hosting.',
                      ),
                    ),
                  );
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

class _SyncStatusBadge extends StatelessWidget {
  const _SyncStatusBadge({required this.backendHealth});

  final AsyncValue<bool> backendHealth;

  @override
  Widget build(BuildContext context) {
    final (label, color) = backendHealth.when(
      data: (connected) => connected
          ? ('Connected to remote database', const Color(0xFF1F8A5B))
          : ('Waiting for backend connection', const Color(0xFFB66A11)),
      error: (error, stackTrace) => ('Connection check failed', Colors.red.shade700),
      loading: () => ('Checking backend...', AppColors.plum),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
