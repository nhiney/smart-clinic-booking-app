import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/icare_logo.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/language_selector.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool hidePassword = true;
  bool saveLoginInfo = false;
  String selectedCountryCode = "+84";
  final List<String> countryCodes = ["+84", "+1", "+44", "+81", "+82", "+86", "+61", "+65"];

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void goToRegister() {
    context.push('/sign-up');
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context)!;
    final authController = context.read<AuthController>();
    String phone = phoneController.text.trim();
    if (selectedCountryCode == "+84" && phone.startsWith('0')) {
      phone = phone.substring(1);
    }
    
    final fullPhone = "$selectedCountryCode$phone";
    
    final success = await authController.login(
      fullPhone,
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? l10n.error_login_failed),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: BrandedAppBar(
        showLogo: true,
        leadingWidth: 100,
        backgroundColor: Colors.transparent,
        leading: TextButton.icon(
          onPressed: () => context.go('/'),
          icon: Icon(Icons.arrow_back, color: context.colors.primary),
          label: Text(
            l10n.login_title,
            style: context.textStyles.bodyBold.copyWith(
              color: context.colors.primary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            alignment: Alignment.centerLeft,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => LanguageSelector.show(context),
            icon: Icon(Icons.language, color: context.colors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.l,
            vertical: context.spacing.s,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.spacing.m),
                const Center(child: ICareLogo(size: 80)),
                SizedBox(height: context.spacing.xl),
                Text(
                  l10n.login_welcome,
                  style: context.textStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: context.spacing.xl),

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
                    return null;
                  },
                ),
                SizedBox(height: context.spacing.m),

                AppTextField(
                  controller: passwordController,
                  labelText: l10n.password_label,
                  hintText: l10n.password_hint,
                  obscureText: hidePassword,
                  prefixIcon: Icon(Icons.lock_outline, color: context.colors.textHint, size: 22),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: context.colors.textHint,
                    ),
                    onPressed: () {
                      setState(() => hidePassword = !hidePassword);
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.error_password_required;
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.spacing.s),
                
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      l10n.forgot_password,
                      style: context.textStyles.bodySmall.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: context.spacing.l),

                AppButton(
                  text: l10n.login_button,
                  onPressed: handleLogin,
                  isLoading: context.watch<AuthController>().isLoading,
                ),
                SizedBox(height: context.spacing.l),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.no_account,
                      style: context.textStyles.body.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: goToRegister,
                      child: Text(
                        l10n.register_now,
                        style: context.textStyles.bodyBold.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
