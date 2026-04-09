import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';

import '../../../../core/constants/app_constants.dart';
import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_state.dart';

class TermsAndConditionsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsAndConditionsCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(AppConstants.privacyPolicyUrl);
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final theme = Theme.of(context);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: state.isLoading ? null : onChanged,
              activeColor: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fullText = l10n.agree_terms;
                    final linkText = l10n.terms_and_conditions;
                    final startIndex = fullText.indexOf(linkText);

                    if (startIndex == -1) {
                      return RichText(
                        text: TextSpan(
                          text: fullText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                        ),
                      );
                    }

                    final prefix = fullText.substring(0, startIndex);
                    final suffix = fullText.substring(startIndex + linkText.length);

                    return RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: prefix),
                          TextSpan(
                            text: linkText,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                          ),
                          TextSpan(text: suffix),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
