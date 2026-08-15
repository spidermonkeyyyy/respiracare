import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/route_names.dart';
import '../../../core/theme/tokens/respi_colors.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../widgets/breathing_animation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Keep splash animation short (~1.2 seconds max)
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.status == AuthStatus.authenticated &&
        authState.currentUser != null) {
      if (authState.currentUser!.role == UserRole.nurse) {
        context.go(RouteNames.nurseDashboard);
      } else {
        context.go(RouteNames.patientHome);
      }
    } else if (authState.isOnboardingCompleted) {
      context.go(RouteNames.signIn);
    } else {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Breathing lung animation
              const BreathingAnimation(size: 140),
              const SizedBox(height: RespiSpacing.xl),
              // Wordmark
              Text(
                'RespiraCare',
                style: RespiTypography.headlineLarge.copyWith(
                  color: RespiColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: RespiSpacing.sm),
              // Tagline
              Text(
                'Breathe easier with remote care',
                style: RespiTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Loading indicator
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: RespiSpacing.xl),
              // Version
              Text(
                'v1.0.0',
                style: RespiTypography.labelSmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: RespiSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
