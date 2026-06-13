import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/widgets/app_text_field.dart';
import 'package:smart_clinic_booking/core/widgets/auth_header.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import '../controllers/auth_controller.dart';

enum _ForgotStep { enterPhone, enterOtp }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _ForgotStep _step = _ForgotStep.enterPhone;

  final _phoneController = TextEditingController();
  final _phoneFormKey = GlobalKey<FormState>();

  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  String _selectedCountryCode = '+84';
  static const List<String> _countryCodes = [
    '+84', '+1', '+44', '+81', '+82', '+86',
  ];

  String _phone = '';

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String _buildFullPhone(String raw) {
    var local = raw.trim();
    if (_selectedCountryCode == '+84' && local.startsWith('0')) {
      local = local.substring(1);
    }
    return '$_selectedCountryCode$local';
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your phone number.';
    if (_selectedCountryCode == '+84') {
      final regex = RegExp(r'^(0)?[3|5|7|8|9][0-9]{8}$');
      if (!regex.hasMatch(value.trim())) return 'Invalid Vietnamese phone number.';
    }
    return null;
  }

  void _sendOtp() {
    if (!_phoneFormKey.currentState!.validate()) return;
    _phone = _buildFullPhone(_phoneController.text);

    final ctrl = context.read<AuthController>();
    ctrl.sendOtpForPasswordReset(
      _phone,
      onCodeSent: () {
        if (!mounted) return;
        setState(() => _step = _ForgotStep.enterOtp);
      },
      onError: (err) {
        if (!mounted) return;
        _showSnackbar(err, isError: true);
      },
    );
  }

  void _verifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnackbar('Please enter all 6 OTP digits.', isError: true);
      return;
    }

    final ctrl = context.read<AuthController>();
    final success = await ctrl.verifyOtpForPasswordReset(otp);

    if (!mounted) return;
    if (success) {
      context.push('/reset-password', extra: {'phone': _phone});
    } else {
      _showSnackbar(ctrl.errorMessage ?? 'Invalid OTP. Please try again.', isError: true);
    }
  }

  void _resendOtp() {
    final ctrl = context.read<AuthController>();
    if (ctrl.otpTimer > 0) return;
    _sendOtp();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? context.colors.error : context.colors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BrandedAppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.primary),
          onPressed: () {
            if (_step == _ForgotStep.enterOtp) {
              setState(() => _step = _ForgotStep.enterPhone);
            } else {
              context.pop();
            }
          },
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
                  'Forgot Password',
                  style: context.textStyles.heading2.copyWith(
                    fontWeight: FontWeight.w800,
                    color: context.colors.primaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _step == _ForgotStep.enterPhone
                      ? 'Enter your registered phone number to receive a verification code.'
                      : 'Enter the 6-digit OTP sent to $_phone',
                  textAlign: TextAlign.center,
                  style: context.textStyles.body
                      .copyWith(color: context.colors.textSecondary),
                ),
                const SizedBox(height: 32),
                _step == _ForgotStep.enterPhone
                    ? _buildPhoneStep()
                    : _buildOtpStep(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Consumer<AuthController>(
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
            key: _phoneFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: context.textStyles.bodyBold.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _phoneController,
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  prefixIcon: _buildCountryCodePicker(),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Send OTP',
                  onPressed: _sendOtp,
                  isLoading: ctrl.isLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpStep() {
    return Consumer<AuthController>(
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _otpControllers[i],
                      focusNode: _otpFocusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: context.textStyles.heading1.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: context.radius.mRadius,
                          borderSide: BorderSide(
                            color: context.colors.divider,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: context.radius.mRadius,
                          borderSide:
                              BorderSide(color: context.colors.primary, width: 2.5),
                        ),
                      ),
                      onChanged: (v) {
                        if (v.isNotEmpty && i < 5) {
                          _otpFocusNodes[i + 1].requestFocus();
                        } else if (v.isEmpty && i > 0) {
                          _otpFocusNodes[i - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Verify OTP',
                onPressed: _verifyOtp,
                isLoading: ctrl.isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: ctrl.otpTimer > 0 ? null : _resendOtp,
                child: Text(
                  ctrl.otpTimer > 0
                      ? 'Resend OTP in ${ctrl.otpTimer}s'
                      : 'Resend OTP',
                  style: context.textStyles.bodyBold.copyWith(
                    color: ctrl.otpTimer > 0
                        ? context.colors.textHint
                        : context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountryCodePicker() {
    return Container(
      width: 70,
      alignment: Alignment.center,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          iconSize: 18,
          items: _countryCodes
              .map((code) => DropdownMenuItem(
                    value: code,
                    child: Text(code, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: (val) => setState(() => _selectedCountryCode = val!),
        ),
      ),
    );
  }
}
