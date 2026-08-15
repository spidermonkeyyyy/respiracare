import 'package:flutter/material.dart';
import '../../core/theme/tokens/respi_colors.dart';

/// RespiraCare Semantic Color Architecture
/// Updated to Claude Amber theme palette.
abstract class AppColors {
  // Brand Identity (Claude Amber)
  static const Color primary = RespiColors.primary;       // #C96442 warm amber/orange
  static const Color secondary = RespiColors.secondary;   // #E9E6DC warm sand
  static const Color accent = RespiColors.accent;         // #E9E6DC warm sand

  // Semantic Status Tokens
  static const Color success = Color(0xFF16A34A);  // Clinical Green (Healthy / Completed)
  static const Color warning = RespiColors.warning;      // #E8A838 amber (Review Required)
  static const Color danger = RespiColors.destructive;    // #141413 (Claude Amber dark mode danger)
  static const Color info = Color(0xFF2563EB); // Information Blue

  // Neutrals & Surfaces (Claude Amber)
  static const Color textPrimary = RespiColors.foreground;      // #3D3929
  static const Color textSecondary = RespiColors.mutedForeground; // #6E6D68
  static const Color textMuted = RespiColors.mutedForeground;    // #6E6D68

  static const Color background = RespiColors.background;        // #FAF9F5
  static const Color surface = RespiColors.card;                  // #F5F4EF
  static const Color surfaceVariant = RespiColors.muted;         // #EDE9DE
  static const Color border = RespiColors.border;                // #D9D6C9
}
