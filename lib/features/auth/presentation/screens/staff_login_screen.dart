import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/auth_header.dart';
import '../controllers/auth_controller.dart';
import '../navigation/role_navigation.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final l10n = AppLocalizations.of(context)!;
    final authController = context.read<AuthController>();
    
    final success = await authController.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      navigateByRole(context, authController.currentUser?.role ?? 'doctor');
    } else {
      _showError(authController.errorMessage ?? l10n.error_login_failed);
    }
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: BrandedAppBar(
        backgroundColor: Colors.transparent,
        leading: InkWell(
          onTap: () => context.go('/login'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.spacing.l),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const AuthHeader(),
              const SizedBox(height: 32),
              Text(
                l10n.staff_login_title,
                style: context.textStyles.heading2.copyWith(
                  fontWeight: FontWeight.w800,
                  color: context.colors.primaryDark,
                ),
              ),
              const SizedBox(height: 24),
              _buildStaffLoginCard(l10n, authController),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffLoginCard(AppLocalizations l10n, AuthController controller) {
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
              l10n.email_label,
              style: context.textStyles.bodyBold.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: emailController,
              hintText: l10n.email_hint,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icon(Icons.email_outlined, color: context.colors.primary),
              validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
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
              validator: (val) => val == null || val.isEmpty ? l10n.required_field : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: l10n.login_button,
              onPressed: handleLogin,
              isLoading: controller.isLoading,
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
          ],
        ),
      ),
    );
  }
}
