import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static AppLanguage getSavedLanguage() {
    final String? languageCode = _prefs.getString(_languageKey);
    if (languageCode == null) return AppLanguage.en;
    
    return AppLanguage.values.firstWhere(
      (lang) => lang.name == languageCode,
      orElse: () => AppLanguage.en,
    );
  }

  static Future<void> saveLanguage(AppLanguage language) async {
    await _prefs.setString(_languageKey, language.name);
  }
}
