import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/radius.dart';
import '../../../app/theme/spacing.dart';

class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final color =
            AppColors.surfaceVariant.withValues(alpha: _animation.value);
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Header skeleton
            _buildBox(height: 24, width: 140, color: color),
            const SizedBox(height: AppSpacing.xs),
            _buildBox(height: 32, width: 220, color: color),
            const SizedBox(height: AppSpacing.lg),

            // Health Status skeleton
            _buildCardSkeleton(height: 110, color: color),
            const SizedBox(height: AppSpacing.md),

            // Daily Monitoring skeleton
            _buildCardSkeleton(height: 180, color: color),
            const SizedBox(height: AppSpacing.md),

            // Medication skeleton
            _buildCardSkeleton(height: 100, color: color),
            const SizedBox(height: AppSpacing.md),

            // Rehabilitation skeleton
            _buildCardSkeleton(height: 130, color: color),
          ],
        );
      },
    );
  }

  Widget _buildBox(
      {required double height, required double width, required Color color}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
  }

  Widget _buildCardSkeleton({required double height, required Color color}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBox(height: 20, width: 160, color: color),
          const SizedBox(height: AppSpacing.md),
          _buildBox(height: 16, width: double.infinity, color: color),
          const SizedBox(height: AppSpacing.sm),
          _buildBox(height: 16, width: 200, color: color),
        ],
      ),
    );
  }
}
