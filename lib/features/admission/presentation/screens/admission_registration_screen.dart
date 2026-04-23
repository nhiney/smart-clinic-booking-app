import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import '../riverpod/admission_provider.dart';

class AdmissionRegistrationScreen extends ConsumerStatefulWidget {
  final String patientId;
  const AdmissionRegistrationScreen({super.key, required this.patientId});

  @override
  ConsumerState<AdmissionRegistrationScreen> createState() => _AdmissionRegistrationScreenState();
}

class _AdmissionRegistrationScreenState extends ConsumerState<AdmissionRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _insuranceController = TextEditingController();

  String _priority = 'normal';
  DateTime? _admissionDate;
  bool _isSubmitting = false;

  static const _priorityOptions = [
    ('normal', 'Bình thường', Colors.green),
    ('urgent', 'Khẩn cấp', Colors.orange),
    ('emergency', 'Cấp cứu', Colors.red),
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _contactPhoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _admissionDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(admissionListProvider(widget.patientId).notifier);
    final id = await notifier.requestAdmission(
      patientId: widget.patientId,
      reason: _reasonController.text.trim(),
      contactPhone: _contactPhoneController.text.trim().isEmpty ? null : _contactPhoneController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
      emergencyPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
      insuranceNumber: _insuranceController.text.trim().isEmpty ? null : _insuranceController.text.trim(),
      priority: _priority,
      admissionDate: _admissionDate,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (id != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yêu cầu nhập viện đã được gửi! Đội ngũ của chúng tôi sẽ liên hệ với bạn sớm.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi yêu cầu thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const BrandedAppBar(
        title: 'Đăng ký nhập viện',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoBanner(),
              const SizedBox(height: 20),
              _SectionCard(
                title: 'Chi tiết nhập viện',
                children: [
                  _buildPrioritySelector(),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: _inputDecoration(
                      label: 'Lý do nhập viện *',
                      hint: 'Mô tả triệu chứng, chẩn đoán hoặc thủ thuật đã lên lịch...',
                      icon: Icons.medical_services_outlined,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Thông tin liên hệ',
                children: [
                  TextFormField(
                    controller: _contactPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: 'Số điện thoại liên hệ',
                      hint: '0901234567',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: _inputDecoration(
                      label: 'Tên người liên hệ khẩn cấp',
                      hint: 'Tên người thân',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration(
                      label: 'SĐT người liên hệ khẩn cấp',
                      hint: '0901234567',
                      icon: Icons.phone_in_talk_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Bảo hiểm',
                children: [
                  TextFormField(
                    controller: _insuranceController,
                    decoration: _inputDecoration(
                      label: 'Số thẻ Bảo hiểm / BHYT',
                      hint: 'DN4012345678901',
                      icon: Icons.card_membership_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Gửi yêu cầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mức độ ưu tiên', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: _priorityOptions.map((opt) {
            final isSelected = _priority == opt.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priority = opt.$1),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? opt.$3.withAlpha(30) : Colors.white,
                    border: Border.all(
                      color: isSelected ? opt.$3 : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        opt.$1 == 'normal'
                            ? Icons.check_circle_outline
                            : opt.$1 == 'urgent'
                                ? Icons.warning_amber_outlined
                                : Icons.emergency_outlined,
                        color: isSelected ? opt.$3 : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        opt.$2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? opt.$3 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.grey[600], size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                  _admissionDate != null
                      ? 'Ngày mong muốn: ${DateFormat('dd/MM/yyyy').format(_admissionDate!)}'
                      : 'Ngày nhập viện mong muốn (tùy chọn)',
                style: TextStyle(
                  color: _admissionDate != null ? Colors.black87 : Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ),
            if (_admissionDate != null)
              GestureDetector(
                onTap: () => setState(() => _admissionDate = null),
                child: Icon(Icons.close, size: 18, color: Colors.grey[500]),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Yêu cầu của bạn sẽ được đội ngũ tiếp nhận xem xét trong vòng 2-4 giờ. '
              'Đối với các trường hợp khẩn cấp, vui lòng gọi hotline hoặc đến trực tiếp phòng cấp cứu.',
              style: TextStyle(fontSize: 13, color: Colors.blue[800]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}

