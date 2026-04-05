import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../../appointment/presentation/screens/booking_screen.dart';
import '../../../../core/widgets/icare_logo.dart';

class DoctorDetailScreen extends StatelessWidget {
  final DoctorEntity doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ICareLogo(size: 28, showText: false, isLight: true),
                SizedBox(width: 8),
                Text(
                  "ICARE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.star,
                        value: doctor.rating.toStringAsFixed(1),
                        label: "Đánh giá",
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.work_history,
                        value: "${doctor.experience}",
                        label: "Năm KN",
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.local_hospital,
                        value: "500+",
                        label: "Bệnh nhân",
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // About
                  Text("Giới thiệu", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    doctor.about.isNotEmpty
                        ? doctor.about
                        : "Chưa có thông tin giới thiệu.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Hospital
                  Text("Nơi làm việc", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: AppColors.shadow, blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doctor.hospital, style: AppTextStyles.subtitle),
                              const SizedBox(height: 2),
                              Text(
                                "TP. Hồ Chí Minh",
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available days
                  Text("Lịch khám", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: doctor.availableDays.map((day) {
                      return Chip(
                        label: Text(day, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primarySurface,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Time slots
                  if (doctor.availableTimeSlots.isNotEmpty) ...[
                    Text("Khung giờ khám", style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: doctor.availableTimeSlots.map((time) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            time,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Book button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(doctor: doctor),
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Đặt lịch khám"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
