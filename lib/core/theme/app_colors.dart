import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primarySurface = Color(0xFFE3F2FD);

  // Secondary
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFFB2DFDB);

  // Background
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // appointment status
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusConfirmed = Color(0xFF66BB6A);
  static const Color statusCompleted = Color(0xFF42A5F5);
  static const Color statusCancelled = Color(0xFFEF5350);

  // Misc
  static const Color divider = Color(0xFFEEEEEE);
  static const Color shadow = Color(0x1A000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF5F7FA), Color(0xFFE4ECF7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
