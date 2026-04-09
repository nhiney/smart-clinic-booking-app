import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../controllers/auth_controller.dart';
import 'create_password_screen.dart';
import '../../../../core/widgets/branded_app_bar.dart';

import 'dart:async';

class OtpScreen extends StatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _countdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _resendOtp() {
    if (!_canResend) return;

    final authController = context.read<AuthController>();
    authController.verifyPhone(
      widget.phone,
      onCodeSent: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mã OTP đã được gửi lại')),
          );
          _startTimer();
        }
      },
      onAutoVerified: () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePasswordScreen(phoneNumber: widget.phone),
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
    );
  }

  void _verifyOtp() async {
    final authController = context.read<AuthController>();
    final success = await authController.verifyOtp(
      _otpController.text.trim(),
      name: null,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác minh thành công! Đang chuyển hướng...'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate home
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePasswordScreen(phoneNumber: widget.phone),
            ),
          );
        }
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Mã OTP chưa chính xác'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BrandedAppBar(
        title: "Xác nhận mã OTP",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mã xác thực đã được gửi đến phần tin nhắn của số điện thoại ${widget.phone}",
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 32),
              // 6-digit OTP Boxes
              Center(
                child: Stack(
                  children: [
                    // Hidden TextField
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        height: 0,
                        width: 0,
                        child: TextFormField(
                          controller: _otpController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          autofocus: true,
                          onChanged: (val) {
                            setState(() {});
                            if (val.length == 6) {
                              _verifyOtp();
                            }
                          },
                        ),
                      ),
                    ),
                    // Visible Boxes
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          String char = "";
                          if (_otpController.text.length > index) {
                            char = _otpController.text[index];
                          }
                          bool isFocused = _otpController.text.length == index;
                          return Container(
                            width: 45,
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isFocused ? AppColors.primary : Colors.grey.shade300,
                                width: isFocused ? 2 : 1,
                              ),
                              boxShadow: isFocused ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            child: Center(
                              child: Text(
                                char,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend
                        ? "Gửi lại mã OTP"
                        : "Gửi lại mã sau ${_countdown}s",
                    style: TextStyle(
                      color: _canResend ? AppColors.primary : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<AuthController>(
                builder: (context, auth, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text("Xác nhận", style: TextStyle(fontSize: 16)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
