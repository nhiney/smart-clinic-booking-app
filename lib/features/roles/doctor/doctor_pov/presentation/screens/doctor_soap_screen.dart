import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/features/roles/doctor/patient_pov/presentation/riverpod/examination_provider.dart';

/// SOAP clinical examination screen (doctor POV).
class DoctorSoapScreen extends ConsumerStatefulWidget {
  final String patientId;
  final Map<String, dynamic>? appointmentExtra;
  const DoctorSoapScreen({super.key, required this.patientId, this.appointmentExtra});

  @override
  ConsumerState<DoctorSoapScreen> createState() => _State();
}

class _State extends ConsumerState<DoctorSoapScreen> with SingleTickerProviderStateMixin {
  int _step = 2; // 0=S,1=O,2=A,3=P — show A as active like design
  final _stopwatch = Stopwatch()..start();
  bool _autoSave = true;

  // ICD codes state
  final _icdCodes = <_IcdEntry>[
    _IcdEntry('I20.0', 'ĐTN không ổn định'),
    _IcdEntry('I10', 'THA độ 2'),
  ];
  final _aiSuggestions = const [
    ('E11.9', 'ĐTĐ type 2 không biến chứng', 78),
    ('R07.4', 'Đau ngực không đặc hiệu', 65),
  ];

  // S/O controllers
  final _sCtrl = TextEditingController(text: 'Đau ngực 3 ngày, lan tay trái khi gắng sức...');
  final _oCtrl = TextEditingController(text: 'HA 142/92 · NT 88 · ECG bất thường');

  @override
  void dispose() {
    _sCtrl.dispose();
    _oCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final aptId = widget.appointmentExtra?['id']?.toString();
    if (aptId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Không tìm thấy mã lịch hẹn')),
      );
      return;
    }
    
    final patientName = widget.appointmentExtra?['patientName']?.toString() ?? 'Nguyễn Văn An';
    
    // ICD code
    final icdString = _icdCodes.map((e) => '${e.code}: ${e.label}').join(', ');
    final finalDiagnosis = '${_oCtrl.text}\nICD: $icdString';
    
    await ref.read(examinationProvider.notifier).save(
      appointmentId: aptId,
      patientId: widget.patientId,
      patientName: patientName,
      diagnosis: finalDiagnosis,
      prescription: '',
      notes: _sCtrl.text,
    );

