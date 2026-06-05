import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final dynamic data;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSettingsTap;

  const DashboardHeader({
    super.key,
    required this.data,
    this.onSearchTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.adminName.toUpperCase()} · ICARE HQ',
                style: const TextStyle(
                  fontSize: 11, 
                  fontWeight: FontWeight.w700, 
                  color: Colors.black38, 
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                data.adminName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
        _buildIconButton(Icons.search, onSearchTap),
        const SizedBox(width: 10),
        _buildIconButton(Icons.settings_outlined, onSettingsTap),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12.withOpacity(0.05)),
        ),
        child: Icon(icon, color: const Color(0xFF334155), size: 20),
      ),
    );
  }
}