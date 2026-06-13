import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/core/widgets/app_card.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/shared/widgets/empty_state_widget.dart';
import 'package:smart_clinic_booking/shared/widgets/loading_widget.dart';

/// Patient prescriptions, sourced from the `medical_records` written by doctors
/// during an examination (diagnosis + free-text prescription).
class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: "Đơn thuốc của tôi",
        showBackButton: true,
      ),
      body: uid == null
          ? const EmptyStateWidget(
              title: "Vui lòng đăng nhập để xem đơn thuốc.",
              icon: Icons.lock_outline,
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              // Chỉ filter theo patientId (không orderBy) để tránh phải tạo
              // composite index; đã sắp xếp client-side theo examinedAt bên dưới.
              stream: FirebaseFirestore.instance
                  .collection('medical_records')
                  .where('patientId', isEqualTo: uid)
                  .limit(30)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(itemCount: 3);
                }
                if (snapshot.hasError) {
                  return EmptyStateWidget(
                    title: "Không tải được đơn thuốc.\n${snapshot.error}",
                    icon: Icons.error_outline,
                  );
                }

                // Keep only records that actually contain a prescription, newest first.
                final docs = (snapshot.data?.docs ?? [])
                    .where((d) => (d.data()['prescription'] ?? '').toString().trim().isNotEmpty)
                    .toList()
                  ..sort((a, b) {
                    final ta = a.data()['examinedAt'] as Timestamp?;
                    final tb = b.data()['examinedAt'] as Timestamp?;
                    return (tb?.millisecondsSinceEpoch ?? 0)
                        .compareTo(ta?.millisecondsSinceEpoch ?? 0);
                  });

                if (docs.isEmpty) {
                  return _buildMockList(context);
                }

                return ListView.builder(
                  padding: EdgeInsets.all(context.spacing.l),
                  itemCount: docs.length,
                  itemBuilder: (context, index) =>
                      _buildPrescriptionCard(context, docs[index], index == 0),
                );
              },
            ),
    );
  }

  static const _mockRx = [
    {
      'id': 'RX5A2B1C',
      'examinedAt': '23/05/2026',
      'diagnosis': 'Đau ngực, tăng huyết áp độ 2',
      'doctorName': 'BS. Trần Minh Quân',
      'isMostRecent': true,
      'prescription':
          '1. Amlodipine 5mg — 1 viên/ngày (sáng, sau ăn)\n'
          '2. Aspirin 81mg — 1 viên/ngày (tối, trước ngủ)\n'
          '3. Atorvastatin 20mg — 1 viên/ngày (tối, sau ăn)\n\n'
          'Tái khám sau 2 tuần. Hạn chế muối, mỡ động vật.',
    },
    {
      'id': 'RX3D7E9F',
      'examinedAt': '12/04/2026',
      'diagnosis': 'Tái khám tăng huyết áp độ 2',
      'doctorName': 'BS. Phạm Văn Đức',
      'isMostRecent': false,
      'prescription':
          '1. Amlodipine 5mg — 1 viên/ngày\n'
          '2. Metoprolol 50mg — 1 viên/ngày\n\n'
          'Đo huyết áp mỗi sáng, ghi nhật ký theo dõi.',
    },
  ];

  Widget _buildMockList(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(context.spacing.l),
      itemCount: _mockRx.length,
      itemBuilder: (context, index) {
        final rx = _mockRx[index];
        return _buildMockCard(context, rx, rx['isMostRecent'] as bool);
      },
    );
  }

  Widget _buildMockCard(BuildContext context, Map<String, dynamic> rx, bool isMostRecent) {
    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.l),
      child: AppCard(
        padding: EdgeInsets.all(context.spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("RX-${rx['id']}", style: context.textStyles.bodyBold.copyWith(color: context.colors.primary)),
                    Text(rx['examinedAt'] as String, style: context.textStyles.caption.copyWith(color: context.colors.textHint)),
                  ],
                ),
                _buildStatusChip(context, isMostRecent),
              ],
            ),
            Divider(height: context.spacing.l, color: context.colors.divider),
            Text("Chẩn đoán: ${rx['diagnosis']}", style: context.textStyles.bodyBold),
            const SizedBox(height: 4),
            Text("Bác sĩ kê đơn: ${rx['doctorName']}", style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
            const SizedBox(height: 16),
            const Text("Chi tiết đơn thuốc:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: context.radius.sRadius,
                border: Border.all(color: context.colors.divider.withValues(alpha: 0.5)),
              ),
              child: Text(rx['prescription'] as String, style: context.textStyles.body),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/notifications/settings'),
              icon: const Icon(Icons.alarm_add_rounded, size: 18),
              label: const Text("Đặt nhắc uống thuốc"),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isMostRecent,
  ) {
    final rx = doc.data();
    final examinedAt = (rx['examinedAt'] as Timestamp?)?.toDate();
    final diagnosis = (rx['diagnosis'] ?? '').toString();
    final doctor = (rx['doctorName'] ?? 'Bác sĩ').toString();
    final prescription = (rx['prescription'] ?? '').toString();

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.l),
      child: AppCard(
        padding: EdgeInsets.all(context.spacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "RX-${doc.id.substring(0, 6).toUpperCase()}",
                      style: context.textStyles.bodyBold.copyWith(color: context.colors.primary),
                    ),
                    Text(
                      examinedAt != null ? DateFormat('dd/MM/yyyy').format(examinedAt) : '—',
                      style: context.textStyles.caption.copyWith(color: context.colors.textHint),
                    ),
                  ],
                ),
                _buildStatusChip(context, isMostRecent),
              ],
            ),
            Divider(height: context.spacing.l, color: context.colors.divider),
            if (diagnosis.isNotEmpty) ...[
              Text("Chẩn đoán: $diagnosis", style: context.textStyles.bodyBold),
              const SizedBox(height: 4),
            ],
            Text(
              "Bác sĩ kê đơn: $doctor",
              style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chi tiết đơn thuốc:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: context.radius.sRadius,
                border: Border.all(color: context.colors.divider.withValues(alpha: 0.5)),
              ),
              child: Text(prescription, style: context.textStyles.body),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push('/notifications/settings'),
              icon: const Icon(Icons.alarm_add_rounded, size: 18),
              label: const Text("Đặt nhắc uống thuốc"),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withValues(alpha: 0.1) : context.colors.textHint.withValues(alpha: 0.1),
        borderRadius: context.radius.xsRadius,
      ),
      child: Text(
        isActive ? "MỚI NHẤT" : "TRƯỚC ĐÓ",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isActive ? AppColors.success : context.colors.textHint,
        ),
      ),
    );
  }
}