    if (!mounted) return;
    final state = ref.read(examinationProvider);
    if (state.isSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu kết quả khám')),
      );
      context.go('/doctor/dashboard');
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${state.error}')),
      );
    }
  }

  String get _elapsed {
    final m = _stopwatch.elapsed.inMinutes;
    final s = _stopwatch.elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text('Khám lâm sàng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0F172A))),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.circle, size: 8, color: Color(0xFFF59E0B)),
              SizedBox(width: 6),
              Text('ĐANG GHI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B), letterSpacing: 0.5)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPatientBar(),
          _buildTimerBar(),
          _buildStepTabs(),
          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSoapSection('S', 'Triệu chứng chủ quan', 'Đau ngực 3 ngày, lan tay trái khi gắng sức...', 0, _sCtrl),
              _buildSoapSection('O', 'Khám thực thể', 'HA 142/92 · NT 88 · ECG bất thường', 1, _oCtrl),
              if (_step == 2) _buildAssessmentSection(),
              if (_step == 3) _buildPlanSection(context),
            ],
          )),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildPatientBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFDBEAFE),
          child: Text('AV', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1D4ED8)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Nguyễn Văn An · #BN-0451', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
          const Text('Nam · 54t · 10:30 · Lần khám 3', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
          child: const Text('THA độ 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
        ),
      ]),
    );
  }

  Widget _buildTimerBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (_, __) => Row(children: [
              const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text('Thời gian khám: $_elapsed', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ]),
          ),
          Row(children: [
            Icon(Icons.circle, size: 8, color: _autoSave ? const Color(0xFF22C55E) : const Color(0xFF94A3B8)),
            const SizedBox(width: 4),
            const Text('Tự động lưu', style: TextStyle(fontSize: 12, color: Color(0xFF22C55E))),
          ]),
        ],
      ),
    );
  }

  Widget _buildStepTabs() {
    const steps = [
      ('S', 'Chủ\nquan'),
      ('O', 'Khách\nquan'),
      ('A', 'Đánh\ngiá'),
      ('P', 'Kế\nhoạch'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isDone = i < _step;
          final isActive = i == _step;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _step = i),
              child: Row(children: [
                if (i > 0) Expanded(child: Container(height: 1, color: isDone ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0))),
                Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? const Color(0xFF22C55E) : isActive ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    ),
                    child: Center(child: isDone
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : Text(steps[i].$1, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                            color: isActive ? Colors.white : const Color(0xFF94A3B8)))),
                  ),
                  const SizedBox(height: 4),
                  Text(steps[i].$2, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, height: 1.2, fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                          color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8))),
                ]),
              ]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSoapSection(String key, String title, String preview, int idx, TextEditingController ctrl) {
    final isDone = idx < _step;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(width: 32, height: 32, decoration: BoxDecoration(
          color: isDone ? const Color(0xFF22C55E) : const Color(0xFFF1F5F9), shape: BoxShape.circle),
          child: Center(child: isDone
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : Text(key, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF94A3B8))))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF0F172A))),
        subtitle: Text(preview, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: TextField(
              controller: ctrl,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Nhập $title...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                filled: true, fillColor: const Color(0xFFF8FAFC),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1D4ED8).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Row(children: [
            CircleAvatar(radius: 14, backgroundColor: Color(0xFF0F172A),
              child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
            SizedBox(width: 10),
            Text('Chẩn đoán & Đánh giá', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
          ]),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome_rounded, size: 14),
            label: const Text('AI gợi ý', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1D4ED8),
              side: const BorderSide(color: Color(0xFF1D4ED8)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const Text('MÃ ICD-10', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            ..._icdCodes.map((e) => _IcdChip(entry: e, onRemove: () => setState(() => _icdCodes.remove(e)))),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_rounded, size: 14, color: Color(0xFF94A3B8)),
                  SizedBox(width: 4),
                  Text('Thêm', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF1D4ED8)),
              SizedBox(width: 6),
              Text('AI ĐỀ XUẤT THÊM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8), letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 10),
            ..._aiSuggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF1D4ED8), borderRadius: BorderRadius.circular(6)),
                  child: Text(s.$1, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(s.$2, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)))),
                Text('${s.$3}%', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _icdCodes.add(_IcdEntry(s.$1, s.$2))),
                  child: Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(color: const Color(0xFF1D4ED8), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ]),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _buildPlanSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          CircleAvatar(radius: 14, backgroundColor: Color(0xFF7C3AED),
            child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
          SizedBox(width: 10),
          Text('Kế hoạch điều trị', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => context.push('/doctor/prescription/${widget.patientId}'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white,
              elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            icon: const Icon(Icons.receipt_long_rounded, size: 18),
            label: const Text('Kê đơn thuốc', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SafeArea(
        top: false,
        child: Row(children: [
          const SizedBox(width: 8),
          const Icon(Icons.mic_rounded, color: Color(0xFF64748B)),
          const SizedBox(width: 16),
          const Icon(Icons.crop_square_rounded, color: Color(0xFF64748B)),
          const Spacer(),
          SizedBox(
            height: 48,
            child: Consumer(
              builder: (context, ref, _) {
                final isSaving = ref.watch(examinationProvider).isSaving;
                return ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : (_step < 3
                          ? () => setState(() => _step++)
                          : _save),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8), foregroundColor: Colors.white, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (isSaving)
                      const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Text(_step < 3 ? 'Tiếp tục bước ${['O', 'A', 'P', ''][_step]} →' : 'Hoàn tất ✓',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                  ]),
                );
              }
            ),
          ),
        ]),
      ),
    );
  }
}

class _IcdEntry {
  final String code, label;
  _IcdEntry(this.code, this.label);
}

class _IcdChip extends StatelessWidget {
  final _IcdEntry entry;
  final VoidCallback onRemove;
  const _IcdChip({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1D4ED8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${entry.code} · ${entry.label}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        GestureDetector(onTap: onRemove,
          child: const Icon(Icons.close_rounded, size: 14, color: Colors.white70)),
      ]),
    );
  }
}
