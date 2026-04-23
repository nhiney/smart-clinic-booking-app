import 'package:flutter/material.dart';

class QuickActionsGrid extends StatelessWidget {
  final String userRole;
  final VoidCallback onBookAppointment;
  final VoidCallback onViewAppointments;
  final VoidCallback onMedicalRecords;
  final VoidCallback onPrescriptions;
  final VoidCallback onContactSupport;
  final VoidCallback onVoiceAssistant;
  final VoidCallback onInpatientAdmission;
  final VoidCallback onNotificationSettings;
  final VoidCallback onPricing;
  final VoidCallback onSurveys;
  final VoidCallback onProfile;

  const QuickActionsGrid({
    super.key,
    required this.userRole,
    required this.onBookAppointment,
    required this.onViewAppointments,
    required this.onMedicalRecords,
    required this.onPrescriptions,
    required this.onContactSupport,
    required this.onVoiceAssistant,
    required this.onInpatientAdmission,
    required this.onNotificationSettings,
    required this.onPricing,
    required this.onSurveys,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          // Header: Chức năng + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chức năng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D62A2),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Color(0xFF0D62A2), size: 18),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: 1,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    const Icon(Icons.search_rounded, color: Color(0xFF0D62A2), size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 4-column Grid
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.85,
            children: [
              _ActionItem(icon: Icons.stethoscope, label: 'Đặt khám', onTap: onBookAppointment),
              _ActionItem(icon: Icons.folder_shared_outlined, label: 'Lịch sử đặt\nkhám', onTap: onViewAppointments),
              _ActionItem(icon: Icons.payment_rounded, label: 'Thanh toán\nviện phí', onTap: onPricing),
              _ActionItem(icon: Icons.receipt_long_outlined, label: 'Hoá đơn', onTap: onPrescriptions),
              _ActionItem(icon: Icons.medical_information_outlined, label: 'Hồ sơ sức\nkhoẻ', onTap: onMedicalRecords),
              _ActionItem(icon: Icons.biotech_outlined, label: 'Kết quả cận\nlâm sàng', onTap: onSurveys),
              _ActionItem(icon: Icons.bed_rounded, label: 'Đăng ký\nnhập viện', onTap: onInpatientAdmission),
              _ActionItem(icon: Icons.headset_mic_outlined, label: 'Lắng nghe\nkhách hàng', onTap: onContactSupport),
              _ActionItem(icon: Icons.supervised_user_circle_outlined, label: 'Hướng dẫn', onTap: () {}),
              _ActionItem(icon: Icons.home_work_outlined, label: 'Theo dõi sức\nkhoẻ tại nhà', onTap: () {}),
              _ActionItem(icon: Icons.vaccines_outlined, label: 'Tiêm chủng', onTap: () {}),
              _ActionItem(icon: Icons.smart_toy_outlined, label: 'Hỏi - đáp\n(Chatbot)', onTap: onVoiceAssistant),
            ],
          ),
        ],
      ),
    );
  }
}


class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  const Color(0xFFF0F7FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D62A2).withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF0D62A2).withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF0D62A2),
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
