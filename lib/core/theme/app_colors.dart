import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Neutral Base (from PRD Section 21)
  static const Color background = Color(0xFF0B0D10);
  static const Color surface = Color(0xFF12151A);
  static const Color elevatedSurface = Color(0xFF181C22);
  static const Color border = Color(0xFF252A32);
  static const Color borderSubtle = Color(0xFF1E232B);

  // Typography
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF9AA1AC);
  static const Color textMuted = Color(0xFF6B7280);

  // Brand Accent
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color accentGlow = Color(0x336366F1);

  // Status & Priority Colors (Semantic)
  static const Color highPriority = Color(0xFFEF4444); // Red
  static const Color mediumPriority = Color(0xFFF59E0B); // Amber
  static const Color lowPriority = Color(0xFF94A3B8); // Slate / Low

  static const Color statusTodo = Color(0xFF94A3B8);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF10B981);

  static const Color overdue = Color(0xFFEF4444);
  static const Color dueToday = Color(0xFFF59E0B);
  static const Color dueSoon = Color(0xFF3B82F6);

  // Cards & Interactive
  static const Color cardHover = Color(0xFF1F242D);
  static const Color inputBackground = Color(0xFF161A21);
}
