import 'package:flutter/material.dart';
import 'app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// AppColorTokens — Màu theo context (Light / Dark mode)
//
// CÁCH DÙNG:
//   context.colors.primary         → màu primary theo theme hiện tại
//   context.colors.background      → màu nền theo theme
//   context.colors.error           → màu lỗi theo theme
//
// THÊM TOKEN MỚI:
//   1. Thêm field vào class AppColorTokens
//   2. Gán giá trị trong AppColorTokens.light() và AppColorTokens.dark()
//   3. Tham chiếu từ AppColors.xxx — không hardcode hex
// ═══════════════════════════════════════════════════════════════════════════════

class AppColorTokens {
  // ─── Brand / Primary ────────────────────────────────────────────────────
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primarySurface;

  // ─── Secondary ──────────────────────────────────────────────────────────
  final Color secondary;
  final Color secondaryDark;
  final Color secondaryLight;

  // ─── Background & Surface ───────────────────────────────────────────────
  final Color background;
  final Color backgroundAlt;
  final Color surface;
  final Color card;
  final Color skeleton;

  // ─── Text ───────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color textDisabled;
  final Color textInverse;
  final Color textLink;

  // ─── Border & Divider ───────────────────────────────────────────────────
  final Color border;
  final Color borderFocus;
  final Color divider;

  // ─── Status: Error ──────────────────────────────────────────────────────
  final Color error;
  final Color errorLight;
  final Color errorSurface;

  // ─── Status: Success ────────────────────────────────────────────────────
  final Color success;
  final Color successLight;
  final Color successSurface;

  // ─── Status: Warning ────────────────────────────────────────────────────
  final Color warning;
  final Color warningLight;
  final Color warningSurface;

  // ─── Status: Info ───────────────────────────────────────────────────────
  final Color info;
  final Color infoLight;
  final Color infoSurface;
  
  // ─── Status: Appointment/Booking ────────────────────────────────────────
  final Color statusPending;
  final Color statusConfirmed;
  final Color statusCompleted;
  final Color statusCancelled;

  // ─── Navigation Bar ─────────────────────────────────────────────────────
  final Color navSelected;
  final Color navUnselected;
  final Color navBackground;

  // ─── Chip / Badge ───────────────────────────────────────────────────────
  final Color chipPrimary;
  final Color chipSecondary;

  // ─── Shadow / Overlay ───────────────────────────────────────────────────
  final Color shadow;
  final Color overlay;

  // ─── Gradient ───────────────────────────────────────────────────────────
  final LinearGradient primaryGradient;
  final LinearGradient surfaceGradient;

  const AppColorTokens({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primarySurface,
    required this.secondary,
    required this.secondaryDark,
    required this.secondaryLight,
    required this.background,
    required this.backgroundAlt,
    required this.surface,
    required this.card,
    required this.skeleton,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.textDisabled,
    required this.textInverse,
    required this.textLink,
    required this.border,
    required this.borderFocus,
    required this.divider,
    required this.error,
    required this.errorLight,
    required this.errorSurface,
    required this.success,
    required this.successLight,
    required this.successSurface,
    required this.warning,
    required this.warningLight,
    required this.warningSurface,
    required this.info,
    required this.infoLight,
    required this.infoSurface,
    required this.navSelected,
    required this.navUnselected,
    required this.navBackground,
    required this.chipPrimary,
    required this.chipSecondary,
    required this.shadow,
    required this.overlay,
    required this.primaryGradient,
    required this.surfaceGradient,
    required this.statusPending,
    required this.statusConfirmed,
    required this.statusCompleted,
    required this.statusCancelled,
  });

