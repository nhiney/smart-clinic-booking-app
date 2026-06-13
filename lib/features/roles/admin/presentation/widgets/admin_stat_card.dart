import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final dynamic item; 
  final IconData icon;
  final Color color;
  final bool isCompact;
  final bool isCurrency;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.item,
    required this.icon,
    required this.color,
    this.isCompact = false,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue = "";
    if (isCurrency) {
      double millions = item.value / 1000000;
      displayValue = "đ${millions.toInt()}M";
    } else if (isCompact && item.value >= 1000) {
      double thousands = item.value / 1000;
      displayValue = "${thousands.toStringAsFixed(1)}K";
    } else {
      displayValue = item.value.toInt().toString();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color.withOpacity(0.8), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_drop_up, color: color, size: 14),
                    Text(
                      '+${item.absoluteChange.toInt()}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 25,
                  child: LineChart(_getSparklineConfig(item.chartData)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _getSparklineConfig(List<double> data) {
    List<double> chartValues = List.from(data);
    if (chartValues.isEmpty || chartValues.every((v) => v == 0)) {
      chartValues = [1, 1, 1, 1, 1, 1, 1];
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (chartValues.length - 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: chartValues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          isCurved: true,
          curveSmoothness: 0.4,
          color: color,
          barWidth: 2.0,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false), 
        ),
      ],
    );
  }
}