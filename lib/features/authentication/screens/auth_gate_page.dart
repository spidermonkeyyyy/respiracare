import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/components/buttons/respi_button.dart';
import '../../../core/navigation/route_names.dart';
import '../../../core/theme/tokens/respi_spacing.dart';
import '../../../core/theme/tokens/respi_typography.dart';
import '../widgets/breathing_animation.dart';

/// Entry point for unauthenticated users.
/// Presents a branded landing with clear pathways to sign in or sign up.
class AuthGatePage extends StatelessWidget {
  const AuthGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(RespiSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),
              const BreathingAnimation(size: 140),
              const SizedBox(height: RespiSpacing.xl),
              Text(
                'RespiraCare',
                style: RespiTypography.headlineLarge.copyWith(
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: RespiSpacing.sm),
              Text(
                'Nurse-led respiratory monitoring',
                style: RespiTypography.bodyLarge.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              RespiButton(
                label: 'Get Started',
                onPressed: () => context.push(RouteNames.signUp),
                variant: RespiButtonVariant.primary,
                fullWidth: true,
              ),
              const SizedBox(height: RespiSpacing.md),
              RespiButton(
                label: 'I already have an account',
                onPressed: () => context.push(RouteNames.signIn),
                variant: RespiButtonVariant.outlined,
                fullWidth: true,
              ),
              const SizedBox(height: RespiSpacing.lg),
              // Emergency access for patients in distress
              TextButton.icon(
                onPressed: () => _showEmergencyInfo(context),
                icon: const Icon(Icons.emergency, color: Colors.red),
                label: Text(
                  'Need immediate help?',
                  style: RespiTypography.labelMedium.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(height: RespiSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.emergency, color: Colors.red, size: 48),
        title: const Text('Emergency'),
        content: const Text(
          'If you are experiencing severe breathing difficulty, '
          'please call your local emergency number immediately.\n\n'
          'RespiraCare is not a replacement for emergency medical services.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
