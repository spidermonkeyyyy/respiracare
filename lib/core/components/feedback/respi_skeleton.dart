import 'package:flutter/material.dart';
import '../../theme/tokens/respi_shapes.dart';
import '../../theme/tokens/respi_spacing.dart';

/// Shimmer-free skeleton loader using pulsing opacity.
class RespiSkeleton extends StatefulWidget {
  const RespiSkeleton({
    super.key,
    this.width,
    this.height = RespiSpacing.lg,
    this.borderRadius = const BorderRadius.all(RespiShapes.sm),
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<RespiSkeleton> createState() => _RespiSkeletonState();
}

class _RespiSkeletonState extends State<RespiSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: _animation.value * 0.1),
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

/// Pre-built skeleton layout for cards.
class RespiSkeletonCard extends StatelessWidget {
  const RespiSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RespiSkeleton(width: double.infinity, height: 180),
        SizedBox(height: RespiSpacing.md),
        RespiSkeleton(width: 200),
        SizedBox(height: RespiSpacing.sm),
        RespiSkeleton(width: 140),
      ],
    );
  }
}
