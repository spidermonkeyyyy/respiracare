import 'package:flutter/material.dart';

/// RespiraCare Semantic Color Architecture
/// Design Tokens established in Phase 2.3 Visual Design System
abstract class AppColors {
  // Brand Identity
  static const Color primary = Color(0xFF0284C7); // Respiratory Blue
  static const Color secondary = Color(0xFF0D9488); // Respiratory Green / Teal
  static const Color accent = Color(0xFF06B6D4); // Soft Teal

  // Semantic Status Tokens
  static const Color success = Color(0xFF16A34A); // Clinical Green (Healthy / Completed)
  static const Color warning = Color(0xFFD97706); // Amber (Review Required / Variance)
  static const Color danger = Color(0xFFDC2626); // Urgent Red (Strictly Reserved for Urgent Escalations)
  static const Color info = Color(0xFF2563EB); // Information Blue

  // Neutrals & Surfaces
  static const Color textPrimary = Color(0xFF0F172A); // Slate Dark (Headings & Primary Text)
  static const Color textSecondary = Color(0xFF475569); // Slate Medium (Body & Subtitles)
  static const Color textMuted = Color(0xFF94A3B8); // Slate Light Muted Text

  static const Color background = Color(0xFFF8FAFC); // Main Screen Canvas Background
  static const Color surface = Color(0xFFFFFFFF); // Card Surface Background
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Input & Soft Container Fill
  static const Color border = Color(0xFFE2E8F0); // Container Border Divider
}
