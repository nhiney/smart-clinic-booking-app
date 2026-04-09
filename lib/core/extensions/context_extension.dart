import 'package:flutter/material.dart';
import '../theme/colors/app_colors.dart';
import '../theme/colors/app_color_scheme.dart';
import '../theme/typography/app_text_styles.dart';
import '../theme/spacing/app_spacing.dart';
import '../theme/radius/app_radius.dart';

extension ContextExtension on BuildContext {
  // Theme Access
  ThemeData get theme => Theme.of(this);
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // Color Tokens
  AppColorTokens get colors => isDarkMode ? AppColorTokens.dark() : AppColorTokens.light();
  
  // Typography
  AppTextStylesProxy get textStyles => const AppTextStylesProxy();
  
  // Spacing & Radius
  AppSpacingProxy get spacing => const AppSpacingProxy();
  AppRadiusProxy get radius => const AppRadiusProxy();
  
  // Quick access to screen size
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  // Convenient padding/margin
  EdgeInsets get paddingAllM => const EdgeInsets.all(AppSpacing.m);
  EdgeInsets get paddingAllL => const EdgeInsets.all(AppSpacing.l);
  EdgeInsets get paddingHorizontalM => const EdgeInsets.symmetric(horizontal: AppSpacing.m);
  EdgeInsets get paddingVerticalM => const EdgeInsets.symmetric(vertical: AppSpacing.m);
}

/// Proxy classes to allow instance-like access to static theme members
class AppTextStylesProxy {
  const AppTextStylesProxy();
  TextStyle get heading1 => AppTextStyles.heading1;
  TextStyle get heading2 => AppTextStyles.heading2;
  TextStyle get heading3 => AppTextStyles.heading3;
  TextStyle get subtitle => AppTextStyles.subtitle;
  TextStyle get body => AppTextStyles.body;
  TextStyle get bodyLarge => body;
  TextStyle get bodyBold => AppTextStyles.bodyBold;
  TextStyle get bodySmall => AppTextStyles.bodySmall;
  TextStyle get caption => AppTextStyles.caption;
  TextStyle get button => AppTextStyles.button;
  TextStyle get link => AppTextStyles.link;
}

class AppSpacingProxy {
  const AppSpacingProxy();
  double get xs => AppSpacing.xs;
  double get s => AppSpacing.s;
  double get m => AppSpacing.m;
  double get l => AppSpacing.l;
  double get xl => AppSpacing.xl;
  double get xxl => AppSpacing.xxl;
}

class AppRadiusProxy {
  const AppRadiusProxy();
  BorderRadius get xsRadius => AppRadius.xsRadius;
  BorderRadius get sRadius => AppRadius.sRadius;
  BorderRadius get mRadius => AppRadius.mRadius;
  BorderRadius get lRadius => AppRadius.lRadius;
  BorderRadius get xlRadius => AppRadius.xlRadius;
}
