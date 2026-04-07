import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_language.dart';
import 'language_service.dart';

final languageControllerProvider = StateNotifierProvider<LanguageController, AppLanguage>((ref) {
  return LanguageController();
});

class LanguageController extends StateNotifier<AppLanguage> {
  LanguageController() : super(LanguageService.getSavedLanguage());

  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    await LanguageService.saveLanguage(language);
  }

  void loadInitialLanguage() {
    state = LanguageService.getSavedLanguage();
  }
}
