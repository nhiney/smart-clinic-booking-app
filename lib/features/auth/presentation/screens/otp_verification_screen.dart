import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/core/widgets/app_button.dart';
import 'package:smart_clinic_booking/core/widgets/auth_header.dart';
import '../bloc/sign_up_bloc.dart';
import '../bloc/sign_up_event.dart';
import '../bloc/sign_up_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isError = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      // Nhập xong ô cuối → ẩn bàn phím
      FocusScope.of(context).unfocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_isError) setState(() => _isError = false);
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) return;
    
    context.read<SignUpBloc>().add(VerifyOtpEvent(otp));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SignUpBloc, SignUpState>(
      listener: (context, state) {
        if (state.error != null) {
          setState(() => _isError = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: context.colors.error),
          );
        }
        if (state.isSuccess) {
          debugPrint('[OTP] Verification success, moving to password screen');
          context.go('/create-password', extra: {
            'phone': widget.phoneNumber,
            'name': state.fullName,
          });
        }
      },
      child: BlocBuilder<SignUpBloc, SignUpState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: BrandedAppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(context.spacing.l),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    AuthHeader(),
                    const SizedBox(height: 32),
                    if (kDebugMode)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.bug_report, color: Colors.orange[700], size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'DEBUG MODE — Nhập mã OTP đã cấu hình trong Firebase Console (Test phone numbers).',
                                style: TextStyle(color: Colors.orange[800], fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      l10n.otp_title,
                      style: context.textStyles.heading2.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.colors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n.otp_hint} (${widget.phoneNumber})',
                      textAlign: TextAlign.center,
                      style: context.textStyles.body.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 45,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  style: context.textStyles.heading1.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 28,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: context.radius.mRadius,
                                      borderSide: BorderSide(
                                        color: _isError ? context.colors.error : context.colors.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: context.radius.mRadius,
                                      borderSide: BorderSide(color: context.colors.primary, width: 2.5),
                                    ),
                                  ),
                                  onChanged: (value) => _onOtpChanged(index, value),
                                  obscureText: false,
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),
                          AppButton(
                            text: l10n.continue_button,
                            onPressed: _verifyOtp,
                            isLoading: state.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
