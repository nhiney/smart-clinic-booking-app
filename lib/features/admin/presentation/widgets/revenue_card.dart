import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';

class RevenueCard extends StatelessWidget {
  final StatItemEntity revenue;
  final StatItemEntity appointments;
  final StatItemEntity hospitals;

  const RevenueCard({
    super.key,
    required this.revenue,
    required this.appointments,
    required this.hospitals,
  });

  @override
  Widget build(BuildContext context) {
    // 🌟 TỰ TÍNH TOÁN ĐỘNG: Lấy tổng doanh thu chia cho số lượt hẹn từ Firestore
    final double avgPerVisit = appointments.value > 0 
        ? (revenue.value / appointments.value) 
        : 0.0;

    // Tự động format định dạng hiển thị ví dụ: 1800 -> 1.8K
    final String formattedTransactions = appointments.value >= 1000
        ? '${(appointments.value / 1000).toStringAsFixed(1)}K'
        : appointments.value.toInt().toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2042), Color(0xFF1E40AF), Color(0xFF3B82F6)],
          stops: [0.1, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG DOANH THU · HỆ THỐNG',
            style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('đ', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w400)),
              Text('${revenue.value.toInt()}M', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), 
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Icon(
                      revenue.percentageChange >= 0 ? Icons.arrow_drop_up : Icons.arrow_drop_down, 
                      color: Colors.white, 
                      size: 16,
                    ),
                    Text(
                      '${revenue.percentageChange.abs().toStringAsFixed(1)}%', 
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${revenue.absoluteChange >= 0 ? "+đ" : "-đ"}${revenue.absoluteChange.abs()}M vs kỳ trước',
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubStat(formattedTransactions, 'Giao dịch'),
              _buildSubStat('đ${avgPerVisit.toStringAsFixed(0)}K', 'TB/lượt'),
              _buildSubStat('${revenue.percentageChange.clamp(0, 100).toInt()}%', 'Đã thu'),
              _buildSubStat('${hospitals.value.toInt()}', 'BV đóng góp'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSubStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}