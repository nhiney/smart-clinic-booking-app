import 'package:flutter/material.dart';

class KioskTheme {
  static const primaryColor = Color(0xFF0056D2); // Deep Clinical Blue
  static const errorColor = Color(0xFFD32F2F);
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      
      // Massive Typography for Elderly Accessibility
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 24,
          color: Colors.black87,
        ),
        labelLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Massive Button Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(200, 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
