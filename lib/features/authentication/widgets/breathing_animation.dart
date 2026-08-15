import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accessibility/reduced_motion_provider.dart';
import '../../../core/theme/tokens/respi_colors.dart';

/// A breathing lung-expansion animation for the splash screen.
///
/// Respects reduced motion preferences — becomes a static pulsing
/// opacity effect instead of scale animation when enabled.
class BreathingAnimation extends ConsumerStatefulWidget {
  const BreathingAnimation({
    super.key,
    this.size = 120,
    this.duration = const Duration(milliseconds: 4000),
  });

  final double size;
  final Duration duration;

  @override
  ConsumerState<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends ConsumerState<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    final reducedMotion = ref.read(reducedMotionProvider);

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (reducedMotion) {
      // Subtle opacity pulse for reduced motion
      _opacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
    } else {
      // Gentle scale expansion simulating breathing
      _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: const _LungPainter(
                color: RespiColors.primary,
                strokeWidth: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LungPainter extends CustomPainter {
  const _LungPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width * 0.35;
    final height = size.height * 0.45;

    // Left lung
    final leftLungPath = Path()
      ..moveTo(center.dx, center.dy - height * 0.3)
      ..quadraticBezierTo(
        center.dx - width * 1.2,
        center.dy - height * 0.1,
        center.dx - width,
        center.dy + height * 0.3,
      )
      ..quadraticBezierTo(
        center.dx - width * 0.6,
        center.dy + height * 0.6,
        center.dx - width * 0.2,
        center.dy + height * 0.5,
      )
      ..quadraticBezierTo(
        center.dx - width * 0.1,
        center.dy + height * 0.2,
        center.dx,
        center.dy + height * 0.1,
      );

    // Right lung (mirrored)
    final rightLungPath = Path()
      ..moveTo(center.dx, center.dy - height * 0.3)
      ..quadraticBezierTo(
        center.dx + width * 1.2,
        center.dy - height * 0.1,
        center.dx + width,
        center.dy + height * 0.3,
      )
      ..quadraticBezierTo(
        center.dx + width * 0.6,
        center.dy + height * 0.6,
        center.dx + width * 0.2,
        center.dy + height * 0.5,
      )
      ..quadraticBezierTo(
        center.dx + width * 0.1,
        center.dy + height * 0.2,
        center.dx,
        center.dy + height * 0.1,
      );

    // Trachea
    final tracheaPath = Path()
      ..moveTo(center.dx, center.dy - height * 0.5)
      ..lineTo(center.dx, center.dy - height * 0.3);

    canvas.drawPath(leftLungPath, paint);
    canvas.drawPath(rightLungPath, paint);
    canvas.drawPath(tracheaPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
