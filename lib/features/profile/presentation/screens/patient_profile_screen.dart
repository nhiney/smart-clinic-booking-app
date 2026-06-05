import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/patient_profile_controller.dart';
import '../../domain/entities/patient_profile.dart';
import '../../../../core/widgets/branded_app_bar.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _cPrimary     = Color(0xFF1976D2);
const _cPrimaryDark = Color(0xFF1565C0);
const _cPrimaryMid  = Color(0xFF1E88E5);
const _cBg          = Color(0xFFF4F7FB);
const _cText        = Color(0xFF0F172A);
const _cTextSub     = Color(0xFF475569);
const _cTextHint    = Color(0xFF94A3B8);
const _cBorder      = Color(0xFFE2E8F0);

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key, this.embeddedInTab = false});
  final bool embeddedInTab;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _allergiesController;
  late TextEditingController _historyController;
  late TextEditingController _emailController;

  DateTime? _selectedDob;
  String? _selectedGender;
  String? _selectedBloodType;
  bool _receiveEmail = false;
  bool _cloudStorageEnabled = false;
  String? _avatarPath;

  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _nameController     = TextEditingController();
    _addressController  = TextEditingController();
    _allergiesController = TextEditingController();
    _historyController  = TextEditingController();
    _emailController    = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _historyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadData() {
    final auth = context.read<AuthController>();
    context.read<PatientProfileController>()
        .loadProfile(auth.currentUser?.id ?? '', auth.currentUser?.phone ?? '')
        .then((_) {
      final p = context.read<PatientProfileController>().profile;
      if (p != null && mounted) {
        setState(() {
          _nameController.text      = p.fullName;
          _addressController.text   = p.address ?? '';
          _selectedDob              = p.dob;
          _selectedGender           = p.gender;
          _selectedBloodType        = p.bloodType;
          _allergiesController.text = p.allergies ?? '';
          _historyController.text   = p.medicalHistory ?? '';
          _emailController.text     = p.email ?? '';
          _receiveEmail             = p.receiveEmail;
          _cloudStorageEnabled      = p.cloudStorageEnabled;
        });
      }
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) setState(() => _avatarPath = picked.path);
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final profile = PatientProfile(
      fullName:             _nameController.text.trim(),
      phone:                auth.currentUser?.phone ?? '',
      dob:                  _selectedDob,
      gender:               _selectedGender,
      address:              _addressController.text.trim(),
      bloodType:            _selectedBloodType,
      allergies:            _allergiesController.text.trim(),
      medicalHistory:       _historyController.text.trim(),
      email:                _emailController.text.trim(),
      receiveEmail:         _receiveEmail,
      cloudStorageEnabled:  _cloudStorageEnabled,
    );
    final success = await context.read<PatientProfileController>().updateProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Cập nhật thành công!'
          : 'Lỗi: ${context.read<PatientProfileController>().errorMessage}'),
      backgroundColor: success ? const Color(0xFF16A34A) : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
    if (success) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.read<PatientProfileController>().resetStatus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cBg,
      appBar: widget.embeddedInTab
          ? null
          : const BrandedAppBar(title: 'Hồ sơ cá nhân', showBackButton: true),
      body: Consumer<PatientProfileController>(
        builder: (context, ctrl, _) {
          if (ctrl.status == PatientProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: _cPrimary));
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Dịch vụ y tế'),
                  const SizedBox(height: 10),
                  _buildQuickAccess(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Thông tin cá nhân'),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _field(label: 'Họ và tên', ctrl: _nameController,
                        icon: Icons.badge_outlined,
                        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null),
                    _readOnly(label: 'Số điện thoại',
                        value: context.read<AuthController>().currentUser?.phone ?? '',
                        icon: Icons.phone_iphone_rounded),
                    _datePicker(),
                    _genderPicker(),
                    _field(label: 'Địa chỉ thường trú', ctrl: _addressController,
                        icon: Icons.location_on_outlined, isLast: true),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionLabel('Thông tin y tế'),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _bloodTypePicker(),
                    _field(label: 'Tình trạng dị ứng', ctrl: _allergiesController,
                        icon: Icons.warning_amber_rounded,
                        hint: 'VD: Hải sản, Penicillin...',
                        iconColor: const Color(0xFFF59E0B)),
                    _field(label: 'Tiền sử bệnh lý', ctrl: _historyController,
                        icon: Icons.history_edu_rounded, maxLines: 3, isLast: true),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionLabel('Cài đặt & Thông báo'),
                  const SizedBox(height: 10),
                  _buildInfoCard([
                    _field(label: 'Email nhận hồ sơ', ctrl: _emailController,
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (_receiveEmail) {
                            if (v == null || v.isEmpty) return 'Cần nhập email';
                            if (!v.contains('@')) return 'Email không hợp lệ';
                          }
                          return null;
                        }),
                    _switchRow(
                      label: 'Nhận kết quả khám qua Email',
                      subtitle: 'Tự động gửi hồ sơ PDF khi có kết quả',
                      value: _receiveEmail,
                      onChanged: (v) => setState(() => _receiveEmail = v),
                    ),
                    _switchRow(
                      label: 'Lưu trữ hồ sơ online',
                      subtitle: 'Truy cập hồ sơ bệnh án mọi lúc',
                      value: _cloudStorageEnabled,
                      onChanged: (v) => setState(() => _cloudStorageEnabled = v),
                      isLast: true,
                    ),
                  ]),
                  const SizedBox(height: 28),
                  _buildSaveButton(ctrl),
                  const SizedBox(height: 12),
                  _buildLogoutButton(),
                  const SizedBox(height: 44),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Hero banner ──────────────────────────────────────────────────────────────
  Widget _buildHero() {
    final phone = context.read<AuthController>().currentUser?.phone ?? '';
    final name  = _nameController.text.isNotEmpty ? _nameController.text : 'Người dùng';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_cPrimaryDark, _cPrimary, _cPrimaryMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _cPrimaryDark.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _avatarPath != null
                          ? Image.file(File(_avatarPath!), fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultAvatar())
                          : _defaultAvatar(),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 15, color: _cPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (phone.isNotEmpty)
                    _HeroPill(icon: Icons.phone_iphone_rounded, label: phone),
                  if (_selectedBloodType != null)
                    _HeroPill(
                      icon: Icons.bloodtype_rounded,
                      label: _selectedBloodType!,
                      accent: const Color(0xFFFFABAB),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar() => Container(
        color: const Color(0xFFBBD4F3),
        child: const Icon(Icons.person_rounded, size: 54, color: _cPrimary),
      );

  // ── Quick access grid ────────────────────────────────────────────────────────
  static const _quickItems = [
    _QuickItem(Icons.history_rounded,          'Lịch sử\nkhám',    '/appointments',         Color(0xFF6366F1)),
    _QuickItem(Icons.folder_copy_rounded,      'Hồ sơ\nbệnh án',   '/medical-records',      Color(0xFF1976D2)),
    _QuickItem(Icons.science_rounded,          'Kết quả\nCLS',     '/surveys',              Color(0xFF0EA5E9)),
    _QuickItem(Icons.receipt_long_rounded,     'Đơn\nthuốc',       '/prescriptions',        Color(0xFFF43F5E)),
    _QuickItem(Icons.medication_liquid_rounded,'Theo dõi\nthuốc',  '/medication',           Color(0xFF10B981)),
    _QuickItem(Icons.local_hospital_rounded,   'Nhập\nviện',       '/admission/history/me', Color(0xFFF59E0B)),
  ];

  Widget _buildQuickAccess() {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid ?? 'me';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.96,
        children: _quickItems.map((item) => _QuickTile(item: item, uid: uid)).toList(),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _cTextHint,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // ── Info card ────────────────────────────────────────────────────────────────
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
        child: Column(children: children),
      ),
    );
  }

  // ── Input field ───────────────────────────────────────────────────────────────
  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Color iconColor = _cTextHint,
    bool isLast = false,
  }) {
    return _FieldRow(
      isLast: isLast,
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: _cText),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 19, color: iconColor),
          labelStyle: const TextStyle(color: _cTextHint, fontSize: 13.5),
          floatingLabelStyle: const TextStyle(color: _cPrimary, fontWeight: FontWeight.w600, fontSize: 12.5),
          filled: true,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: _cPrimary.withValues(alpha: 0.4), width: 1.5),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
        ),
      ),
    );
  }

  Widget _readOnly({required String label, required String value, required IconData icon}) {
    return _FieldRow(
      child: Row(
        children: [
          Icon(icon, size: 19, color: _cTextHint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: _cTextHint, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: _cTextSub)),
              ],
            ),
          ),
          const Icon(Icons.lock_outline_rounded, size: 14, color: _cBorder),
        ],
      ),
    );
  }

  Widget _datePicker() {
    return _FieldRow(
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDob ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: const ColorScheme.light(primary: _cPrimary),
              ),
              child: child!,
            ),
          );
          if (picked != null) setState(() => _selectedDob = picked);
        },
        child: Row(
          children: [
            const Icon(Icons.cake_rounded, size: 19, color: _cTextHint),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ngày sinh',
                      style: TextStyle(color: _cTextHint, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    _selectedDob == null
                        ? 'Chưa cập nhật'
                        : DateFormat('dd / MM / yyyy').format(_selectedDob!),
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: _selectedDob == null ? _cTextHint : _cText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, size: 15,
                color: _selectedDob != null ? _cPrimary : _cBorder),
          ],
        ),
      ),
    );
  }

  Widget _genderPicker() {
    return _FieldRow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Giới tính',
              style: TextStyle(color: _cTextHint, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [
              _GenderChip(label: 'Nam',  icon: Icons.male_rounded,         selected: _selectedGender == 'Nam',  onTap: () => setState(() => _selectedGender = 'Nam')),
              const SizedBox(width: 8),
              _GenderChip(label: 'Nữ',   icon: Icons.female_rounded,       selected: _selectedGender == 'Nữ',   onTap: () => setState(() => _selectedGender = 'Nữ')),
              const SizedBox(width: 8),
              _GenderChip(label: 'Khác', icon: Icons.transgender_rounded,  selected: _selectedGender == 'Khác', onTap: () => setState(() => _selectedGender = 'Khác')),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _bloodTypePicker() {
    return _FieldRow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bloodtype_outlined, size: 14, color: Color(0xFFF43F5E)),
            const SizedBox(width: 5),
            const Text('Nhóm máu',
                style: TextStyle(color: _cTextHint, fontSize: 12, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bloodTypes.map((bt) {
              final sel = _selectedBloodType == bt;
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodType = bt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 50,
                  height: 38,
                  decoration: BoxDecoration(
                    color: sel ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? const Color(0xFFF43F5E) : _cBorder,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(bt, style: TextStyle(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      color: sel ? const Color(0xFFF43F5E) : _cTextHint,
                    )),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _switchRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return _FieldRow(
      isLast: isLast,
      noDivider: isLast,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _cText)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: _cTextHint)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _cPrimary,
          ),
        ],
      ),
    );
  }

  // ── Save button ──────────────────────────────────────────────────────────────
  Widget _buildSaveButton(PatientProfileController ctrl) {
    final busy = ctrl.status == PatientProfileStatus.updating;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (!widget.embeddedInTab) ...[
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: _cBorder, width: 1.5),
                ),
                child: const Text('Hủy',
                    style: TextStyle(color: _cTextSub, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: busy ? _cBorder : _cPrimary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: busy
                    ? []
                    : [
                        BoxShadow(
                          color: _cPrimary.withValues(alpha: 0.38),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: ElevatedButton.icon(
                onPressed: busy ? null : _saveProfile,
                icon: busy
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_rounded, size: 20),
                label: Text(busy ? 'Đang lưu...' : 'Lưu thông tin',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout ───────────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w700)),
            content: const Text('Bạn có chắc chắn muốn đăng xuất không?',
                style: TextStyle(color: _cTextSub)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: _cTextHint))),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (!widget.embeddedInTab && mounted) Navigator.pop(context);
                  await context.read<AuthController>().logout();
                  if (mounted) context.go('/login');
                },
                child: const Text('Đăng xuất',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 17, color: Color(0xFFEF4444)),
        label: const Text('Đăng xuất khỏi ứng dụng',
            style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}

// ── _FieldRow — divider wrapper ───────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final Widget child;
  final bool isLast;
  final bool noDivider;
  const _FieldRow({required this.child, this.isLast = false, this.noDivider = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: child),
        if (!isLast && !noDivider) const Divider(height: 1, color: _cBorder),
      ],
    );
  }
}

// ── _HeroPill ─────────────────────────────────────────────────────────────────
class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? accent;
  const _HeroPill({required this.icon, required this.label, this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: accent != null ? 0.15 : 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accent ?? Colors.white70),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(
              color: accent ?? Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── _GenderChip ───────────────────────────────────────────────────────────────
class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? _cPrimary.withValues(alpha: 0.07) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _cPrimary : _cBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? _cPrimary : _cTextHint),
              const SizedBox(height: 3),
              Text(label, style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _cPrimary : _cTextHint,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick access grid ─────────────────────────────────────────────────────────
class _QuickItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _QuickItem(this.icon, this.label, this.route, this.color);
}

class _QuickTile extends StatelessWidget {
  final _QuickItem item;
  final String uid;
  const _QuickTile({required this.item, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withValues(alpha: 0.06),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final route = item.route == '/admission/history/me'
              ? '/admission/history/$uid'
              : item.route;
          context.push(route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _cText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
