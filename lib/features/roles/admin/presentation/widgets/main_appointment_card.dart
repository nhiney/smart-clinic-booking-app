import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MainAppointmentCard extends StatelessWidget {
  final dynamic appointments;
  final String currentPeriod;

  const MainAppointmentCard({
    super.key,
    required this.appointments,
    required this.currentPeriod,
  });

  List<String> _getDynamicWeekDays() {
    final now = DateTime.now();
    final weekdayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    List<String> days = [];

    for (int i = 0; i < 7; i++) {
      final targetDate = now.subtract(Duration(days: i));
      days.add(weekdayLabels[targetDate.weekday % 7]);
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    final dynamicDays = _getDynamicWeekDays();
    final formattedValue = appointments.value.toInt()
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');

    return Container(
      width: double.infinity,
      height: 265,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2042),
            Color(0xFF1E40AF),
            Color(0xFF3B82F6),
          ],
          stops: [0.1, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                border: Border.all(color: Colors.white.withOpacity(0.04), width: 1.5),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TỔNG LỊCH HẸN · ${currentPeriod.toUpperCase()}', 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white.withOpacity(0.6), 
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formattedValue, 
                  style: const TextStyle(
                    fontSize: 42, 
                    fontWeight: FontWeight.w800, 
                    color: Colors.white, 
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15), 
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_drop_up, color: Colors.white, size: 16), 
                          Text(
                            '${appointments.percentageChange}%', 
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${appointments.absoluteChange} vs kỳ trước', 
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6), 
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  height: 65, 
                  child: LineChart(_getMainChartConfig(appointments.chartData)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: dynamicDays.map((day) {
                    final isToday = day == dynamicDays.first;
                    return SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white.withOpacity(0.35), 
                          fontSize: 11, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _getMainChartConfig(List<dynamic> data) {
    List<double> chartValues = data.map((e) => (e as num).toDouble()).toList();
    
    if (chartValues.isEmpty || chartValues.every((v) => v == 0)) {
      chartValues = [0, 0, 0, 0, 0, 0, 0];
    }

    chartValues = chartValues.reversed.toList();

    double minV = chartValues.reduce((a, b) => a < b ? a : b);
    double maxV = chartValues.reduce((a, b) => a > b ? a : b);
    double padding = (maxV - minV) * 0.15;
    if (padding == 0) padding = 1.0;

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0, maxX: (chartValues.length - 1).toDouble(),
      minY: minV - padding < 0 ? 0 : minV - padding,
      maxY: maxV + padding,
      lineBarsData: [
        LineChartBarData(
          spots: chartValues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          isCurved: true,
          curveSmoothness: 0.35,
          color: Colors.white,
          barWidth: 3.0,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.25), Colors.white.withOpacity(0.0)],
            ),
          ),
        ),
      ],
    );
  }
}