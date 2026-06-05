import 'package:flutter/material.dart';

class RevenueCard extends StatelessWidget {
  final double totalRevenue;
  final double growthPercentage;
  final double growthAbsolute;
  final String totalTransactions;
  final String averagePerVisit;
  final String collectedPercentage;
  final int hospitalCount;

  const RevenueCard({
    super.key,
    required this.totalRevenue,
    required this.growthPercentage,
    required this.growthAbsolute,
    required this.totalTransactions,
    required this.averagePerVisit,
    required this.collectedPercentage,
    required this.hospitalCount,
  });

  @override
  Widget build(BuildContext context) {
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
            'TỔNG DOANH THU · THÁNG 5/2026',
            style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('đ', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w400)),
              Text('${totalRevenue.toInt()}M', style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_drop_up, color: Colors.white, size: 16),
                    Text('$growthPercentage%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '+đ${growthAbsolute.toInt()}M vs tháng trước',
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
              _buildSubStat(totalTransactions, 'Giao dịch'),
              _buildSubStat(averagePerVisit, 'TB/lượt'),
              _buildSubStat(collectedPercentage, 'Đã thu'),
              _buildSubStat('$hospitalCount', 'BV đóng góp'),
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