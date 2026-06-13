import 'package:flutter/material.dart';

class DashboardTitleSection extends StatelessWidget {
  final dynamic data;

  const DashboardTitleSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bảng điều khiển', 
          style: TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        const Text(
          'Tổng quan hệ thống', 
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text('Tất cả dịch vụ ${data.systemUptime}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
            const SizedBox(width: 6),
            const Text('·', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Text('Cập nhật ${data.lastUpdated}', style: const TextStyle(fontSize: 13, color: Colors.black45)),
          ],
        )
      ],
    );
  }
}