import 'package:flutter/material.dart';
import '../colors/app_colors.dart';
import '../colors/app_color_scheme.dart';
import '../typography/app_text_styles.dart';
import '../radius/app_radius.dart';

ThemeData get darkTheme {
  final tokens = AppColorTokens.dark();
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: tokens.primary,
    scaffoldBackgroundColor: tokens.background,
    
    colorScheme: ColorScheme.dark(
      primary: tokens.primary,
      secondary: tokens.secondary,
      surface: tokens.surface,
      error: tokens.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: tokens.textPrimary,
      onError: Colors.white,
    ),
    
    appBarTheme: AppBarTheme(
      backgroundColor: tokens.surface,
      foregroundColor: tokens.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.heading3.copyWith(color: tokens.textPrimary),
    ),
    
    dividerTheme: DividerThemeData(
      color: tokens.divider,
      thickness: 1,
    ),
    
    cardTheme: CardThemeData(
      color: tokens.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mRadius,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: tokens.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mRadius,
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: tokens.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: tokens.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: tokens.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: tokens.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.mRadius,
        borderSide: BorderSide(color: tokens.error),
      ),
      hintStyle: AppTextStyles.caption.copyWith(color: tokens.textHint),
    ),
  );
}
