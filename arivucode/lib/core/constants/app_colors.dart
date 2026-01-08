import 'package:flutter/material.dart';

/// App-wide color palette optimized for dark theme and code readability
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============ Primary Colors ============
  static const Color primary = Color(0xFF6C63FF); // Vibrant purple
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF5449E0);
  
  static const Color secondary = Color(0xFF00D9FF); // Cyan accent
  static const Color secondaryLight = Color(0xFF4DE4FF);
  static const Color secondaryDark = Color(0xFF00B8D9);

  // ============ Background Colors ============
  static const Color backgroundDark = Color(0xFF0F0F1E); // Deep dark blue
  static const Color backgroundMedium = Color(0xFF1A1A2E); // Card background
  static const Color backgroundLight = Color(0xFF25254A); // Elevated surfaces
  
  // ============ Surface Colors ============
  static const Color surface = Color(0xFF1E1E3F);
  static const Color surfaceVariant = Color(0xFF2A2A4A);
  
  // ============ Text Colors ============
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color textTertiary = Color(0xFF7E7E9A);
  static const Color textDisabled = Color(0xFF4A4A5E);

  // ============ Semantic Colors ============
  static const Color success = Color(0xFF00E676); // Bright green
  static const Color successDark = Color(0xFF00C853);
  
  static const Color error = Color(0xFFFF5252); // Bright red
  static const Color errorDark = Color(0xFFE53935);
  
  static const Color warning = Color(0xFFFFAB40); // Orange
  static const Color warningDark = Color(0xFFFF9100);
  
  static const Color info = Color(0xFF40C4FF); // Light blue
  static const Color infoDark = Color(0xFF00B0FF);

  // ============ Difficulty Colors ============
  static const Color difficultyEasy = Color(0xFF00E676); // Green
  static const Color difficultyMedium = Color(0xFFFFD740); // Yellow
  static const Color difficultyHard = Color(0xFFFF5252); // Red

  // ============ Syntax Highlighting Colors ============
  static const Color syntaxKeyword = Color(0xFFFF79C6); // Pink
  static const Color syntaxString = Color(0xFFF1FA8C); // Yellow
  static const Color syntaxComment = Color(0xFF6272A4); // Blue-gray
  static const Color syntaxNumber = Color(0xFFBD93F9); // Purple
  static const Color syntaxFunction = Color(0xFF50FA7B); // Green
  static const Color syntaxClass = Color(0xFF8BE9FD); // Cyan
  static const Color syntaxOperator = Color(0xFFFF79C6); // Pink
  static const Color syntaxVariable = Color(0xFFF8F8F2); // White

  // ============ Gradient Colors ============
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, backgroundMedium],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Special Effects ============
  static const Color shimmerBase = Color(0xFF1A1A2E);
  static const Color shimmerHighlight = Color(0xFF25254A);
  
  static const Color divider = Color(0xFF2A2A4A);
  static const Color border = Color(0xFF3A3A5A);
  
  // Streak fire colors
  static const Color streakFire1 = Color(0xFFFF6B35); // Orange
  static const Color streakFire2 = Color(0xFFFF9F1C); // Yellow-orange
  static const Color streakFire3 = Color(0xFFFFC300); // Yellow
  
  static const LinearGradient streakGradient = LinearGradient(
    colors: [streakFire1, streakFire2, streakFire3],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============ Overlay Colors ============
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0xB3000000); // 70% black
}
