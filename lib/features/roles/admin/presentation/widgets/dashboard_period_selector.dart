import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';

class DashboardPeriodSelector extends StatelessWidget {
  final AdminController controller;

  const DashboardPeriodSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final periods = ['7 ngày', '30 ngày', 'Quý', 'Năm'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: periods.map((period) {
          final isSelected = controller.selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changePeriod(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, 
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}