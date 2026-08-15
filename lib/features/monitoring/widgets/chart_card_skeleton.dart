import 'package:flutter/material.dart';

import '../../../core/theme/tokens/respi_shapes.dart';
import '../../../core/theme/tokens/respi_spacing.dart';

/// Loading skeleton for [ClinicalChartCard] — shown while historical data
/// is being fetched.
///
/// Mirrors the card's structure (header, latest value placeholder + trend badge)
/// with shimmering placeholders so the layout doesn't jump when real data
/// arrives.
class ChartCardSkeleton extends StatelessWidget {
  const ChartCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shimmerColor = cs.onSurfaceVariant.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: RespiShapes.xlRadius,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(RespiSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header skeleton: type label + latest value placeholder + trend badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(
                      width: 80,
                      height: 16,
                      color: shimmerColor,
                    ),
                    const SizedBox(height: RespiSpacing.xxs),
                    _ShimmerBox(
                      width: 120,
                      height: 24,
                      color: shimmerColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: RespiSpacing.sm),
              // Trend badge placeholder
              _ShimmerBox(
                width: 72,
                height: 24,
                color: shimmerColor,
                borderRadius: 12,
              ),
            ],
          ),
          const SizedBox(height: RespiSpacing.md),

          // Chart area skeleton
          _ShimmerBox(
            width: double.infinity,
            height: 200,
            color: shimmerColor,
            borderRadiusValue: RespiShapes.mdValue,
          ),

          // Footer skeleton
          const SizedBox(height: RespiSpacing.xs),
          Row(
            children: [
              _ShimmerBox(
                width: 100,
                height: 16,
                color: shimmerColor,
              ),
              const SizedBox(width: RespiSpacing.md),
              _ShimmerBox(
                width: 140,
                height: 16,
                color: shimmerColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A rectangular placeholder with a subtle shimmer effect.
class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius,
    this.borderRadiusValue,
  });

  final double width;
  final double height;
  final Color color;
  final double? borderRadius;
  final double? borderRadiusValue;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
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
      builder: (_, __) {
        final gradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            widget.color,
            widget.color.withValues(alpha: 0.06),
            widget.color,
          ],
          stops: const [0.0, 0.5, 1.0],
        );

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: gradient,
            borderRadius: widget.borderRadius != null
                ? BorderRadius.circular(widget.borderRadius!)
                : widget.borderRadiusValue != null
                    ? BorderRadius.circular(widget.borderRadiusValue!)
                    : null,
          ),
        );
      },
    );
  }
}