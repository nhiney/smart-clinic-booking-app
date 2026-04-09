import 'package:flutter/material.dart';
import '../extensions/context_extension.dart';
import '../../l10n/app_localizations.dart';
import 'icare_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ICareLogo(size: 104, showText: false),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.welcome_to,
              style: context.textStyles.bodyBold.copyWith(
                color: context.colors.textPrimary,
                fontSize: 18,
              ),
            ),
            Text(
              'ICARE',
              style: context.textStyles.heading2.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 28,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
