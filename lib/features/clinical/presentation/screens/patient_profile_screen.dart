import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../shared/widgets/medical_record_card.dart';
import '../../../../shared/widgets/patient_header_card.dart';
import '../../../../shared/widgets/sticky_bottom_action_bar.dart';
import '../../../../shared/widgets/vital_card.dart';
import '../riverpod/clinical_providers.dart';

class PatientProfileScreen extends ConsumerWidget {
  final String patientId;

  const PatientProfileScreen({
    super.key,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientProfileProvider(patientId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: 'Hồ sơ bệnh nhân',
        showBackButton: true,
      ),
      body: patientAsync.when(
        data: (patient) {
          final subtitle = '${patient.gender} • ${patient.age} tuổi • ${patient.code}';
          final recentVitals = patient.latestVital;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 700;
              final crossAxisCount = isTablet ? 4 : 3;

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  context.spacing.l,
                  context.spacing.m,
                  context.spacing.l,
                  120,
                ),
                children: [
                  PatientHeaderCard(
                    fullName: patient.fullName,
                    subtitle: subtitle,
                    code: patient.code,
                    bloodGroup: patient.bloodGroup,
                    weightLabel: '${patient.weight.toStringAsFixed(0)}kg',
                    alertLabel: patient.latestVital.alertLabel,
                    avatarUrl: patient.avatarUrl,
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(
                    title: 'CHỈ SỐ GẦN NHẤT',
                    subtitle: DateFormat('HH:mm, dd/MM').format(recentVitals.measuredAt),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isTablet ? 1.35 : 1.05,
                    children: [
                      VitalCard(
                        title: 'Huyết áp',
                        value: recentVitals.bloodPressureLabel,
                        unit: recentVitals.bloodPressureUnit,
                        isAlert: recentVitals.isBloodPressureHigh,
                      ),
                      VitalCard(
                        title: 'Nhịp tim',
                        value: '${recentVitals.heartRate}',
                        unit: 'bpm',
                        isAlert: recentVitals.isHeartRateHigh,
                      ),
                      VitalCard(
                        title: 'BMI',
                        value: patient.bmi.toStringAsFixed(1),
                        isAlert: recentVitals.isBmiHigh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle(title: 'TRIỆU CHỨNG HÔM NAY'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.symptoms.first,
                          style: context.textStyles.subtitle,
                        ),
                        const SizedBox(height: 10),
                        ...patient.symptoms.skip(1).map(
                              (symptom) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  '• $symptom',
                                  style: context.textStyles.bodySmall.copyWith(
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: patient.symptoms
                              .map(
                                (symptom) => Chip(
                                  label: Text(
                                    symptom,
                                    style: const TextStyle(
                                      color: Color(0xFFB45309), // amber700
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFFEF3C7), // amber100
                                  side: const BorderSide(color: Color(0xFFFDE68A)), // amber200
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionTitle(title: 'BỆNH ÁN GẦN ĐÂY'),
                  const SizedBox(height: 12),
                  ...patient.records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: MedicalRecordCard(record: record),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Không tải được hồ sơ: $error'),
        ),
      ),
      bottomNavigationBar: StickyBottomActionBar(
        primaryLabel: 'Lập bệnh án',
        onPrimaryTap: () => context.push('/encounter/$patientId'),
        secondaryLabel: 'Ghi chú',
        onSecondaryTap: () async {
          final noteController = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Ghi chú bệnh nhân'),
              content: TextField(
                controller: noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Nhập ghi chú nội bộ',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, noteController.text.trim()),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          );

          if (result != null && result.isNotEmpty) {
            await ref.read(patientRepositoryProvider).savePatientNote(patientId, result);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu ghi chú')),
              );
            }
          }
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: context.textStyles.subtitle.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: context.textStyles.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}
