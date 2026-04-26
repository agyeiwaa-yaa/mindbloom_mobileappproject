import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/providers/core_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      try {
        final api = ref.read(apiServiceProvider);
        if (await api.isConfigured()) {
          await ref.read(mindBloomRepositoryProvider).syncLocalCacheToRemote();
        }
      } catch (_) {
        // Ignore startup sync issues and let the app continue normally.
      }
    });
    _timer = Timer(const Duration(milliseconds: 1900), () {
      if (mounted) {
        context.go('/entry');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF6FB),
              Color(0xFFFFE6F1),
              Color(0xFFF9D5E7),
            ],
          ),
        ),
        child: Stack(
          children: [
            const _GlowOrb(top: -50, right: -10, size: 190, color: Color(0x80F7B5D0)),
            const _GlowOrb(top: 120, left: -35, size: 140, color: Color(0x66DFA4C1)),
            const _GlowOrb(bottom: -25, right: 22, size: 160, color: Color(0x55F6C7D9)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      width: 102,
                      height: 102,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26B74D79),
                            blurRadius: 24,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.spa_rounded,
                        size: 54,
                        color: AppColors.berry,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'MindBloom',
                      style: textTheme.displaySmall?.copyWith(
                        color: AppColors.plum,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A calm, supportive wellness journal for clients, therapists, and mindful daily care.',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        'Track mood patterns, capture reflective journal moments, support healthy routines, and bring clearer wellbeing insight into therapy conversations.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.muted,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.berry,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Preparing your wellness space...',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.plum,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
