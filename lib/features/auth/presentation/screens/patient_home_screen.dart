import 'package:flutter/material.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang chủ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event_available_rounded),
              label: const Text('Đặt lịch khám'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.history_rounded),
              label: const Text('Xem lịch sử khám'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_rounded),
              label: const Text('Hồ sơ cá nhân'),
            ),
          ],
        ),
      ),
    );
  }
}
