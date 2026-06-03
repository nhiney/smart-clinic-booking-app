import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/admin_controller.dart';

class AdminStatisticsScreen extends StatefulWidget {
  const AdminStatisticsScreen({super.key});

  @override
  State<AdminStatisticsScreen> createState() => _AdminStatisticsScreenState();
}

class _AdminStatisticsScreenState extends State<AdminStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().listenToSystemStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final String adminName = controller.currentAdminName;
    final String adminRole = controller.currentAdminRole;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 90.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(adminName, adminRole),
              const SizedBox(height: 24),
              _buildFilterTabs(controller),
              const SizedBox(height: 20),
              _buildMainChartCard(
                appointmentsCount: controller.totalAppointmentsCount,
                newAppointments: controller.newAppointmentsThisWeek,
                chartSpots: _getWeeklyUsageSpots(controller),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildStatCard(
                    title: "BỆNH VIỆN",
                    value: "12",
                    increment: "+1",
                    icon: Icons.store_outlined,
                    iconColor: const Color(0xFF1E88E5),
                    chartColor: Colors.blue,
                  ),
                  _buildStatCard(
                    title: "BÁC SĨ",
                    value: controller.totalDoctorsCount.toString(),
                    increment: "+${controller.newDoctorsThisWeek}",
                    icon: Icons.mediation_outlined,
                    iconColor: const Color(0xFF00B0FF),
                    chartColor: Colors.cyan,
                  ),
                  _buildStatCard(
                    title: "BỆNH NHÂN",
                    value: controller.totalUsers.toString(),
                    increment: "+${controller.newUsersThisWeek}",
                    icon: Icons.people_outline_rounded,
                    iconColor: const Color(0xFFFFB300),
                    chartColor: Colors.orange,
                  ),
                  _buildStatCard(
                    title: "DOANH THU",
                    value: "đ${(controller.totalRevenue / 1000000).toStringAsFixed(0)}M",
                    increment: "+${controller.revenueGrowthRate.toStringAsFixed(0)}%",
                    icon: Icons.assignment_outlined,
                    iconColor: const Color(0xFF7E57C2),
                    chartColor: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String role) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFF0A192F),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$role • ICARE HQ",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 0.5),
            ),
            const SizedBox(height: 2),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
            ),
          ],
        ),
        const Spacer(),
        _buildHeaderIconButton(Icons.search_rounded),
        const SizedBox(width: 10),
        _buildHeaderIconButton(Icons.settings_outlined),
      ],
    );
  }

  Widget _buildHeaderIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12.withOpacity(0.05)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 22),
        onPressed: () {},
      ),
    );
  }

  Widget _buildFilterTabs(AdminController controller) {
    final now = DateTime.now();
    final String timestamp = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Bảng điều khiển", style: TextStyle(fontSize: 14, color: Colors.black45)),
        const Text("Tổng quan hệ thống", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 8, 
              height: 8, 
              decoration: BoxDecoration(
                color: controller.systemStatusColor, 
                shape: BoxShape.circle
              )
            ),
            const SizedBox(width: 6),
            const Text("Tất cả dịch vụ ", style: TextStyle(fontSize: 12, color: Colors.black54)),
            Text(
              controller.systemUptimePercentage,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Spacer(),
            Text(
              "Cập nhật $timestamp", 
              style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabItem("7 ngày", isSelected: true),
              _buildTabItem("30 ngày"),
              _buildTabItem("Quý"),
              _buildTabItem("Năm"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0A192F) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildMainChartCard({
    required int appointmentsCount, 
    required int newAppointments, 
    required List<FlSpot> chartSpots,
  }) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1E36), Color(0xFF15447C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF15447C).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TỔNG LỊCH HẸN • HỆ THỐNG", style: TextStyle(fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(
                  appointmentsCount.toString(),
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
                ),
                Row(
                  children: [
                    const Icon(Icons.arrow_drop_up_rounded, color: Colors.greenAccent, size: 24),
                    const Text("Tăng trưởng", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text("  +$newAppointments lịch mới tuần này", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartSpots,
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String increment,
    required IconData icon,
    required Color iconColor,
    required Color chartColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 0.5)),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A192F))),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_drop_up_rounded, color: Colors.green, size: 16),
                    Text(increment, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(
                width: 50,
                height: 20,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [const FlSpot(0, 1), const FlSpot(1, 1.2), const FlSpot(2, 3), const FlSpot(3, 2.8), const FlSpot(4, 4)],
                        isCurved: true,
                        color: chartColor,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getWeeklyUsageSpots(AdminController controller) {
    if (controller.totalAppointmentsCount == 0) {
      return [const FlSpot(0, 0), const FlSpot(6, 0)];
    }
    double base = controller.totalAppointmentsCount.toDouble();
    return [
      FlSpot(0, base * 0.2),
      FlSpot(1, base * 0.15),
      FlSpot(2, base * 0.3),
      FlSpot(3, base * 0.25),
      FlSpot(4, base * 0.4),
      FlSpot(5, base * 0.5),
      FlSpot(6, base * 0.45),
    ];
  }
}