import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.person_add, size: 60, color: Colors.blue),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    AppInput(
                      controller: name,
                      hint: "Full Name",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: email,
                      hint: "Email",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: password,
                      hint: "Password",
                      icon: Icons.lock,
                      obscure: true,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: "Create Account",
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have account?"),
                  TextButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("Login"),
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
