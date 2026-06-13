// lib/features/admin/presentation/widgets/doctor_status_tab_bar.dart
import 'package:flutter/material.dart';

class DoctorStatusTabBar extends StatelessWidget {
  final String activeTab;
  final Map<String, int> counts;
  final ValueChanged<String> onTabChanged;

  const DoctorStatusTabBar({
    super.key,
    required this.activeTab,
    required this.counts,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = ['Chờ duyệt', 'Đã duyệt', 'Từ chối'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tabs.map((tab) {
        final isSelected = activeTab == tab;
        final count = counts[tab] ?? 0;

        return GestureDetector(
          onTap: () => onTabChanged(tab),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    tab,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (count > 0 || isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 3,
                width: 65,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}