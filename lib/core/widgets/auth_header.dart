import 'package:flutter/material.dart';
import '../extensions/context_extension.dart';
import '../../l10n/app_localizations.dart';
import 'icare_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Keep the app title perfectly centered.
          Column(
            mainAxisSize: MainAxisSize.min,
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
                  fontSize: 24,
                  height: 1.0,
                ),
              ),
            ],
          ),
          // Move logo to the left so it doesn't push title off-center.
          const Positioned(
            left: 0,
            child: ICareLogo(size: 96, showText: false),
          ),
        ],
      ),
    );
  }
}
