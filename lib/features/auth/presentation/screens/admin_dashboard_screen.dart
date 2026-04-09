import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.admin_dashboard_title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ActionCard(title: l10n.admin_manage_hospital, icon: Icons.local_hospital_rounded),
            const SizedBox(height: 12),
            _ActionCard(title: l10n.admin_manage_department, icon: Icons.account_tree_rounded),
            const SizedBox(height: 12),
            _ActionCard(title: l10n.admin_manage_doctor, icon: Icons.medical_services_rounded),
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
