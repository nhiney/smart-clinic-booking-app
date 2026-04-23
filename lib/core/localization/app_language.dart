import 'package:flutter/material.dart';

enum AppLanguage { vi, en, zh, ja, ko }

extension AppLanguageExtension on AppLanguage {
  Locale get locale {
    switch (this) {
      case AppLanguage.vi:
        return const Locale('vi');
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.zh:
        return const Locale('zh');
      case AppLanguage.ja:
        return const Locale('ja');
      case AppLanguage.ko:
        return const Locale('ko');
    }
  }

  String get languageName {
    switch (this) {
      case AppLanguage.vi:
        return 'Tiếng Việt';
      case AppLanguage.en:
        return 'English';
      case AppLanguage.zh:
        return '中文';
      case AppLanguage.ja:
        return '日本語';
      case AppLanguage.ko:
        return '한국어';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.vi:
        return '🇻🇳';
      case AppLanguage.en:
        return '🇺🇸';
      case AppLanguage.zh:
        return '🇨🇳';
      case AppLanguage.ja:
        return '🇯🇵';
      case AppLanguage.ko:
        return '🇰🇷';
    }
  }

  String localize(String vi, String en) {
    if (this == AppLanguage.vi) return vi;
    return en;
  }
}
