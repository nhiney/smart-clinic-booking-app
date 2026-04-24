import 'package:flutter/material.dart';
import '../theme/colors/colors.dart';
import '../theme/typography/app_text_styles.dart';
import '../theme/spacing/app_spacing.dart';
import '../theme/radius/app_radius.dart';

extension ContextExtension on BuildContext {
  // ─── Theme ────────────────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ─── Colors (theo theme hiện tại) ─────────────────────────────────────────
  // context.colors.primary | context.colors.background | context.colors.error ...
  AppColorTokens get colors => isDarkMode ? AppColorTokens.dark() : AppColorTokens.light();

  // ─── Typography ───────────────────────────────────────────────────────────
  AppTextStylesProxy get textStyles => const AppTextStylesProxy();

  // ─── Spacing & Radius ─────────────────────────────────────────────────────
  AppSpacingProxy get spacing => const AppSpacingProxy();
  AppRadiusProxy get radius => const AppRadiusProxy();

  // ─── Screen Size ──────────────────────────────────────────────────────────
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // ─── Padding helpers ──────────────────────────────────────────────────────
  EdgeInsets get paddingAllM => EdgeInsets.all(spacing.m);
  EdgeInsets get paddingAllL => EdgeInsets.all(spacing.l);
  EdgeInsets get paddingHorizontalM => EdgeInsets.symmetric(horizontal: spacing.m);
  EdgeInsets get paddingVerticalM => EdgeInsets.symmetric(vertical: spacing.m);

  // ─── Decoration helpers ───────────────────────────────────────────────────
  BoxDecoration get cardDecoration => BoxDecoration(
        color: colors.card,
        borderRadius: radius.mRadius,
        border: Border.all(color: colors.border),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))],
      );

  BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: colors.card,
        borderRadius: radius.lRadius,
        boxShadow: [
          BoxShadow(color: colors.shadow, blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: colors.shadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      );
}

// ─── Typography Proxy ─────────────────────────────────────────────────────────
class AppTextStylesProxy {
  const AppTextStylesProxy();
  TextStyle get heading1  => AppTextStyles.heading1;
  TextStyle get heading2  => AppTextStyles.heading2;
  TextStyle get heading3  => AppTextStyles.heading3;
  TextStyle get subtitle  => AppTextStyles.subtitle;
  TextStyle get body      => AppTextStyles.body;
  TextStyle get bodyLarge => AppTextStyles.body;
  TextStyle get bodyBold  => AppTextStyles.bodyBold;
  TextStyle get bodySmall => AppTextStyles.bodySmall;
  TextStyle get caption   => AppTextStyles.caption;
  TextStyle get button    => AppTextStyles.button;
  TextStyle get link      => AppTextStyles.link;
}

// ─── Spacing Proxy ────────────────────────────────────────────────────────────
class AppSpacingProxy {
  const AppSpacingProxy();
  double get xs  => AppSpacing.xs;
  double get s   => AppSpacing.s;
  double get m   => AppSpacing.m;
  double get l   => AppSpacing.l;
  double get xl  => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
}

// ─── Radius Proxy ─────────────────────────────────────────────────────────────
class AppRadiusProxy {
  const AppRadiusProxy();
  BorderRadius get xsRadius => AppRadius.xsRadius;
  BorderRadius get sRadius  => AppRadius.sRadius;
  BorderRadius get mRadius  => AppRadius.mRadius;
  BorderRadius get lRadius  => AppRadius.lRadius;
  BorderRadius get xlRadius => AppRadius.xlRadius;
}
