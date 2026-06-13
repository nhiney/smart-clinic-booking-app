import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Doctor KYC Upload Screen — submit licence, specialisation and documents
// ═══════════════════════════════════════════════════════════════════════════

class KycUploadScreen extends StatefulWidget {
  const KycUploadScreen({super.key});

  @override
  State<KycUploadScreen> createState() => _KycUploadScreenState();
}

class _KycUploadScreenState extends State<KycUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _licenceCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();

  String _selectedSpecialty = 'Tim mạch';
  bool _isSubmitting = false;
  bool _submitted = false;

  static const _specialties = [
    'Tim mạch', 'Nội khoa', 'Ngoại khoa', 'Thần kinh', 'Da liễu',
    'Nhi khoa', 'Sản phụ khoa', 'Nhãn khoa', 'Tai mũi họng', 'Răng hàm mặt',
    'Ung thư', 'Hô hấp', 'Cơ xương khớp', 'Tâm thần', 'Khác',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _licenceCtrl.dispose();
    _hospitalCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await FirebaseFirestore.instance.collection('doctor_applications').add({
        'doctorUid': uid,
        'fullName': _nameCtrl.text.trim(),
        'licenceNumber': _licenceCtrl.text.trim(),
        'specialty': _selectedSpecialty,
        'hospital': _hospitalCtrl.text.trim(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });
      setState(() => _submitted = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi gửi hồ sơ: $e'),
          backgroundColor: IColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      body: SafeArea(
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  // ─── Success state ────────────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: IColors.successBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  size: 40, color: IColors.success),
            ),
            const SizedBox(height: 20),
            Text('Hồ sơ đã được gửi',
                style: IText.display(size: 22, color: IColors.ink),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              'Ban quản trị sẽ xem xét và phê duyệt tài khoản bác sĩ của bạn trong vòng 1–3 ngày làm việc.',
              style: IText.body(size: 14, color: IColors.ink3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: IColors.primary50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: IColors.primary100),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded,
                    color: IColors.primary500, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bạn sẽ nhận được thông báo qua email khi hồ sơ được phê duyệt.',
                    style: IText.body(size: 13, color: IColors.primary500),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Form ─────────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoBanner(),
                  const SizedBox(height: 24),
                  _sectionLabel('Thông tin bác sĩ'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameCtrl,
                    label: 'Họ và tên đầy đủ',
                    hint: 'Nguyễn Văn A',
                    icon: Icons.person_outline_rounded,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _licenceCtrl,
                    label: 'Số chứng chỉ hành nghề',
                    hint: 'VD: 012345/BYT-HN',
                    icon: Icons.badge_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập số CCHN' : null,
                  ),
                  const SizedBox(height: 14),
                  _buildSpecialtyDropdown(),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _hospitalCtrl,
                    label: 'Bệnh viện / Cơ sở y tế',
                    hint: 'Bệnh viện Bạch Mai',
                    icon: Icons.local_hospital_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nơi công tác' : null,
                  ),
                  const SizedBox(height: 28),
                  _buildNoteCard(),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: IColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: IColors.line),
              boxShadow: IColors.cardShadow,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: IColors.ink),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Xác minh tài khoản',
                style: IText.display(size: 20, color: IColors.ink)),
            Text('KYC · Bác sĩ',
                style: IText.label(size: 11, color: IColors.primary500)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [IColors.navy, IColors.primary500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.verified_user_rounded,
              color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Xác minh chứng chỉ hành nghề',
                style: IText.body(
                    size: 14, weight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 4),
            Text(
                'Điền đầy đủ thông tin để được phê duyệt tài khoản bác sĩ.',
                style: IText.body(
                    size: 12, color: Colors.white.withValues(alpha: 0.8))),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: IText.label(size: 11, color: IColors.ink3));

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: IText.body(size: 13, weight: FontWeight.w600, color: IColors.ink2)),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        validator: validator,
        style: IText.body(size: 14, color: IColors.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: IText.body(size: 14, color: IColors.ink200),
          prefixIcon: Icon(icon, size: 18, color: IColors.ink3),
          filled: true,
          fillColor: IColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: IColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: IColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: IColors.primary500, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: IColors.danger),
          ),
        ),
      ),
    ]);
  }

  Widget _buildSpecialtyDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Chuyên khoa',
          style: IText.body(size: 13, weight: FontWeight.w600, color: IColors.ink2)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: IColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: IColors.line),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSpecialty,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: IColors.ink3),
            style: IText.body(size: 14, color: IColors.ink),
            items: _specialties
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _selectedSpecialty = v);
            },
          ),
        ),
      ),
    ]);
  }

  Widget _buildNoteCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: IColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IColors.warning.withValues(alpha: 0.35)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded,
            size: 18, color: IColors.warning),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Thông tin sẽ được xác minh với Bộ Y tế. Vui lòng điền chính xác số chứng chỉ hành nghề.',
            style: IText.body(size: 12.5, color: IColors.ink2),
          ),
        ),
      ]),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isSubmitting
                ? [IColors.ink200, IColors.ink200]
                : [IColors.primary500, IColors.primary700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isSubmitting
              ? []
              : [
                  BoxShadow(
                      color: IColors.primary500.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
        ),
        child: Center(
          child: _isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Text('Gửi hồ sơ xét duyệt',
                  style: IText.body(
                      size: 15, weight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }
}
