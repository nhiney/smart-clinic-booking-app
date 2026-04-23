import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/debug_test_login_config.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/auth_header.dart';
import '../../../../core/services/local_account_store.dart';
import '../controllers/auth_controller.dart';
import '../navigation/role_navigation.dart';
import '../utils/auth_error_localizer.dart';

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
  bool rememberMe = false;
  String selectedCountryCode = "+84";
  final List<String> countryCodes = ["+84", "+1", "+44", "+81", "+82", "+86"];

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _tr(String vi, String en, String ja, String ko, String zh) {
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'en':
        return en;
      case 'ja':
        return ja;
      case 'ko':
        return ko;
      case 'zh':
        return zh;
      default:
        return vi;
    }
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final authController = context.read<AuthController>();

    final rawPhone = phoneController.text.trim();
    final normalizedPhone = AuthController.normalizePhone(selectedCountryCode, rawPhone);

    // Kiểm tra định dạng số điện thoại
    if (!_isValidPhoneFormat(rawPhone)) {
      _showError(selectedCountryCode == '+84'
          ? 'Số điện thoại Việt Nam không hợp lệ (VD: 0912345678)'
          : 'Số điện thoại không hợp lệ');
      return;
    }

    final password = passwordController.text.trim();

    // ---- LOCAL AUTHENTICATION (SharedPreferences) ----
    // Ưu tiên kiểm tra trong LocalAccountStore trước
    final localAccount = await LocalAccountStore.instance.verifyLogin(
      phone: normalizedPhone,
      password: password,
    );
    if (!mounted) return;

    if (localAccount != null) {
      // Đăng nhập local thành công
      debugPrint('[LOGIN] Local login success for $normalizedPhone');
      final virtualEmail = '$normalizedPhone@icare.patient';
      // Thử đăng nhập Firebase (non-blocking) để sync session
      authController.login(virtualEmail, password).ignore();
      // Navigate ngay không chờ Firebase
      navigateByRole(context, 'patient');
      return;
    }

    // ---- Kiểm tra phone đã đăng ký chưa (fallback Firestore/server) ----
    final isRegistered = await authController.checkPhoneRegistered(normalizedPhone);
    if (!mounted) return;
    if (!isRegistered) {
      _showError('Số điện thoại chưa được đăng ký. Vui lòng đăng ký trước.');
      return;
    }

    // ---- Firebase Auth Login (production) ----
    final virtualEmail2 = '$normalizedPhone@icare.patient';
    final success = await authController.login(virtualEmail2, password);

    if (!mounted) return;

    if (success) {
      navigateByRole(context, authController.currentUser?.role ?? 'patient');
    } else {
      _showError(localizeAuthError(context, authController.errorMessage, fallback: l10n.error_login_failed));
    }
  }

  bool _isValidPhoneFormat(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s'), '');
    if (selectedCountryCode == '+84') {
      return RegExp(r'^(0?[35789][0-9]{8})$').hasMatch(clean);
    }
    return RegExp(r'^[0-9]{7,12}$').hasMatch(clean);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: BrandedAppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => context.go('/'),
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
              const Color(0xFFE3F2FD),
              const Color(0xFFF1F8FF),
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
                const AuthHeader(),
                const SizedBox(height: 32),
                Text(
                  l10n.login_account,
                  style: context.textStyles.heading2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
                  ),
                ),
                const SizedBox(height: 24),
                _buildLoginCard(l10n, authController),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(AppLocalizations l10n, AuthController controller) {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.phone_label,
              style: context.textStyles.bodyBold.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: phoneController,
              hintText: l10n.phone_hint,
              keyboardType: TextInputType.phone,
              prefixIcon: _buildCountryCodePicker(),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.password_label,
              style: context.textStyles.bodyBold.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: passwordController,
              hintText: l10n.password_hint,
              obscureText: hidePassword,
              prefixIcon: Icon(Icons.lock_outline, color: context.colors.primary),
              suffixIcon: IconButton(
                icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => hidePassword = !hidePassword),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (val) => setState(() => rememberMe = val ?? false),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.save_login, style: context.textStyles.bodySmall),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.forgot_password,
                    style: context.textStyles.bodyBold.copyWith(color: context.colors.primary, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppButton(
              text: l10n.login_button,
              onPressed: handleLogin,
              isLoading: controller.isLoading,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(l10n.or_label, style: context.textStyles.bodySmall.copyWith(color: Colors.grey)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/sign-up'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: context.colors.primary),
                  shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                ),
                child: Text(
                  l10n.register_now,
                  style: context.textStyles.button.copyWith(color: context.colors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/qr-login'),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: context.colors.primary.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
                ),
                label: Text(
                  _tr(
                    'Đăng nhập bằng mã QR',
                    'Login with QR code',
                    'QRコードでログイン',
                    'QR 코드로 로그인',
                    '使用二维码登录',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildStaffLink(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.staff_login_prompt,
          style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => context.push('/staff-login'),
          child: Text(
            l10n.staff_login_link,
            style: context.textStyles.bodyBold.copyWith(
              color: context.colors.primary,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCodePicker() {
    return Container(
      width: 70,
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCountryCode,
          iconSize: 18,
          items: countryCodes.map((code) => DropdownMenuItem(value: code, child: Text(code, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (val) => setState(() => selectedCountryCode = val!),
        ),
      ),
    );
  }
}
