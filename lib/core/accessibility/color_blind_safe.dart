import 'package:flutter/material.dart';

/// Patterns and icons for color-blind safe status indication.
///
/// Never rely on color alone for critical clinical information.
/// Always pair with an icon, text label, or pattern.
class ColorBlindSafe {
  ColorBlindSafe._();

  // ─── Icons by semantic meaning ─────────────────────────────
  static const IconData iconSuccess = Icons.check_circle;
  static const IconData iconWarning = Icons.warning;
  static const IconData iconError = Icons.error;
  static const IconData iconInfo = Icons.info;
  static const IconData iconNeutral = Icons.circle;

  // ─── Text labels ───────────────────────────────────────────
  static const String labelSuccess = 'Normal';
  static const String labelWarning = 'Attention';
  static const String labelError = 'Critical';
  static const String labelInfo = 'Info';

  // ─── Patterns (for charts and graphs) ──────────────────────
  static const List<double> patternSolid = [];
  static const List<double> patternDashed = [4, 4];
  static const List<double> patternDotted = [1, 3];
  static const List<double> patternDashDot = [4, 2, 1, 2];
}

/// A status indicator that works for all types of color vision.
class AccessibleStatusIndicator extends StatelessWidget {
  const AccessibleStatusIndicator({
    super.key,
    required this.status,
    this.showLabel = true,
    this.showIcon = true,
    this.size = 16,
  });

  final RespiStatus status;
  final bool showLabel;
  final bool showIcon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (color, icon, label) = switch (status) {
      RespiStatus.normal => (const Color(0xFF2E8B57), ColorBlindSafe.iconSuccess, ColorBlindSafe.labelSuccess),
      RespiStatus.warning => (const Color(0xFFE6A23C), ColorBlindSafe.iconWarning, ColorBlindSafe.labelWarning),
      RespiStatus.critical => (const Color(0xFFC23B22), ColorBlindSafe.iconError, ColorBlindSafe.labelError),
      RespiStatus.info => (cs.primary, ColorBlindSafe.iconInfo, ColorBlindSafe.labelInfo),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(icon, color: color, size: size),
          const SizedBox(width: 4),
        ],
        if (showLabel)
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: size * 0.875,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

enum RespiStatus { normal, warning, critical, info }
