import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            _ActionCard(title: 'Quản lý bệnh viện', icon: Icons.local_hospital_rounded),
            SizedBox(height: 12),
            _ActionCard(title: 'Quản lý khoa', icon: Icons.account_tree_rounded),
            SizedBox(height: 12),
            _ActionCard(title: 'Quản lý bác sĩ', icon: Icons.medical_services_rounded),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ActionCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}
