import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_language.dart';
import '../localization/language_controller.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              AppLocalizations.of(context)!.settings_language,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...AppLanguage.values.map((language) {
            return ListTile(
              leading: Text(
                language.flag,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(language.languageName),
              trailing: currentLanguage == language
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref.read(languageControllerProvider.notifier).setLanguage(language);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageSelector(),
    );
  }
}
