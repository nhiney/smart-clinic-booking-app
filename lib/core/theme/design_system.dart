import 'package:flutter/material.dart';
import 'colors/colors.dart';
import 'typography/app_text_styles.dart';
import 'spacing/app_spacing.dart';
import 'radius/app_radius.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DesignSystem — Hub tổng hợp tất cả UI tokens
//
// Cách dùng nhanh trong widget:
//   DesignSystem.colors(context).primary
//   DesignSystem.palette.primary       (không cần context)
//   DesignSystem.typography.heading1
//   DesignSystem.spacing.l
//   DesignSystem.radius.m
// ═══════════════════════════════════════════════════════════════════════════════

class DesignSystem {
  DesignSystem._();

  /// Màu theo theme hiện tại (light / dark)
  static AppColorTokens colors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? AppColorTokens.dark() : AppColorTokens.light();
  }

  /// Màu tĩnh không phụ thuộc theme
  static const palette = AppColors;

  /// Typography tokens
  static const typography = AppTextStyles;

  /// Spacing tokens
  static const spacing = AppSpacing;

  /// Border radius tokens
  static const radius = AppRadius;

  /// BoxDecoration chuẩn cho card
  static BoxDecoration cardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(
      color: c.card,
      borderRadius: AppRadius.mRadius,
      border: Border.all(color: c.border),
      boxShadow: [BoxShadow(color: c.shadow, blurRadius: 10, offset: const Offset(0, 4))],
    );
  }

  /// BoxDecoration chuẩn cho elevated card (có shadow nổi hơn)
  static BoxDecoration elevatedCardDecoration(BuildContext context) {
    final c = colors(context);
    return BoxDecoration(
      color: c.card,
      borderRadius: AppRadius.lRadius,
      boxShadow: [
        BoxShadow(color: c.shadow, blurRadius: 20, offset: const Offset(0, 8)),
        BoxShadow(color: c.shadow, blurRadius: 6, offset: const Offset(0, 2)),
      ],
    );
  }

  /// InputDecoration chuẩn cho form field
  static InputDecoration inputDecoration(BuildContext context, {String? label, String? hint, Widget? prefix}) {
    final c = colors(context);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
      border: OutlineInputBorder(borderRadius: AppRadius.mRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: c.borderFocus, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: c.error),
      ),
      filled: true,
      fillColor: c.surface,
    );
  }
}
