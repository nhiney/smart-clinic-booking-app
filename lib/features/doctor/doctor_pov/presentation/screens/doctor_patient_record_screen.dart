import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Patient medical record screen (doctor POV).
/// Receives patientId + optional appointment snapshot via extra.
class DoctorPatientRecordScreen extends StatelessWidget {
  final String patientId;
  final Map<String, dynamic>? appointmentExtra;

  const DoctorPatientRecordScreen({
    super.key,
    required this.patientId,
    this.appointmentExtra,
  });

  // Mock data – replace with Firestore in production
  static final _mock = {
    'name': 'Nguyễn Văn An',
    'code': '#BN-0451',
    'visitNo': 3,
    'gender': 'Nam',
    'age': 54,
    'bhyt': 'GD4-0123',
    'bloodType': 'O+',
    'weight': 72,
    'conditions': ['THA độ 2'],
    'allergies': ['Penicillin (nặng)', 'Hải sản'],
    'allergyNote': 'Tránh kê nhóm Beta-lactam.',
    'bp': '142/92',
    'bpStatus': 'Cao',
    'hr': 88,
    'hrStatus': 'Bình thường',
    'bmi': 25.4,
    'bmiStatus': 'Thừa cân',
    'symptoms': 'Đau ngực âm ỉ 3 ngày qua, lan ra cánh tay trái khi gắng sức. Kèm khó thở, chóng mặt vào buổi sáng. Đã tự uống Aspirin 81mg.',
    'appointmentTime': '10:30',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildActionRow(context)),
          SliverToBoxAdapter(child: _buildAllergyWarning()),
          SliverToBoxAdapter(child: _buildVitals()),
          SliverToBoxAdapter(child: _buildSymptoms()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: _buildBottom(context),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    final initials = _mock['name'].toString().split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join().toUpperCase();
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1D4ED8),
      leading: const BackButton(color: Colors.white),
      actions: [
        IconButton(icon: const Icon(Icons.more_horiz_rounded, color: Colors.white), onPressed: () {}),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        title: Text(_mock['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_mock['code']} · LẦN KHÁM ${_mock['visitNo']}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFF38BDF8),
                        child: Text(initials, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_mock['name'].toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                            Text('${_mock['gender']} · ${_mock['age']}t · BHYT ${_mock['bhyt']}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, children: [
                              _TagChip('${_mock['bloodType']}·${_mock['weight']}kg', Colors.white.withValues(alpha: 0.2), Colors.white),
                              ...((_mock['conditions'] as List).map((c) => _TagChip(c.toString(), const Color(0xFFFEF08A).withValues(alpha: 0.3), const Color(0xFFFEF08A)))),
                              _TagChip('Dị ứng', const Color(0xFFFCA5A5).withValues(alpha: 0.3), const Color(0xFFFCA5A5)),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionBtn(icon: Icons.phone_rounded, label: 'Gọi', color: const Color(0xFF1D4ED8)),
          _ActionBtn(icon: Icons.message_rounded, label: 'Nhắn', color: const Color(0xFF059669),
            onTap: () => context.push('/doctor/chat/$patientId')),
          _ActionBtn(icon: Icons.videocam_rounded, label: 'Video', color: const Color(0xFF7C3AED)),
          _ActionBtn(icon: Icons.folder_shared_rounded, label: 'Hồ sơ', color: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildAllergyWarning() {
    final allergies = _mock['allergies'] as List;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.warning_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cảnh báo dị ứng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFFDC2626))),
                const SizedBox(height: 2),
                Text('${allergies.join(', ')}. ${_mock['allergyNote']}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitals() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Chỉ số sinh tồn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            TextButton(onPressed: () {}, child: const Text('Lịch sử', style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 13))),
          ]),
          const Text('Đo lúc 10:28 hôm nay', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _VitalCard(label: 'HUYẾT ÁP', value: _mock['bp'].toString(), unit: 'mmHg', status: _mock['bpStatus'].toString(), isHigh: true)),
            const SizedBox(width: 10),
            Expanded(child: _VitalCard(label: 'NHỊP TIM', value: '${_mock['hr']}', unit: 'bpm', status: _mock['hrStatus'].toString(), isHigh: false)),
            const SizedBox(width: 10),
            Expanded(child: _VitalCard(label: 'BMI', value: '${_mock['bmi']}', unit: 'kg/m²', status: _mock['bmiStatus'].toString(), isHigh: false)),
          ]),
        ],
      ),
    );
  }

  Widget _buildSymptoms() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Triệu chứng hôm nay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const Text('Bệnh nhân tự khai báo', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                children: [
                  const TextSpan(text: 'Đau ngực âm ỉ 3 ngày qua, '),
                  TextSpan(text: 'lan ra cánh tay trái khi gắng sức', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const TextSpan(text: '. Kèm khó thở, chóng mặt vào buổi sáng. Đã tự uống Aspirin 81mg.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.description_outlined, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/doctor/soap/$patientId', extra: appointmentExtra),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 18),
                  label: const Text('Bắt đầu khám', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  const _TagChip(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ]),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label, value, unit, status;
  final bool isHigh;
  const _VitalCard({required this.label, required this.value, required this.unit, required this.status, required this.isHigh});

  @override
  Widget build(BuildContext context) {
    final color = isHigh ? const Color(0xFFEF4444) : const Color(0xFF0F172A);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(unit, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Row(children: [
          if (isHigh) const Icon(Icons.arrow_upward_rounded, size: 12, color: Color(0xFFEF4444)),
          Text(status, style: TextStyle(fontSize: 11, color: isHigh ? const Color(0xFFEF4444) : const Color(0xFF059669), fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}
