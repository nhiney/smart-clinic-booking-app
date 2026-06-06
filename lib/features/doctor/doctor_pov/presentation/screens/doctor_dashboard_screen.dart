import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/features/doctor/patient_pov/presentation/controllers/doctor_controller.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';

import '../widgets/doctor_header_section.dart';
import '../widgets/today_progress_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/next_patient_card.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorController = context.watch<DoctorController>();
    final doctor = doctorController.currentDoctor;
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;

    if (user != null && doctor == null && !doctorController.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        doctorController.fetchDoctorProfile(user.id);
      });
    }

    if (doctorController.isLoading && doctor == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (doctor == null) {
      return const Scaffold(
        body: Center(child: Text('Không tải được thông tin bác sĩ.')),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF8FAFC), // slate50
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.spacing.s),

                // ─── 1. Header ──────────────────────────────────────────
                const DoctorHeaderSection(),

                SizedBox(height: context.spacing.l),

                // ─── 2. Date & Title ────────────────────────────────────
                _DateTitleSection(),

                SizedBox(height: context.spacing.l),

                // ─── 3. Today Progress Card ─────────────────────────────
                const TodayProgressCard(),

                SizedBox(height: context.spacing.m),

                // ─── 4. Two Stat Cards ──────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
                  child: Row(
                    children: [
                      const StatCard(
                        title: 'TUẦN NÀY',
                        value: '47',
                        changeText: '+12.7%',
                        isPositive: true,
                        subtitle: 'bệnh nhân',
                        sparklineData: [
                          28, 32, 25, 30, 35, 33, 38, 36, 42, 40, 44, 47,
                        ],
                      ),
                      SizedBox(width: context.spacing.s + 4),
                      StatCard(
                        title: 'ĐÁNH GIÁ',
                        value: doctor?.rating.toStringAsFixed(1) ?? '4.9',
                        changeText: '+0.1',
                        isPositive: true,
                        subtitle: 'trên ${doctor?.totalReviews ?? 312} lượt',
                        sparklineData: const [
                          4.5, 4.6, 4.5, 4.7, 4.6, 4.7, 4.8, 4.7, 4.8, 4.8, 4.9, 4.9,
                        ],
                        onTap: () {
                          if (doctor != null) {
                            context.push(
                              '/doctor/review/${doctor.id}?isDoctorPOV=true',
                              extra: doctor.name,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.spacing.l + 4),

                // ─── 5. Next Patient Section ────────────────────────────
                const NextPatientCard(),

                SizedBox(height: context.spacing.m),

                _DoctorQuickActions(
                  onOpenProfile: () => context.push('/patient/0451'),
                  onOpenEncounter: () => context.push('/encounter/0451'),
                  onOpenTreatmentPlan: () => context.push('/encounter/0451/plan'),
                ),

                SizedBox(height: context.spacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Date & Title Section ────────────────────────────────────────────────────
class _DateTitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Text(
            'Thứ năm, 23 tháng 5',
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),

          SizedBox(height: context.spacing.xs),

          // Title
          Text(
            'Lịch trực hôm nay',
            style: context.textStyles.heading1.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: context.spacing.s),

          // Summary with bold parts
          RichText(
            text: TextSpan(
              style: context.textStyles.body.copyWith(
                color: context.colors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Đã khám '),
                TextSpan(
                  text: '5 ca',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const TextSpan(text: ', còn '),
                TextSpan(
                  text: '7 ca',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const TextSpan(text: '. Bệnh nhân tiếp theo trong '),
                TextSpan(
                  text: '18 phút',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorQuickActions extends StatelessWidget {
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenEncounter;
  final VoidCallback onOpenTreatmentPlan;

  const _DoctorQuickActions({
    required this.onOpenProfile,
    required this.onOpenEncounter,
    required this.onOpenTreatmentPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lối tắt lâm sàng',
            style: context.textStyles.heading3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ActionPill(
                label: 'Hồ sơ bệnh nhân',
                icon: Icons.person_outline_rounded,
                onTap: onOpenProfile,
              ),
              _ActionPill(
                label: 'Khám SOAP',
                icon: Icons.medical_services_outlined,
                onTap: onOpenEncounter,
              ),
              _ActionPill(
                label: 'Kế hoạch điều trị',
                icon: Icons.description_outlined,
                onTap: onOpenTreatmentPlan,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: context.colors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: context.textStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




