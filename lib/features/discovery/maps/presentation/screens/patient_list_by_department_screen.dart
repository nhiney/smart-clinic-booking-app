import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/theme/typography/app_text_styles.dart';
import '../../data/models/department_patient.dart';
import '../controllers/hospital_detail_controller.dart';
import './patient_detail_screen.dart';

/// Danh sách bệnh nhân của một khoa. Nhấn vào một bệnh nhân để xem chi tiết.
class PatientListByDepartmentScreen extends ConsumerWidget {
  final String departmentId;
  final String departmentName;

  const PatientListByDepartmentScreen({
    super.key,
    required this.departmentId,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPatients = ref.watch(departmentPatientsProvider(departmentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(departmentName, style: AppTextStyles.subtitle),
            Text('Danh sách bệnh nhân',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
      body: asyncPatients.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Không thể tải danh sách bệnh nhân.\n$e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ),
        data: (patients) {
          if (patients.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline_rounded, size: 56, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text('Chưa có bệnh nhân trong khoa này.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(departmentPatientsProvider(departmentId).future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: patients.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _PatientTile(
                patient: patients[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PatientDetailScreen(
                      patient: patients[i],
                      departmentName: departmentName,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  final DepartmentPatient patient;
  final VoidCallback onTap;

  const _PatientTile({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final meta = <String>[
      if (p.age != null) '${p.age} tuổi',
      if (p.gender.isNotEmpty) p.gender,
    ].join(' • ');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: p.avatarUrl.isNotEmpty
                    ? CachedNetworkImageProvider(p.avatarUrl)
                    : null,
                child: p.avatarUrl.isEmpty
                    ? Text(
                        p.name.trim().isNotEmpty ? p.name.trim().substring(0, 1) : '?',
                        style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: AppTextStyles.subtitle),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(meta,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                    if (p.diagnosis.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.diagnosis,
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
