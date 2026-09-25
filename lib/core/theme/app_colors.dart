import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark Neutral Base
  static const Color background = Color(0xFF0B0D10);
  static const Color surface = Color(0xFF12151A);
  static const Color elevatedSurface = Color(0xFF1A1E2B);
  static const Color border = Color(0xFF252A32);
  static const Color borderSubtle = Color(0xFF1E232B);

  // High Contrast Text
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFF9AA1AC);
  static const Color textMuted = Color(0xFF6B7280);

  // Professional Blue Accent (NO PURPLE)
  static const Color primary = Color(0xFF3B82F6); // Professional Blue
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color accentGlow = Color(0x263B82F6);

  // Minimal Semantic Status Colors
  static const Color highPriority = Color(0xFFEF4444); // Red
  static const Color mediumPriority = Color(0xFFF59E0B); // Amber
  static const Color lowPriority = Color(0xFF64748B); // Slate

  static const Color statusTodo = Color(0xFF64748B);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF10B981);

  static const Color overdue = Color(0xFFEF4444);
  static const Color dueToday = Color(0xFFF59E0B);
  static const Color dueSoon = Color(0xFF3B82F6);

  // Input & Modal background
  static const Color inputBackground = Color(0xFF161A21);
}
