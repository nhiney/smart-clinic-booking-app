import 'package:flutter/material.dart';

class AppColors {
  // Gentle Medical Blue Palette
  static const Color primary = Color(0xFF2196F3);      // Standard Clinical Blue
  static const Color primaryDark = Color(0xFF1565C0);  // Trust Blue
  static const Color primaryLight = Color(0xFFBBDEFB); // Soft Sky Blue
  static const Color primarySurface = Color(0xFFF0F7FF); // Alice Blue / Surface Tints

  // Secondary
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFFB2DFDB);

  // Background
  static const Color background = Color(0xFFF8FAFF); // Very soft blue-white
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF263238);   // Charcoal
  static const Color textSecondary = Color(0xFF546E7A); // Slate Blue Gray
  static const Color textHint = Color(0xFF90A4AE);      // Blue Gray
  static const Color textOnPrimary = Colors.white;

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF2196F3);

  // Appointment status
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusConfirmed = Color(0xFF4CAF50);
  static const Color statusCompleted = Color(0xFF2196F3);
  static const Color statusCancelled = Color(0xFFEF5350);

  // Misc
  static const Color divider = Color(0xFFECEFF1);
  static const Color shadow = Color(0x1A2196F3); // Blue-tinted shadow
  static const Color shimmerBase = Color(0xFFE3F2FD);
  static const Color shimmerHighlight = Color(0xFFF5F9FF);

  // Gradients (Gentle & Calming)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiGradient = LinearGradient(
    colors: [primary, Color(0xFF6A1B9A), Color(0xFFAD1457)], // Keep the 'Magic' AI feel
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFE3F2FD), Color(0xFFF8FAFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
