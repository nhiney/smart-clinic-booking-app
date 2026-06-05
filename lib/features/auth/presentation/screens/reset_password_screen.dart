import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/widgets/app_text_field.dart';
import 'package:smart_clinic_booking/core/widgets/auth_header.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;

  const ResetPasswordScreen({super.key, required this.phoneNumber});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirm = true;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase =>
      _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase =>
      _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasDigit =>
      _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _isPasswordValid =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasDigit;
  bool get _isConfirmMatched =>
      _confirmController.text.isNotEmpty &&
      _confirmController.text == _passwordController.text;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (!_isPasswordValid) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and a number.';
    }
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ctrl = context.read<AuthController>();
    final success =
        await ctrl.resetPasswordAfterOtp(_passwordController.text.trim());

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset successfully! Please log in.'),
          backgroundColor: context.colors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Sign out so user re-authenticates with new password
      await ctrl.logout();
      if (!mounted) return;
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.errorMessage ?? 'Failed to reset password. Please try again.'),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPasswordRules() {
    Widget rule(String text, bool isValid) => Row(
          children: [
            Icon(
              isValid ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isValid ? Colors.green : context.colors.textHint,
            ),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(text, style: context.textStyles.bodySmall)),
          ],
        );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.spacing.m),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.06),
        borderRadius: context.radius.mRadius,
        border:
            Border.all(color: context.colors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password requirements',
            style: context.textStyles.bodyBold
                .copyWith(color: context.colors.primaryDark),
          ),
          const SizedBox(height: 8),
          rule('At least 8 characters', _hasMinLength),
          const SizedBox(height: 6),
          rule('At least one uppercase letter', _hasUppercase),
          const SizedBox(height: 6),
          rule('At least one lowercase letter', _hasLowercase),
          const SizedBox(height: 6),
          rule('At least one digit', _hasDigit),
          const SizedBox(height: 6),
          rule('Passwords match', _isConfirmMatched),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const BrandedAppBar(backgroundColor: Colors.transparent),
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
                const AuthHeader(),
                const SizedBox(height: 32),
                Text(
                  'Reset Password',
                  style: context.textStyles.heading2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new password for your account.',
                  textAlign: TextAlign.center,
                  style: context.textStyles.body
                      .copyWith(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 24),
                Consumer<AuthController>(
                  builder: (context, ctrl, _) {
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
                          children: [
                            _buildPasswordRules(),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              labelText: 'New Password',
                              hintText: 'Enter new password',
                              obscureText: _hidePassword,
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: context.colors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _confirmController,
                              labelText: 'Confirm Password',
                              hintText: 'Re-enter new password',
                              obscureText: _hideConfirm,
                              prefixIcon: Icon(Icons.lock_reset_outlined,
                                  color: context.colors.primary),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _hideConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () => setState(
                                    () => _hideConfirm = !_hideConfirm),
                              ),
                              validator: _validateConfirm,
                            ),
                            const SizedBox(height: 32),
                            AppButton(
                              text: 'Reset Password',
                              onPressed: _submit,
                              isLoading: ctrl.isLoading,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
