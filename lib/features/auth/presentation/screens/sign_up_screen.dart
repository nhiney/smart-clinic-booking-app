import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/core/widgets/auth_header.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_clinic_booking/core/widgets/app_text_field.dart';

import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_state.dart';
import '../bloc/sign_up_event.dart';
import '../utils/auth_error_localizer.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _termsAccepted = false;
  String _selectedCountryCode = '+84';
  static const List<String> _countryCodes = [
    '+84',
    '+1',
    '+44',
    '+81',
    '+82',
    '+86',
    '+61',
    '+65',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    debugPrint('[SignUpScreen] Register button pressed');
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.must_accept_terms),
            backgroundColor: context.colors.error,
          ),
        );
        return;
      }

      final fullPhone = _buildFullPhoneNumber(_phoneController.text);
      debugPrint('[SignUpScreen] Dispatching VerifyPhoneEvent for $fullPhone');
      context.read<SignUpBloc>().add(VerifyPhoneEvent(
        fullPhone,
        fullName: _nameController.text.trim(),
      ));
    }
  }

  String _buildFullPhoneNumber(String rawPhone) {
    var localPhone = rawPhone.trim();
    if (_selectedCountryCode == '+84' && localPhone.startsWith('0')) {
      localPhone = localPhone.substring(1);
    }
    return '$_selectedCountryCode$localPhone';
  }

  String? _validatePhoneByCountryCode(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.error_phone_required;
    final cleanPhone = value.trim();
    if (_selectedCountryCode == '+84') {
      final vnRegex = RegExp(r'^(0)?[3|5|7|8|9][0-9]{8}$');
      if (!vnRegex.hasMatch(cleanPhone)) {
        return 'Số điện thoại Việt Nam không hợp lệ';
      }
      return null;
    }

    final intlRegex = RegExp(r'^[0-9]{7,12}$');
    if (!intlRegex.hasMatch(cleanPhone)) {
      return 'Phone number is invalid';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[SignUpScreen] Building...');
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizeAuthError(context, state.error)),
              backgroundColor: context.colors.error,
            ),
          );
        }
        if (state.isCodeSent) {
          context.push('/verify-otp', extra: {
            'phone': state.phoneNumber,
            'name': state.fullName,
          });
        }
        if (state.isSuccess) {
          // If auto-verified
          context.push('/create-password', extra: {
            'phone': state.phoneNumber,
            'name': state.fullName,
          });
        }
      },
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: BrandedAppBar(
              backgroundColor: Colors.transparent,
              leading: InkWell(
                onTap: () => context.pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_back, color: context.colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.back_button_text,
                      style: context.textStyles.bodyBold.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFE3F2FD), // Xanh siêu nhạt
                    const Color(0xFFF1F8FF), // Nhạt hơn nữa
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.spacing.l),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      AuthHeader(),
                      const SizedBox(height: 32),
                      Text(
                        l10n.register_title,
                        style: context.textStyles.heading2.copyWith(
                          fontWeight: FontWeight.w800,
                          color: context.colors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.register_subtitle,
                        textAlign: TextAlign.center,
                        style: context.textStyles.body.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                      padding: EdgeInsets.all(context.spacing.l),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: context.radius.xlRadius,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _nameController,
                              labelText: l10n.full_name_label,
                              hintText: l10n.full_name_hint,
                              prefixIcon: Icon(Icons.person_outline, color: context.colors.textHint, size: 20),
                              validator: (v) => (v == null || v.trim().isEmpty) ? l10n.required_field : null,
                            ),
                            const SizedBox(height: 20),
                            AppTextField(
                              controller: _phoneController,
                              labelText: l10n.phone_label,
                              hintText: l10n.phone_hint,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Container(
                                width: 100,
                                padding: const EdgeInsets.only(left: 12, right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.smartphone_outlined, color: context.colors.textHint, size: 20),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCountryCode,
                                          isExpanded: true,
                                          icon: Icon(Icons.arrow_drop_down, color: context.colors.textHint),
                                          style: context.textStyles.bodyBold.copyWith(
                                            color: context.colors.textPrimary,
                                            fontSize: 15,
                                          ),
                                          items: _countryCodes.map((code) {
                                            return DropdownMenuItem<String>(
                                              value: code,
                                              child: Text(code),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            if (value == null) return;
                                            setState(() => _selectedCountryCode = value);
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 24,
                                      color: context.colors.divider,
                                    ),
                                  ],
                                ),
                              ),
                              validator: (v) {
                                return _validatePhoneByCountryCode(v, l10n);
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _termsAccepted,
                                    onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                                    activeColor: context.colors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: context.textStyles.body.copyWith(
                                        color: context.colors.textSecondary,
                                        fontSize: 13,
                                        height: 1.5,
                                        letterSpacing: 0.2,
                                        wordSpacing: 1.0,
                                      ),
                                      children: [
                                        TextSpan(text: l10n.terms_agreement_text.split(l10n.terms_and_conditions)[0]),
                                        TextSpan(
                                          text: l10n.terms_and_conditions,
                                          style: TextStyle(
                                            color: context.colors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              const pdfUrl = 'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf';
                                              final uri = Uri.parse(pdfUrl);
                                              if (await canLaunchUrl(uri)) {
                                                await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                                              }
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: l10n.register_now,
                              onPressed: _onRegisterPressed,
                              isLoading: state.isLoading,
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    l10n.or_label,
                                    style: context.textStyles.body.copyWith(color: context.colors.textHint),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () => context.go('/login'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                side: BorderSide(color: context.colors.primary),
                                shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                              ),
                              child: Text(
                                  l10n.login_button,
                                  style: context.textStyles.bodyBold.copyWith(color: context.colors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
