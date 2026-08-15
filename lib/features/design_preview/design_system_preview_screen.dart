import 'package:flutter/material.dart';
import '../../mock/mock_patients.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/radius.dart';
import '../../app/theme/shadows.dart';
import '../../app/theme/spacing.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/animations/app_animations.dart';
import '../../core/widgets/buttons/app_button.dart';
import '../../core/widgets/cards/alert_card.dart';
import '../../core/widgets/cards/app_card.dart';
import '../../core/widgets/cards/health_status_card.dart';
import '../../core/widgets/cards/metric_card.dart';
import '../../core/widgets/cards/progress_card.dart';
import '../../core/widgets/cards/video_card.dart';
import '../../core/widgets/feedback/app_empty_state.dart';
import '../../core/widgets/feedback/app_error_state.dart';
import '../../core/widgets/feedback/app_loading.dart';
import '../../core/widgets/inputs/app_input.dart';

class DesignSystemPreviewScreen extends StatefulWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  State<DesignSystemPreviewScreen> createState() =>
      _DesignSystemPreviewScreenState();
}

class _DesignSystemPreviewScreenState extends State<DesignSystemPreviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.palette_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'RespiraCare Design System',
              style: AppTypography.titleLarge
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Buttons'),
            Tab(text: 'Cards'),
            Tab(text: 'Inputs'),
            Tab(text: 'Feedback'),
            Tab(text: 'Theme Tokens'),
            Tab(text: 'Animations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildButtonsSection(),
          _buildCardsSection(),
          _buildInputsSection(),
          _buildFeedbackSection(),
          _buildThemeTokensSection(),
          _buildAnimationsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTypography.headlineLarge.copyWith(fontSize: 20.0)),
          const SizedBox(height: 2.0),
          Text(subtitle, style: AppTypography.secondaryText),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Button Component (AppButton)',
            'Supporting primary, secondary, outlined, danger, loading, and disabled states.'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Primary Variant',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Start Monitoring Check',
                icon: Icons.play_arrow_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Secondary Variant',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'View Symptoms History',
                variant: AppButtonVariant.secondary,
                icon: Icons.history_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Outlined Variant',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Download Care Summary',
                variant: AppButtonVariant.outlined,
                icon: Icons.download_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Danger Variant',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                text: 'Escalate Urgent Alert',
                variant: AppButtonVariant.danger,
                icon: Icons.warning_rounded,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Loading State',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              const AppButton(
                text: 'Submitting Data',
                loading: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Disabled State',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              const AppButton(
                text: 'Complete Questionnaire First',
                enabled: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardsSection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Card System Architecture',
            'Health status, metrics, nurse alerts, questionnaire progress, and video modules.'),
        Text('Health Status Cards (Color + Icon + Text Accessibility)',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        const HealthStatusCard(
          title: 'Respiratory Status',
          value: 'SpO₂ 96%',
          statusText: 'Stable',
          subtitle: 'Updated 10 minutes ago',
          variant: HealthStatusVariant.normal,
        ),
        const SizedBox(height: AppSpacing.sm),
        const HealthStatusCard(
          title: 'Respiratory Status',
          value: 'SpO₂ 91%',
          statusText: 'Review Required',
          subtitle: 'Drop detected — Nurse notified',
          variant: HealthStatusVariant.attention,
        ),
        const SizedBox(height: AppSpacing.sm),
        const HealthStatusCard(
          title: 'Weekly Questionnaire',
          value: 'CAT Score: 14',
          statusText: 'Information',
          subtitle: 'Moderate symptom impact',
          variant: HealthStatusVariant.information,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Metric Cards',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                label: 'Oxygen SpO₂',
                value: '95',
                unit: '%',
                trend: '↑ 2%',
                isTrendPositive: true,
                icon: Icons.air_rounded,
                onTap: () {},
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: MetricCard(
                label: 'CAT Symptoms',
                value: '18',
                unit: '/40',
                trend: '↓ 3 pts',
                isTrendPositive: false,
                icon: Icons.assignment_rounded,
                iconColor: AppColors.secondary,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Nurse Alert Cards',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        AlertCard(
          patientName: kPatientP1FullName,
          alertReason:
              'SpO₂ dropped below threshold (91%) during morning check.',
          timestamp: 'Today, 08:30 AM',
          state: AlertCardState.newAlert,
          actionLabel: 'Review Patient',
          onActionPressed: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        AlertCard(
          patientName: 'Fatima El-Khadir',
          alertReason: 'CAT Score increased by 5 points in past 48 hours.',
          timestamp: 'Yesterday, 16:45 PM',
          state: AlertCardState.reviewing,
          actionLabel: 'Continue Review',
          onActionPressed: () {},
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Progress & Video Cards',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        const ProgressCard(
          title: 'Daily Protocol Completion',
          subtitle: '3 of 4 tasks completed today',
          progress: 0.75,
          icon: Icons.task_alt_rounded,
        ),
        const SizedBox(height: AppSpacing.sm),
        VideoCard(
          title: 'Proper Inhaler Technique & Breathing Exercises',
          durationText: '04:15',
          categoryTag: 'Education',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildInputsSection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Input Components (AppInput)',
            'Accessible text input fields with labels, icons, error states, and toggleable password fields.'),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInput(
                label: 'Email / National ID',
                hint: 'e.g. patient@respiracare.org',
                prefixIcon: Icons.email_outlined,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: 'Password',
                hint: 'Enter your account password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: 'SpO₂ Measurement Value (%)',
                hint: 'e.g. 96',
                prefixIcon: Icons.speed_rounded,
                errorText: 'Value must be between 70% and 100%',
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: 'Observation Notes',
                hint: 'Describe any breathless episodes or cough severity...',
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Feedback & State Components',
            'Standardized loading indicators, empty states, and error handling states.'),
        Text('Loading State (AppLoading)',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        const AppCard(
          child: AppLoading(
              message: 'Syncing clinical data with RespiraCare cloud...'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Empty State (AppEmptyState)',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: AppEmptyState(
            title: 'No Measurements Yet Today',
            message:
                'You have not submitted your daily respiratory questionnaire or pulse oximetry reading yet.',
            icon: Icons.medical_services_outlined,
            actionLabel: 'Start Morning Check',
            onActionPressed: () {},
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Error State (AppErrorState)',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: AppErrorState(
            title: 'Unable to Connect to Oximeter',
            message:
                'Please ensure Bluetooth is enabled and your medical oximeter device is switched on.',
            retryLabel: 'Retry Bluetooth Scan',
            onRetry: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildThemeTokensSection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Theme Design Tokens',
            'Semantic colors, typography hierarchy, spacing grid, border radius, and soft shadows.'),
        Text('Semantic Color System',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildColorSwatch('Primary', AppColors.primary, '0xFF0284C7'),
            _buildColorSwatch('Secondary', AppColors.secondary, '0xFF0D9488'),
            _buildColorSwatch('Accent', AppColors.accent, '0xFF06B6D4'),
            _buildColorSwatch('Success', AppColors.success, '0xFF16A34A'),
            _buildColorSwatch('Warning', AppColors.warning, '0xFFD97706'),
            _buildColorSwatch('Danger', AppColors.danger, '0xFFDC2626'),
            _buildColorSwatch('Info', AppColors.info, '0xFF2563EB'),
            _buildColorSwatch('Text Dark', AppColors.textPrimary, '0xFF0F172A'),
            _buildColorSwatch('Text Muted', AppColors.textMuted, '0xFF94A3B8'),
            _buildColorSwatch('Background', AppColors.background, '0xFFF8FAFC',
                isLight: true),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Typography System',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        const AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Large (32px Bold)',
                  style: AppTypography.displayLarge),
              Divider(height: AppSpacing.lg),
              Text('Headline Large (24px Semibold)',
                  style: AppTypography.headlineLarge),
              Divider(height: AppSpacing.lg),
              Text('Title Large (20px Semibold)',
                  style: AppTypography.titleLarge),
              Divider(height: AppSpacing.lg),
              Text('Body Large (18px Regular)', style: AppTypography.bodyLarge),
              Divider(height: AppSpacing.lg),
              Text('Body Medium (16px Regular)',
                  style: AppTypography.bodyMedium),
              Divider(height: AppSpacing.lg),
              Text('Secondary Text (14px Medium)',
                  style: AppTypography.secondaryText),
              Divider(height: AppSpacing.lg),
              Text('Label Medium (12px Medium)',
                  style: AppTypography.labelMedium),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Radius & Shadows',
            style: AppTypography.titleLarge.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.smallBorderRadius,
                  boxShadow: AppShadows.small,
                ),
                child: const Text('Small Shadow\nRadius: 8px',
                    style: AppTypography.labelMedium,
                    textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mediumBorderRadius,
                  boxShadow: AppShadows.medium,
                ),
                child: const Text('Medium Shadow\nRadius: 16px',
                    style: AppTypography.labelMedium,
                    textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.largeBorderRadius,
                  boxShadow: AppShadows.large,
                ),
                child: const Text('Large Shadow\nRadius: 24px',
                    style: AppTypography.labelMedium,
                    textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String label, Color color, String hex,
      {bool isLight = false}) {
    return Container(
      width: 100.0,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.small - 2),
              border: isLight ? Border.all(color: AppColors.border) : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 11)),
          Text(hex,
              style: AppTypography.labelMedium
                  .copyWith(color: AppColors.textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildAnimationsSection() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _buildSectionHeader('Animation Foundation',
            'Smooth, non-intrusive healthcare motion using AppFadeAnimation, AppSlideAnimation, and AppScaleAnimation.'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fade Animation (Card Entrance)',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              const AppFadeAnimation(
                duration: AppAnimationDuration.normal,
                child: HealthStatusCard(
                  title: 'Animated Card',
                  value: 'Faded In smoothly',
                  statusText: 'Animated',
                  variant: HealthStatusVariant.normal,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Slide Animation (Bottom Up)',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              const AppSlideAnimation(
                duration: AppAnimationDuration.slow,
                direction: SlideDirection.up,
                child: ProgressCard(
                  title: 'Slided Up Smoothly',
                  progress: 1.0,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Scale Animation (Success Pop)',
                  style: AppTypography.titleLarge.copyWith(fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              AppScaleAnimation(
                duration: AppAnimationDuration.fast,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.task_alt_rounded,
                          color: AppColors.success, size: 28),
                      const SizedBox(width: AppSpacing.md),
                      Text('Scale Transition Pop Complete',
                          style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
