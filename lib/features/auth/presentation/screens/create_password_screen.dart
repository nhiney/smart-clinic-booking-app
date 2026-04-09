import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/widgets/app_text_field.dart';
import 'package:smart_clinic_booking/core/widgets/auth_header.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../utils/auth_error_localizer.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String? name;
  const CreatePasswordScreen({super.key, required this.phoneNumber, this.name});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

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

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _isConfirmMatched =>
      _confirmPasswordController.text.isNotEmpty &&
      _confirmPasswordController.text == _passwordController.text;

  bool get _isPasswordValid =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasDigit;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordInputChanged);
    _confirmPasswordController.addListener(_onPasswordInputChanged);
  }

  void _onPasswordInputChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordInputChanged);
    _confirmPasswordController.removeListener(_onPasswordInputChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return AppLocalizations.of(context)!.required_field;
    if (!_isPasswordValid) {
      return AppLocalizations.of(context)!.password_validation_error;
    }
    return null;
  }

  Widget _buildPasswordRules(BuildContext context) {
    Widget ruleItem(String text, bool isValid) {
      return Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isValid ? Colors.green : context.colors.textHint,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: context.textStyles.bodySmall)),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing.m),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.06),
        borderRadius: context.radius.mRadius,
        border: Border.all(color: context.colors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nguyên tắc tạo mật khẩu',
            style: context.textStyles.bodyBold.copyWith(
              color: context.colors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          ruleItem('Mật khẩu có tối thiểu 8 ký tự', _hasMinLength),
          const SizedBox(height: 6),
          ruleItem('Mật khẩu có chữ in hoa', _hasUppercase),
          const SizedBox(height: 6),
          ruleItem('Mật khẩu có chữ thường', _hasLowercase),
          const SizedBox(height: 6),
          ruleItem('Mật khẩu có chữ số', _hasDigit),
          const SizedBox(height: 6),
          ruleItem('Mật khẩu xác nhận phải trùng khớp', _isConfirmMatched),
        ],
      ),
    );
  }

  void _submit() async {
    if (_isLoading) return;
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final authController = context.read<AuthController>();
      final success = await authController.register(
        name: widget.name ?? 'Người dùng Patient',
        phone: widget.phoneNumber,
        password: _passwordController.text,
        role: 'patient',
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          final qrData = await authController.createQrLoginToken(persistent: true);
          if (!mounted) return;
          if (qrData != null && (qrData['token'] as String?)?.isNotEmpty == true) {
            // Sign out so the user is forced to see QR then login manually as requested
            authController.logout();
            if (!mounted) return;
            context.go('/account-qr', extra: qrData);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizeAuthError(
                    context,
                    authController.errorMessage,
                    fallback: AppLocalizations.of(context)!.registration_success,
                  ),
                ),
                backgroundColor: context.colors.primary,
              ),
            );
            context.go('/login');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizeAuthError(
                  context,
                  authController.errorMessage,
                  fallback: _tr(
                    'Đăng ký thất bại',
                    'Registration failed',
                    '登録に失敗しました',
                    '회원가입에 실패했습니다',
                    '注册失败',
                  ),
                ),
              ),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BrandedAppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFF8FAFC),
              Colors.white,
            ],
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
                  l10n.create_password_title,
                  style: context.textStyles.heading2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
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
                      children: [
                        _buildPasswordRules(context),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          labelText: l10n.password_label,
                          hintText: l10n.password_hint,
                          obscureText: true,
                          prefixIcon: Icon(Icons.lock_outline, color: context.colors.primary),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Xác nhận mật khẩu',
                          hintText: 'Nhập lại mật khẩu',
                          obscureText: true,
                          prefixIcon: Icon(Icons.lock_reset_outlined, color: context.colors.primary),
                          validator: (v) {
                            if (v == null || v.isEmpty) return l10n.required_field;
                            return v != _passwordController.text ? 'Mật khẩu không khớp' : null;
                          },
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          text: l10n.continue_button,
                          onPressed: _submit,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
