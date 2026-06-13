import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final dynamic patient; 
  const PatientDetailScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    String diagnosisDisplay = 'Chưa có chẩn đoán';
    try {
      if (patient.diagnoses is List && patient.diagnoses.isNotEmpty) {
        diagnosisDisplay = patient.diagnoses.join(', ');
      } else if (patient.diagnosis != null && patient.diagnosis.toString().isNotEmpty) {
        diagnosisDisplay = patient.diagnosis.toString();
      }
    } catch (_) {}

    String lastVisitDisplay = 'Chưa có dữ liệu';
    try {
      if (patient.lastVisit != null && patient.lastVisit.toString().isNotEmpty) {
        lastVisitDisplay = patient.lastVisit.toString().split(' ')[0];
      }
    } catch (_) {}

    String allergiesDisplay = 'Không có';
    try {
      if (patient.allergies is List && patient.allergies.isNotEmpty) {
        allergiesDisplay = patient.allergies.join(', ');
      } else if (patient.allergies != null && patient.allergies.toString().isNotEmpty) {
        allergiesDisplay = patient.allergies.toString();
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Hồ sơ bệnh án chi tiết', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildSectionTitle('Thông tin lâm sàng'),
              const SizedBox(height: 10),
              _buildMedicalCard(diagnosisDisplay, allergiesDisplay),
              const SizedBox(height: 20),
              _buildSectionTitle('Thông tin hành chính'),
              const SizedBox(height: 10),
              _buildInfoCard(lastVisitDisplay),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    String name = 'Bệnh nhân';
    String insuranceId = 'Chưa rõ';
    String age = '0';
    String bloodType = 'O';
    
    try { name = patient.name ?? 'Bệnh nhân'; } catch(_) {}
    try { insuranceId = patient.insuranceId ?? patient.insurance_id ?? 'Chưa rõ'; } catch(_) {}
    try { age = (patient.age ?? 0).toString(); } catch(_) {}
    try { bloodType = patient.bloodType ?? 'O'; } catch(_) {}

    String shortName = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text(shortName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                Text('Mã BHYT: $insuranceId', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildBadge('Tuổi: $age', const Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    _buildBadge('Nhóm máu: $bloodType', const Color(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMedicalCard(String diagnosis, String allergies) {
    String history = 'Không có tiền sử bệnh lý';
    String doctor = 'Chưa phân công';
    try { history = patient.medicalHistory ?? 'Không có'; } catch(_) {}
    try { doctor = patient.assignedDoctor ?? 'Chưa phân công'; } catch(_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          _buildDetailRow(Icons.medical_services_rounded, 'Chẩn đoán hiện tại', diagnosis, valueColor: const Color(0xFFDC2626)),
          const Divider(height: 24),
          _buildDetailRow(Icons.history_edu_rounded, 'Tiền sử bệnh lý', history),
          const Divider(height: 24),
          _buildDetailRow(Icons.warning_amber_rounded, 'Dị ứng', allergies),
          const Divider(height: 24),
          _buildDetailRow(Icons.person_pin_rounded, 'Bác sĩ phụ trách', doctor, valueColor: const Color(0xFF16A34A)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String lastVisit) {
    String phone = 'Chưa cập nhật';
    String address = 'Chưa cập nhật';
    try { phone = patient.phone ?? 'Chưa cập nhật'; } catch(_) {}
    try { address = patient.address ?? 'Chưa cập nhật'; } catch(_) {}

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          _buildDetailRow(Icons.phone_android_rounded, 'Số điện thoại', phone),
          const Divider(height: 24),
          _buildDetailRow(Icons.location_on_rounded, 'Địa chỉ cư trú', address),
          const Divider(height: 24),
          _buildDetailRow(Icons.calendar_month_rounded, 'Lần khám gần nhất', lastVisit),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF334155)));
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text(value.isEmpty ? 'Không có' : value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: valueColor ?? const Color(0xFF1E293B))),
            ],
          ),
        )
      ],
    );
  }
}