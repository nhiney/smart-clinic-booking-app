import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/icare_logo.dart';
import '../../../../core/widgets/language_selector.dart';
import '../controllers/auth_controller.dart';
import '../utils/auth_error_localizer.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;
  String selectedRole = 'patient';
  String selectedCountryCode = "+84";
  final List<String> countryCodes = ["+84", "+1", "+44", "+81", "+82", "+86", "+61", "+65"];

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _goToOtp() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    String phone = phoneController.text.trim();
    if (selectedCountryCode == "+84" && phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    final fullPhone = "$selectedCountryCode$phone";

    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.must_accept_terms)),
      );
      return;
    }

    final authController = context.read<AuthController>();

    // Kiểm tra số điện thoại đã đăng ký chưa
    final isRegistered = await authController.checkPhoneRegistered(fullPhone);
    if (!mounted) return;
    if (isRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'vi'
                ? 'Số điện thoại này đã được đăng ký. Vui lòng đăng nhập.'
                : 'This phone number is already registered. Please log in.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    authController.verifyPhone(
      fullPhone,
      onCodeSent: () {
        if (!mounted) return;
        context.push('/verify-otp', extra: {
          'phone': fullPhone,
          'name': fullNameController.text.trim(),
        });
      },
      onAutoVerified: () {
        if (!mounted) return;
        context.push('/create-password', extra: {
          'phone': fullPhone,
          'name': fullNameController.text.trim(),
        });
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizeAuthError(context, error))),
        );
      },
    );
  }

  void _openTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: BrandedAppBar(
        showLogo: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: context.colors.primary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: context.radius.xlRadius,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => LanguageSelector.show(context),
                icon: Icon(Icons.language, color: context.colors.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.l, vertical: context.spacing.s),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: ICareLogo(size: 60, showText: false)),
                SizedBox(height: context.spacing.s),
                Center(
                  child: Text(
                    'ICARE',
                    style: context.textStyles.heading3.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: context.colors.primaryDark,
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.l),
                Text(l10n.register_title, style: context.textStyles.heading2),
                SizedBox(height: context.spacing.xs),
                Text(
                  l10n.login_welcome,
                  style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                ),
                SizedBox(height: context.spacing.l),
                AppTextField(
                  controller: fullNameController,
                  labelText: l10n.full_name_label,
                  hintText: l10n.full_name_hint,
                  prefixIcon: Icon(Icons.person_outline, color: context.colors.textHint),
                  validator: (val) => (val == null || val.trim().isEmpty) ? l10n.required_field : null,
                ),
                SizedBox(height: context.spacing.m),
                AppTextField(
                  controller: phoneController,
                  labelText: l10n.phone_label,
                  hintText: l10n.phone_hint,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Container(
                    width: 100,
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_android, color: context.colors.textHint, size: 20),
                        const SizedBox(width: 4),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCountryCode,
                              isExpanded: true,
                              icon: Icon(Icons.arrow_drop_down, color: context.colors.textHint),
                              style: context.textStyles.bodyBold.copyWith(
                                color: context.colors.textPrimary,
                                fontSize: 15,
                              ),
                              items: countryCodes.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedCountryCode = val!;
                                });
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
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.error_phone_required;
                    }
                    final cleanPhone = val.trim();
                    if (selectedCountryCode == "+84") {
                      final vnRegex = RegExp(r'^(0)?[3|5|7|8|9][0-9]{8}$');
                      if (!vnRegex.hasMatch(cleanPhone)) {
                        return 'So dien thoai Viet Nam khong hop le';
                      }
                    } else {
                      final intlRegex = RegExp(r'^[0-9]{7,12}$');
                      if (!intlRegex.hasMatch(cleanPhone)) {
                        return 'Phone number is invalid';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacing.m),
                Text(
                  Localizations.localeOf(context).languageCode == 'vi' ? 'Vai tro' : 'Role',
                  style: context.textStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: context.spacing.s),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(l10n.role_patient),
                        selected: selectedRole == 'patient',
                        onSelected: (_) => setState(() => selectedRole = 'patient'),
                        selectedColor: context.colors.primary.withOpacity(0.16),
                        labelStyle: context.textStyles.bodyBold.copyWith(
                          color: selectedRole == 'patient' ? context.colors.primary : context.colors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                      ),
                    ),
                    SizedBox(width: context.spacing.s),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(l10n.role_doctor),
                        selected: selectedRole == 'doctor',
                        onSelected: (_) => setState(() => selectedRole = 'doctor'),
                        selectedColor: context.colors.primary.withOpacity(0.16),
                        labelStyle: context.textStyles.bodyBold.copyWith(
                          color: selectedRole == 'doctor' ? context.colors.primary : context.colors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.m),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => isChecked = !isChecked),
                      borderRadius: BorderRadius.circular(7),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isChecked ? context.colors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isChecked ? context.colors.primary : context.colors.divider,
                            width: 1.5,
                          ),
                        ),
                        child: isChecked
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                    SizedBox(width: context.spacing.s),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: '${l10n.agree_terms} ',
                          style: context.textStyles.body.copyWith(
                            color: context.colors.textSecondary,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.terms_and_conditions,
                              style: context.textStyles.bodyBold.copyWith(
                                color: context.colors.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = _openTerms,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.spacing.xl),
                Consumer<AuthController>(
                  builder: (context, auth, _) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: context.radius.mRadius,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: AppButton(
                        text: l10n.create_account_button,
                        onPressed: _goToOtp,
                        isLoading: auth.isLoading,
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  },
                ),
                SizedBox(height: context.spacing.s),
                AppButton(
                  text: l10n.login_button,
                  onPressed: () => context.pop(),
                  isSecondary: true,
                  foregroundColor: context.colors.primary,
                  backgroundColor: context.colors.surface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
