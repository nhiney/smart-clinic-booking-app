import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/medical_record_controller.dart';
import '../../domain/entities/medical_record_entity.dart';

class AddMedicalRecordScreen extends ConsumerStatefulWidget {
  const AddMedicalRecordScreen({super.key});

  @override
  ConsumerState<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends ConsumerState<AddMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _symptomController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  final List<String> _symptoms = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _doctorController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('vi'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _addSymptom() {
    final text = _symptomController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _symptoms.add(text);
      _symptomController.clear();
    });
  }

  void _removeSymptom(int index) {
    setState(() => _symptoms.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final auth = legacy_provider.Provider.of<AuthController>(context, listen: false);
      final record = MedicalRecordEntity(
        id: const Uuid().v4(),
        userId: auth.currentUser?.id ?? '',
        doctor: _doctorController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        prescription: _prescriptionController.text.trim(),
        createdAt: _selectedDate,
        symptoms: _symptoms.isNotEmpty ? List<String>.from(_symptoms) : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      await ref.read(medicalRecordControllerProvider.notifier).addRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm hồ sơ y tế thành công'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(title: 'Thêm hồ sơ y tế', showBackButton: true),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(context.spacing.l),
          children: [
            _buildSectionLabel('THÔNG TIN KHÁM'),
            SizedBox(height: context.spacing.s),
            _buildDateField(),
            SizedBox(height: context.spacing.m),
            _buildTextField(
              controller: _doctorController,
              label: 'Tên bác sĩ',
              hint: 'VD: Nguyễn Văn A',
              icon: Icons.person_rounded,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên bác sĩ' : null,
            ),
            SizedBox(height: context.spacing.xl),
            _buildSectionLabel('CHẨN ĐOÁN & ĐIỀU TRỊ'),
            SizedBox(height: context.spacing.s),
            _buildTextField(
              controller: _diagnosisController,
              label: 'Chẩn đoán',
              hint: 'VD: Viêm họng cấp',
              icon: Icons.medical_information_rounded,
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập chẩn đoán' : null,
            ),
            SizedBox(height: context.spacing.m),
            _buildTextField(
              controller: _prescriptionController,
              label: 'Đơn thuốc / Phương pháp điều trị',
              hint: 'VD: Amoxicillin 500mg x 3 lần/ngày...',
              icon: Icons.medication_rounded,
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập đơn thuốc' : null,
            ),
            SizedBox(height: context.spacing.xl),
            _buildSectionLabel('TRIỆU CHỨNG'),
            SizedBox(height: context.spacing.s),
            _buildSymptomInput(),
            if (_symptoms.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _symptoms.asMap().entries.map((e) => Chip(
                      label: Text(e.value, style: TextStyle(fontSize: 12, color: context.colors.primary)),
                      backgroundColor: context.colors.primary.withValues(alpha: 0.08),
                      deleteIcon: Icon(Icons.close, size: 14, color: context.colors.primary),
                      onDeleted: () => _removeSymptom(e.key),
                      side: BorderSide(color: context.colors.primary.withValues(alpha: 0.2)),
                    )).toList(),
              ),
            ],
            SizedBox(height: context.spacing.xl),
            _buildSectionLabel('GHI CHÚ'),
            SizedBox(height: context.spacing.s),
            _buildTextField(
              controller: _notesController,
              label: 'Ghi chú của bác sĩ (tùy chọn)',
              hint: 'Nhập ghi chú thêm...',
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
            SizedBox(height: context.spacing.xxl),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Đang lưu...' : 'Lưu hồ sơ', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            SizedBox(height: context.spacing.l),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: context.textStyles.caption.copyWith(
        color: context.colors.textHint,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 20, color: context.colors.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ngày khám', style: context.textStyles.caption.copyWith(color: context.colors.textHint, fontSize: 11)),
                Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: context.textStyles.bodyBold),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded, color: context.colors.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Padding(
          padding: EdgeInsets.only(top: maxLines > 1 ? 12 : 0),
          child: Icon(icon, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: context.colors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildSymptomInput() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _symptomController,
            onFieldSubmitted: (_) => _addSymptom(),
            decoration: InputDecoration(
              hintText: 'VD: Đau họng, sốt, ho...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: context.colors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _addSymptom,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}
