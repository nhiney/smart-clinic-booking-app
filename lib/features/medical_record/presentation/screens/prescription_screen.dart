import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for prescriptions
    final prescriptions = [
      {
        'id': 'RX-88291',
        'doctor': 'BS. Nguyễn Văn A',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'diagnosis': 'Viêm họng cấp',
        'medicines': [
          {'name': 'Amoxicillin 500mg', 'dosage': '1 viên x 3 lần/ngày', 'duration': '5 ngày'},
          {'name': 'Paracetamol 500mg', 'dosage': '1 viên khi sốt > 38.5 độ', 'duration': '3 ngày'},
        ],
        'status': 'active'
      },
      {
        'id': 'RX-77102',
        'doctor': 'BS. Lê Thị B',
        'date': DateTime.now().subtract(const Duration(days: 30)),
        'diagnosis': 'Rối loạn tiêu hóa',
        'medicines': [
          {'name': 'Smecta', 'dosage': '1 gói x 2 lần/ngày', 'duration': '3 ngày'},
        ],
        'status': 'completed'
      }
    ];

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(
        title: "Đơn thuốc của tôi",
        showBackButton: true,
      ),
      body: prescriptions.isEmpty
          ? const EmptyStateWidget(
              title: "Bạn chưa có đơn thuốc nào.",
              icon: Icons.medication_outlined,
            )
          : ListView.builder(
              padding: EdgeInsets.all(context.spacing.l),
              itemCount: prescriptions.length,
              itemBuilder: (context, index) {
                final rx = prescriptions[index];
                return _buildPrescriptionCard(context, rx);
              },
            ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, Map<String, dynamic> rx) {
    final bool isActive = rx['status'] == 'active';
    final List medicines = rx['medicines'] as List;

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
                      rx['id'],
                      style: context.textStyles.bodyBold.copyWith(color: context.colors.primary),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(rx['date']),
                      style: context.textStyles.caption.copyWith(color: context.colors.textHint),
                    ),
                  ],
                ),
                _buildStatusChip(context, isActive),
              ],
            ),
            Divider(height: context.spacing.l, color: context.colors.divider),
            Text(
              "Chẩn đoán: ${rx['diagnosis']}",
              style: context.textStyles.bodyBold,
            ),
            const SizedBox(height: 4),
            Text(
              "Bác sĩ kê đơn: ${rx['doctor']}",
              style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chi tiết đơn thuốc:",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...medicines.map((m) => _buildMedicineItem(context, m)).toList(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/under-development?title=${Uri.encodeComponent('Tải PDF đơn thuốc')}'),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text("Tải PDF"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.primary,
                      side: BorderSide(color: context.colors.primary),
                      shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/under-development?title=${Uri.encodeComponent('Đặt nhắc uống thuốc')}'),
                    icon: const Icon(Icons.alarm_add_rounded, size: 18),
                    label: const Text("Đặt nhắc hẹn"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
                    ),
                  ),
                ),
              ],
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
        color: isActive ? AppColors.success.withOpacity(0.1) : context.colors.textHint.withOpacity(0.1),
        borderRadius: context.radius.xsRadius,
      ),
      child: Text(
        isActive ? "ĐANG SỬ DỤNG" : "ĐÃ HOÀN THÀNH",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: isActive ? AppColors.success : context.colors.textHint,
        ),
      ),
    );
  }

  Widget _buildMedicineItem(BuildContext context, Map<String, dynamic> medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.sRadius,
        border: Border.all(color: context.colors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medication_liquid_rounded, color: context.colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medicine['name'], style: context.textStyles.bodyBold),
                Text(
                  "${medicine['dosage']} • ${medicine['duration']}",
                  style: context.textStyles.caption.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
