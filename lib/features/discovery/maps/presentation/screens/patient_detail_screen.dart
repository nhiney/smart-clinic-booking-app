import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/theme/typography/app_text_styles.dart';
import '../../data/models/department_patient.dart';

/// Chi tiết thông tin một bệnh nhân của khoa.
class PatientDetailScreen extends StatelessWidget {
  final DepartmentPatient patient;
  final String? departmentName;

  const PatientDetailScreen({
    super.key,
    required this.patient,
    this.departmentName,
  });

  static String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final subtitleParts = <String>[
      if (p.age != null) '${p.age} tuổi',
      if (p.gender.isNotEmpty) p.gender,
      if (p.bloodType.isNotEmpty) 'Nhóm máu ${p.bloodType}',
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ bệnh nhân'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── header ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: p.avatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(p.avatarUrl)
                      : null,
                  child: p.avatarUrl.isEmpty
                      ? Text(
                          p.name.trim().isNotEmpty ? p.name.trim().substring(0, 1) : '?',
                          style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: AppTextStyles.heading2),
                      const SizedBox(height: 4),
                      if (subtitleParts.isNotEmpty)
                        Text(
                          subtitleParts.join(' • '),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      if (departmentName != null && departmentName!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _Chip(label: departmentName!, color: AppColors.primary),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── thông tin liên hệ ──────────────────────────────────
          _Section(
            title: 'Thông tin liên hệ',
            children: [
              _InfoRow(icon: Icons.phone_rounded, label: 'Điện thoại', value: p.phone),
              _InfoRow(icon: Icons.email_rounded, label: 'Email', value: p.email),
              _InfoRow(icon: Icons.cake_rounded, label: 'Ngày sinh', value: _formatDate(p.dateOfBirth)),
              _InfoRow(icon: Icons.location_on_rounded, label: 'Địa chỉ', value: p.address),
            ],
          ),
          const SizedBox(height: 16),

          // ── thông tin y tế ─────────────────────────────────────
          _Section(
            title: 'Thông tin y tế',
            children: [
              _InfoRow(icon: Icons.coronavirus_rounded, label: 'Chẩn đoán', value: p.diagnosis),
              _InfoRow(icon: Icons.history_edu_rounded, label: 'Tiền sử bệnh', value: p.medicalHistory),
              _InfoRow(
                icon: Icons.warning_amber_rounded,
                label: 'Dị ứng',
                value: p.allergies.isEmpty ? '—' : p.allergies.join(', '),
              ),
              _InfoRow(icon: Icons.bloodtype_rounded, label: 'Nhóm máu', value: p.bloodType),
              _InfoRow(
                icon: Icons.event_available_rounded,
                label: 'Khám gần nhất',
                value: _formatDate(p.lastVisit),
              ),
              _InfoRow(icon: Icons.medical_services_rounded, label: 'Bác sĩ phụ trách', value: p.assignedDoctor),
              _InfoRow(icon: Icons.badge_rounded, label: 'Số BHYT', value: p.insuranceId),
            ],
          ),
          const SizedBox(height: 16),

          // ── liên hệ khẩn cấp ───────────────────────────────────
          if (!p.emergencyContact.isEmpty)
            _Section(
              title: 'Liên hệ khẩn cấp',
              children: [
                _InfoRow(icon: Icons.person_rounded, label: 'Họ tên', value: p.emergencyContact.name),
                _InfoRow(icon: Icons.family_restroom_rounded, label: 'Quan hệ', value: p.emergencyContact.relation),
                _InfoRow(icon: Icons.phone_in_talk_rounded, label: 'Điện thoại', value: p.emergencyContact.phone),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── helpers ────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
