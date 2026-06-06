import 'package:flutter/material.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFFF1F5F9);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF10B981);
}

// ── Model ────────────────────────────────────────────────────────────────────
class MedicalVisit {
  final String id;
  final int day;
  final int month;
  final int year;
  final String title;
  final String icdCode;
  final String icdLabel;
  final String doctor;
  final String doctorInitials;
  final String specialty;
  final Color specialtyColor;
  final List<String> prescriptions; // tên thuốc
  final List<String> tests; // xét nghiệm
  final String recommendation;

  const MedicalVisit({
    required this.id,
    required this.day,
    required this.month,
    required this.year,
    required this.title,
    required this.icdCode,
    required this.icdLabel,
    required this.doctor,
    required this.doctorInitials,
    required this.specialty,
    required this.specialtyColor,
    this.prescriptions = const [],
    this.tests = const [],
    this.recommendation = '',
  });

  String get monthLabel => 'THÁNG ${month.toString().padLeft(2, '0')}, $year';
  String get dayLabel => day.toString().padLeft(2, '0');
  String get monthShort => 'TH${month.toString().padLeft(2, '0')}';
}

const _cardio = Color(0xFFE53E3E);
const _internal = Color(0xFF3182CE);
const _derma = Color(0xFFED64A6);

const _demoVisits = <MedicalVisit>[
  MedicalVisit(
    id: 'v1', day: 23, month: 5, year: 2026,
    title: 'Đau ngực, tăng huyết áp',
    icdCode: 'I20.0', icdLabel: 'ĐTN không ổn định',
    doctor: 'BS. Trần Minh Quân', doctorInitials: 'MQ',
    specialty: 'Tim mạch', specialtyColor: _cardio,
    prescriptions: ['Amlodipine 5mg', 'Aspirin 81mg', 'Atorvastatin 20mg'],
    tests: ['Điện tâm đồ ECG', 'Siêu âm tim 2D', 'Xét nghiệm máu', 'Men tim Troponin'],
    recommendation: 'Tái khám sau 2 tuần. Theo dõi huyết áp tại nhà mỗi sáng.',
  ),
  MedicalVisit(
    id: 'v2', day: 12, month: 4, year: 2026,
    title: 'Tái khám tăng huyết áp',
    icdCode: 'I10', icdLabel: 'THA độ 2',
    doctor: 'BS. Phạm Văn Đức', doctorInitials: 'VĐ',
    specialty: 'Tim mạch', specialtyColor: _cardio,
    prescriptions: ['Amlodipine 5mg', 'Losartan 50mg'],
    tests: ['Đo huyết áp 24h Holter'],
    recommendation: 'Duy trì thuốc, giảm muối trong khẩu phần ăn.',
  ),
  MedicalVisit(
    id: 'v3', day: 3, month: 2, year: 2026,
    title: 'Khám sức khỏe định kỳ',
    icdCode: 'Z00.0', icdLabel: 'Khám định kỳ',
    doctor: 'BS. Nguyễn Thị Lan', doctorInitials: 'TL',
    specialty: 'Nội tổng quát', specialtyColor: _internal,
    prescriptions: ['Vitamin tổng hợp'],
    tests: ['Tổng phân tích máu', 'Đường huyết', 'Chức năng gan thận', 'X-quang ngực'],
    recommendation: 'Kết quả tốt. Khám lại sau 6 tháng.',
  ),
  MedicalVisit(
    id: 'v4', day: 18, month: 12, year: 2025,
    title: 'Viêm da tiếp xúc',
    icdCode: 'L23', icdLabel: 'Viêm da dị ứng',
    doctor: 'BS. Đỗ Thị Mai', doctorInitials: 'TM',
    specialty: 'Da liễu', specialtyColor: _derma,
    prescriptions: ['Kem Hydrocortisone 1%', 'Loratadine 10mg'],
    tests: ['Test áp da'],
    recommendation: 'Tránh tiếp xúc chất gây dị ứng. Tái khám nếu không đỡ.',
  ),
  MedicalVisit(
    id: 'v5', day: 5, month: 11, year: 2025,
    title: 'Rối loạn lipid máu',
    icdCode: 'E78.5', icdLabel: 'Tăng mỡ máu',
    doctor: 'BS. Trần Minh Quân', doctorInitials: 'MQ',
    specialty: 'Tim mạch', specialtyColor: _cardio,
    prescriptions: ['Atorvastatin 20mg'],
    tests: ['Bộ mỡ máu (Lipid panel)'],
    recommendation: 'Tập thể dục 30 phút/ngày, hạn chế đồ chiên rán.',
  ),
  MedicalVisit(
    id: 'v6', day: 20, month: 9, year: 2025,
    title: 'Viêm họng cấp',
    icdCode: 'J02.9', icdLabel: 'Viêm họng',
    doctor: 'BS. Nguyễn Thị Lan', doctorInitials: 'TL',
    specialty: 'Nội tổng quát', specialtyColor: _internal,
    prescriptions: ['Amoxicillin 500mg', 'Paracetamol 500mg'],
    tests: ['Test nhanh liên cầu khuẩn'],
    recommendation: 'Uống đủ nước, nghỉ ngơi. Hết thuốc tái khám nếu còn sốt.',
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────
class MedicalHistoryTimelineScreen extends StatefulWidget {
  const MedicalHistoryTimelineScreen({super.key});

  @override
  State<MedicalHistoryTimelineScreen> createState() =>
      _MedicalHistoryTimelineScreenState();
}

class _MedicalHistoryTimelineScreenState
    extends State<MedicalHistoryTimelineScreen> {
  String _specialty = 'Tất cả';
  String _query = '';
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  final Set<String> _expanded = {'v1'}; // card đầu mở sẵn

  List<String> get _specialties {
    final s = _demoVisits.map((v) => v.specialty).toSet().toList()..sort();
    return ['Tất cả', ...s];
  }

  List<MedicalVisit> get _filtered {
    return _demoVisits.where((v) {
      final okSpec = _specialty == 'Tất cả' || v.specialty == _specialty;
      final q = _query.trim().toLowerCase();
      final okQuery = q.isEmpty ||
          v.title.toLowerCase().contains(q) ||
          v.doctor.toLowerCase().contains(q) ||
          v.icdCode.toLowerCase().contains(q);
      return okSpec && okQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final doctorsCount = _demoVisits.map((v) => v.doctor).toSet().length;

    // gom nhóm theo tháng
    final groups = <String, List<MedicalVisit>>{};
    for (final v in filtered) {
      groups.putIfAbsent(v.monthLabel, () => []).add(v);
    }

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Tìm theo bệnh, bác sĩ, mã ICD...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              )
            : const Text('Hồ sơ bệnh án',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: !_searching,
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _query = '';
                _searchCtrl.clear();
              }
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          _summaryHeader(filtered.length, doctorsCount),
          _filterChips(),
          Expanded(
            child: filtered.isEmpty
                ? _empty()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 10),
                          child: Text(entry.key,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textSecondary,
                                  letterSpacing: 0.5)),
                        ),
                        ...entry.value.map((v) => _VisitCard(
                              visit: v,
                              expanded: _expanded.contains(v.id),
                              onToggle: () => setState(() {
                                if (!_expanded.add(v.id)) _expanded.remove(v.id);
                              }),
                              onDetail: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => VisitDetailScreen(visit: v)),
                              ),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryHeader(int count, int doctors) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count lượt khám',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: _C.textPrimary)),
          const SizedBox(height: 2),
          Text.rich(TextSpan(
            style: const TextStyle(color: _C.textSecondary, fontSize: 13),
            children: [
              const TextSpan(text: 'Từ 03/2024 đến nay · '),
              TextSpan(
                  text: '$doctors bác sĩ',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _specialties.map((s) {
            final sel = s == _specialty;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _specialty = s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? _C.primary : _C.bg,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: sel ? _C.primary : _C.border, width: 1.5),
                  ),
                  child: Text(s,
                      style: TextStyle(
                          color: sel ? Colors.white : _C.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_off_outlined,
              size: 56, color: _C.textSecondary),
          SizedBox(height: 12),
          Text('Không tìm thấy lượt khám phù hợp',
              style: TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

// ── Visit card ───────────────────────────────────────────────────────────────
class _VisitCard extends StatelessWidget {
  final MedicalVisit visit;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDetail;

  const _VisitCard({
    required this.visit,
    required this.expanded,
    required this.onToggle,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // date badge
          Container(
            width: 46,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _C.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(visit.dayLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900)),
                Text(visit.monthShort,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // content card
          Expanded(
            child: GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _C.border),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(visit.title,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _C.textPrimary)),
                        ),
                        AnimatedRotation(
                          turns: expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: _C.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _C.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('${visit.icdCode} · ${visit.icdLabel}',
                          style: const TextStyle(
                              color: _C.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor:
                              visit.specialtyColor.withValues(alpha: 0.15),
                          child: Text(visit.doctorInitials,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: visit.specialtyColor)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${visit.doctor} · ${visit.specialty}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: _C.textSecondary,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: expanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: _details(context),
                      secondChild: const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: _C.border),
        ),
        _checkLine('Đơn thuốc ${visit.prescriptions.length} loại'),
        const SizedBox(height: 8),
        _checkLine('${visit.tests.length} xét nghiệm'),
        const SizedBox(height: 8),
        _checkLine('Khuyến nghị tái khám 2 tuần'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onDetail,
          child: const Row(
            children: [
              Text('Xem chi tiết',
                  style: TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, color: _C.primary, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _checkLine(String text) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, color: _C.green, size: 16),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(fontSize: 13, color: _C.textPrimary)),
      ],
    );
  }
}

// ── Visit detail ─────────────────────────────────────────────────────────────
class VisitDetailScreen extends StatelessWidget {
  final MedicalVisit visit;
  const VisitDetailScreen({super.key, required this.visit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        title: const Text('Chi tiết lượt khám',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _C.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '${visit.dayLabel}/${visit.month.toString().padLeft(2, '0')}/${visit.year}',
                    style: const TextStyle(
                        color: _C.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(visit.title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _C.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _C.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${visit.icdCode} · ${visit.icdLabel}',
                      style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          visit.specialtyColor.withValues(alpha: 0.15),
                      child: Text(visit.doctorInitials,
                          style: TextStyle(
                              color: visit.specialtyColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(visit.doctor,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary)),
                        Text(visit.specialty,
                            style: const TextStyle(
                                color: _C.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(Icons.medication_rounded, 'Đơn thuốc',
              visit.prescriptions, const Color(0xFFE91E63)),
          const SizedBox(height: 16),
          _section(Icons.science_rounded, 'Xét nghiệm', visit.tests,
              const Color(0xFF0891B2)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: _C.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Khuyến nghị của bác sĩ',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _C.textPrimary,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(visit.recommendation,
                          style: const TextStyle(
                              color: _C.textSecondary,
                              fontSize: 13,
                              height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tải bản PDF hồ sơ...')),
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Tải hồ sơ (PDF)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(IconData icon, String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: _C.textPrimary)),
              const Spacer(),
              Text('${items.length}',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e,
                          style: const TextStyle(
                              fontSize: 14, color: _C.textPrimary)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
