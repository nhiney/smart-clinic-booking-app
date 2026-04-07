import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppColorTokens {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primarySurface;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color error;
  final Color success;
  final Color warning;
  final Color divider;

  const AppColorTokens({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primarySurface,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.error,
    required this.success,
    required this.warning,
    required this.divider,
  });

  factory AppColorTokens.light() => const AppColorTokens(
        primary: AppColors.primary,
        primaryDark: AppColors.primaryDark,
        primaryLight: AppColors.primaryLight,
        primarySurface: AppColors.primarySurface,
        secondary: AppColors.secondary,
        background: AppColors.background,
        surface: AppColors.surface,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textHint: AppColors.textHint,
        error: AppColors.error,
        success: AppColors.success,
        warning: AppColors.warning,
        divider: AppColors.divider,
      );

  factory AppColorTokens.dark() => const AppColorTokens(
        primary: AppColors.primary, // Adjust for dark theme if needed
        primaryDark: AppColors.primaryDark,
        primaryLight: AppColors.primaryLight,
        primarySurface: Color(0xFF1A1A1A),
        secondary: AppColors.secondary,
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
        textPrimary: Colors.white,
        textSecondary: Colors.white70,
        textHint: Colors.white54,
        error: AppColors.error,
        success: AppColors.success,
        warning: AppColors.warning,
        divider: Colors.white12,
      );
}
