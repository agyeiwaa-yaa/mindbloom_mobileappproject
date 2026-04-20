import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../settings/presentation/providers/settings_controller.dart';

class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).asData?.value;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCE7DF), Color(0xFFF7F4EE)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 40),
                    const SizedBox(height: 12),
                    Text('Private wellness space', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    if (settings?.passcodeEnabled == true) ...[
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Passcode',
                          errorText: _error,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () async {
                          final valid = await ref
                              .read(settingsControllerProvider.notifier)
                              .validatePasscode(_controller.text.trim());
                          if (!valid) {
                            setState(() => _error = 'Incorrect passcode');
                            return;
                          }
                          ref.read(appSessionProvider.notifier).unlock();
                        },
                        child: const Text('Unlock with passcode'),
                      ),
                    ],
                    if (settings?.biometricsEnabled == true) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final success = await ref.read(biometricServiceProvider).authenticate();
                          if (success) {
                            ref.read(appSessionProvider.notifier).unlock();
                          }
                        },
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Use biometrics'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
