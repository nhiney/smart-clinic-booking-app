import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();

    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.register(
      nameController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Đăng ký thất bại'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white70),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 30,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text("Tạo tài khoản", style: AppTextStyles.heading2),
                            const SizedBox(height: 24),

                            // Name
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: "Họ và tên",
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Vui lòng nhập tên';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Phone
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: "Số điện thoại",
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Vui lòng nhập số điện thoại';
                                if (val.length < 9) return 'Số điện thoại không hợp lệ';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Password
                            TextFormField(
                              controller: passwordController,
                              obscureText: hidePassword,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    hidePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => hidePassword = !hidePassword);
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu';
                                if (val.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirm Password
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Xác nhận mật khẩu",
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                              validator: (val) {
                                if (val != passwordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Register button
                            Consumer<AuthController>(
                              builder: (_, auth, __) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: auth.isLoading ? null : handleRegister,
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text("ĐĂNG KÝ"),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 14),

                            // Login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Đã có tài khoản? ", style: AppTextStyles.bodySmall),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text("Đăng nhập", style: AppTextStyles.link),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
