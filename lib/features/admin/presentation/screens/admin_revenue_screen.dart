import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';
import '../widgets/revenue_card.dart';
import '../widgets/revenue_chart_card.dart';
import '../widgets/top_hospital_item.dart';

class AdminRevenueScreen extends StatelessWidget {
  final AdminDashboardEntity dashboardData;

  const AdminRevenueScreen({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final revenueStat = dashboardData.revenue;
    final appointmentStat = dashboardData.appointments;
    final hospitalStat = dashboardData.hospitals;

    final double avgPerVisit = appointmentStat.value > 0 
        ? (revenueStat.value / appointmentStat.value) 
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F9FC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Doanh thu',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RevenueCard(
                revenue: revenueStat,
                appointments: appointmentStat,
                hospitals: hospitalStat,
              ),
              const SizedBox(height: 16),
              RevenueChartCard(chartData: revenueStat.chartData),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BV doanh thu cao nhất',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Tất cả', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                  )
                ],
              ),
              const SizedBox(height: 8),
              dashboardData.topHospitals.isEmpty
                  ? const Center(child: Text('Không có dữ liệu xếp hạng bệnh viện.'))
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: dashboardData.topHospitals.map((hospitalItem) {
                          return TopHospitalItem(hospital: hospitalItem);
                        }).toList(),
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}