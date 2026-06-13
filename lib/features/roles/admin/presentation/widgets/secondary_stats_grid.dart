import 'package:flutter/material.dart';
import './admin_stat_card.dart';

class SecondaryStatsGrid extends StatelessWidget {
  final dynamic data;

  const SecondaryStatsGrid({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14, 
      mainAxisSpacing: 14,
      childAspectRatio: 0.95,
      children: [
        AdminStatCard(title: 'BỆNH VIỆN', item: data.hospitals, icon: Icons.business_rounded, color: Colors.blue),
        AdminStatCard(title: 'BÁC SĨ', item: data.doctors, icon: Icons.people_alt_rounded, color: Colors.teal),
        AdminStatCard(title: 'BỆNH NHÂN', item: data.patients, icon: Icons.person_rounded, color: Colors.orange, isCompact: true),
        AdminStatCard(title: 'DOANH THU', item: data.revenue, icon: Icons.bookmark_border_outlined, color: Colors.purple, isCurrency: true),
      ],
    );
  }
}