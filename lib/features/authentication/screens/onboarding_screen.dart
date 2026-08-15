import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../core/components/buttons/respi_button.dart";
import "../../../core/navigation/route_names.dart";
import "../../../core/theme/tokens/respi_colors.dart";
import "../../../core/theme/tokens/respi_spacing.dart";
import "../../../core/theme/tokens/respi_typography.dart";
import "../providers/auth_provider.dart";
import "../providers/onboarding_provider.dart";
import "../widgets/breathing_animation.dart";

/// Multi-step onboarding flow.
///
/// Steps:
/// 1. Welcome + breathing animation
/// 2. Role selection (Patient / Nurse)
/// 3. How remote monitoring works
/// 4. Privacy & consent
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final pages = [
      const _WelcomePage(),
      _RoleSelectionPage(),
      const _HowItWorksPage(),
      _ConsentPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(RespiSpacing.md),
              child: Row(
                children: List.generate(pages.length, (index) {
                  final isActive = index <= onboardingState.currentPage;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? RespiColors.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Page content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey(onboardingState.currentPage),
                  child: pages[onboardingState.currentPage],
                ),
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(RespiSpacing.screenPadding),
              child: Row(
                children: [
                  if (onboardingState.currentPage > 0)
                    Expanded(
                      child: RespiButton(
                        label: "Back",
                        variant: RespiButtonVariant.text,
                        onPressed: notifier.previousPage,
                      ),
                    ),
                  if (onboardingState.currentPage > 0)
                    const SizedBox(width: RespiSpacing.md),
                  Expanded(
                    flex: onboardingState.currentPage == 0 ? 1 : 2,
                    child: RespiButton(
                      label: onboardingState.currentPage == pages.length - 1
                          ? "Get Started"
                          : "Continue",
                      onPressed: () async {
                        if (onboardingState.currentPage == pages.length - 1) {
                          if (onboardingState.canProceed) {
                            notifier.completeOnboarding();
                            
                            // Save onboarding completion to SharedPreferences
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool("onboarding_completed", true);
                            
                            // Also call auth provider to sync
                            ref.read(authProvider.notifier).completeOnboarding();
                            
                            // Navigate to sign-up/role selection
                            if (!context.mounted) return;
                            context.go(RouteNames.signUp);
                          }
                        } else {
                          notifier.nextPage();
                        }
                      },
                      isLoading: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page 1: Welcome ────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(RespiSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BreathingAnimation(size: 160),
          const SizedBox(height: RespiSpacing.xxl),
          const Text(
            "Welcome to RespiraCare",
            style: RespiTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RespiSpacing.md),
          Text(
            "Your personal connection to better breathing. "
            "Track your health, stay in touch with your care team, "
            "and get support when you need it.",
            style: RespiTypography.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Role Selection ─────────────────────────────────
class _RoleSelectionPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(RespiSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "I am a...",
            style: RespiTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RespiSpacing.xxl),
          _RoleCard(
            icon: Icons.person_outline,
            title: "Patient",
            description:
                "I want to monitor my breathing and stay connected with my care team.",
            isSelected: state.selectedRole == "patient",
            onTap: () => notifier.selectRole("patient"),
          ),
          const SizedBox(height: RespiSpacing.lg),
          _RoleCard(
            icon: Icons.local_hospital_outlined,
            title: "Nurse",
            description:
                "I provide remote care and monitor my assigned patients.",
            isSelected: state.selectedRole == "nurse",
            onTap: () => notifier.selectRole("nurse"),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(RespiSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: cs.primary, width: 2)
              : Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: RespiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: RespiTypography.titleMedium.copyWith(
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: RespiSpacing.xs),
                  Text(
                    description,
                    style: RespiTypography.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

// ─── Page 3: How It Works ───────────────────────────────────
class _HowItWorksPage extends StatelessWidget {
  const _HowItWorksPage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(RespiSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "How It Works",
            style: RespiTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: RespiSpacing.xxl),
          _FeatureItem(
            icon: Icons.monitor_heart_outlined,
            title: "Record Your Vitals",
            description: "Log oxygen levels, heart rate, and symptoms daily.",
          ),
          SizedBox(height: RespiSpacing.lg),
          _FeatureItem(
            icon: Icons.chat_bubble_outline,
            title: "Stay Connected",
            description:
                "Message your care team anytime with questions or concerns.",
          ),
          SizedBox(height: RespiSpacing.lg),
          _FeatureItem(
            icon: Icons.notifications_active_outlined,
            title: "Get Alerts",
            description:
                "Your nurse is notified if your readings need attention.",
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(RespiSpacing.md),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cs.primary),
        ),
        const SizedBox(width: RespiSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RespiTypography.titleMedium),
              const SizedBox(height: RespiSpacing.xs),
              Text(
                description,
                style: RespiTypography.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Page 4: Consent ────────────────────────────────────────
class _ConsentPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(RespiSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Privacy & Consent",
            style: RespiTypography.headlineMedium,
          ),
          const SizedBox(height: RespiSpacing.lg),
          Text(
            "Before we begin, please review and accept the following:",
            style: RespiTypography.bodyLarge.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: RespiSpacing.xl),
          _ConsentCheckbox(
            value: state.acceptedTerms,
            onChanged: notifier.toggleTerms,
            title: "Terms of Service",
            description:
                "I agree to the Terms of Service and understand how RespiraCare works.",
          ),
          const SizedBox(height: RespiSpacing.lg),
          _ConsentCheckbox(
            value: state.acceptedPrivacy,
            onChanged: notifier.togglePrivacy,
            title: "Privacy Policy",
            description:
                "I consent to the collection and sharing of my health data with my assigned care team.",
          ),
          const Spacer(),
          if (!state.canProceed &&
              (state.acceptedTerms || state.acceptedPrivacy))
            Text(
              "Please accept both to continue",
              style: RespiTypography.bodySmall.copyWith(color: cs.error),
            ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.description,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(RespiSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: cs.primary,
            ),
            const SizedBox(width: RespiSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RespiTypography.titleMedium),
                  const SizedBox(height: RespiSpacing.xs),
                  Text(
                    description,
                    style: RespiTypography.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
