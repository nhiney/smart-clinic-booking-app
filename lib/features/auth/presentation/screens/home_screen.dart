import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Clinic"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthController>().logout();

              context.go("/login");
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to Smart Clinic",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