  // ─── LIGHT THEME ────────────────────────────────────────────────────────
  factory AppColorTokens.light() => const AppColorTokens(
        primary:         AppColors.brand,
        primaryDark:     AppColors.brandDark,
        primaryLight:    AppColors.brandLight,
        primarySurface:  AppColors.brandFaint,

        secondary:       AppColors.teal500,
        secondaryDark:   AppColors.teal900,
        secondaryLight:  AppColors.teal100,

        background:      AppColors.gray50,
        backgroundAlt:   AppColors.slate50,
        surface:         Colors.white,
        card:            Colors.white,
        skeleton:        AppColors.gray100,

        textPrimary:     AppColors.gray900,
        textSecondary:   AppColors.gray500,
        textHint:        AppColors.gray300,
        textDisabled:    AppColors.gray400,
        textInverse:     Colors.white,
        textLink:        AppColors.brand,

        border:          AppColors.gray200,
        borderFocus:     AppColors.brand,
        divider:         AppColors.gray200,

        error:           AppColors.red600,
        errorLight:      AppColors.red100,
        errorSurface:    AppColors.red50,

        success:         AppColors.green600,
        successLight:    AppColors.green200,
        successSurface:  AppColors.green50,

        warning:         AppColors.amber600,
        warningLight:    AppColors.amber100,
        warningSurface:  AppColors.amber50,

        info:            AppColors.blue600,
        infoLight:       AppColors.blue100,
        infoSurface:     AppColors.blue50,

        navSelected:     AppColors.brand,
        navUnselected:   AppColors.blueGray600,
        navBackground:   Colors.white,

        chipPrimary:     AppColors.brandFaint,
        chipSecondary:   AppColors.teal50,

        shadow:          AppColors.black8,
        overlay:         AppColors.black12,

        primaryGradient: AppColors.primaryGradient,
        surfaceGradient: AppColors.surfaceGradient,
        statusPending:   AppColors.statusPending,
        statusConfirmed: AppColors.statusConfirmed,
        statusCompleted: AppColors.statusCompleted,
        statusCancelled: AppColors.statusCancelled,
      );

  // ─── DARK THEME ─────────────────────────────────────────────────────────
  factory AppColorTokens.dark() => const AppColorTokens(
        primary:         AppColors.lightBlue700,
        primaryDark:     AppColors.brand,
        primaryLight:    AppColors.slate800,
        primarySurface:  AppColors.slate800,

        secondary:       AppColors.teal500,
        secondaryDark:   AppColors.teal900,
        secondaryLight:  AppColors.teal700,

        background:      AppColors.slate900,
        backgroundAlt:   Color(0xFF0A1628),
        surface:         AppColors.slate800,
        card:            AppColors.slate700,
        skeleton:        AppColors.slate700,

        textPrimary:     Colors.white,
        textSecondary:   AppColors.slate400,
        textHint:        AppColors.slate600,
        textDisabled:    AppColors.slate600,
        textInverse:     AppColors.gray900,
        textLink:        AppColors.lightBlue100,

        border:          AppColors.slate700,
        borderFocus:     AppColors.lightBlue700,
        divider:         AppColors.slate700,

        error:           AppColors.red500,
        errorLight:      Color(0xFF7F1D1D),
        errorSurface:    Color(0xFF450A0A),

        success:         AppColors.green500,
        successLight:    Color(0xFF14532D),
        successSurface:  Color(0xFF052E16),

        warning:         AppColors.amber500,
        warningLight:    Color(0xFF78350F),
        warningSurface:  Color(0xFF451A03),

        info:            AppColors.blue400,
        infoLight:       Color(0xFF1E3A5F),
        infoSurface:     Color(0xFF0C1A2E),

        navSelected:     AppColors.lightBlue700,
        navUnselected:   AppColors.slate400,
        navBackground:   AppColors.slate800,

        chipPrimary:     AppColors.slate700,
        chipSecondary:   AppColors.slate700,

        shadow:          AppColors.black12,
        overlay:         Color(0x29000000),

        primaryGradient: AppColors.darkGradient,
        surfaceGradient: LinearGradient(
          colors: [AppColors.slate800, AppColors.slate900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        statusPending:   AppColors.amber500,
        statusConfirmed: AppColors.green500,
        statusCompleted: AppColors.blue400,
        statusCancelled: AppColors.red500,
      );
}
