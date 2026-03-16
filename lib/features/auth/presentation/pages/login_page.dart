import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  void login() async {
    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login success")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Smart Clinic",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  "Book doctor appointments easily",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              AppInput(
                controller: emailController,
                hint: "Email",
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              AppInput(
                controller: passwordController,
                hint: "Password",
                icon: Icons.lock,
                obscure: hidePassword,
                suffix: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 30),
              AppButton(
                text: "Login",
                loading: loading,
                onPressed: login,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot password?"),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Continue with Google"),
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have account?"),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: const Text("Register"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
