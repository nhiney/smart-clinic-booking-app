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

  static const _kPrimary = Color(0xFF0D62A2);
  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _allergiesController = TextEditingController();
    _historyController = TextEditingController();
    _emailController = TextEditingController();
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
    final userId = auth.currentUser?.id ?? '';
    final userPhone = auth.currentUser?.phone ?? '';
    context.read<PatientProfileController>().loadProfile(userId, userPhone).then((_) {
      final profile = context.read<PatientProfileController>().profile;
      if (profile != null && mounted) {
        setState(() {
          _nameController.text = profile.fullName;
          _addressController.text = profile.address ?? '';
          _selectedDob = profile.dob;
          _selectedGender = profile.gender;
          _selectedBloodType = profile.bloodType;
          _allergiesController.text = profile.allergies ?? '';
          _historyController.text = profile.medicalHistory ?? '';
          _emailController.text = profile.email ?? '';
          _receiveEmail = profile.receiveEmail;
          _cloudStorageEnabled = profile.cloudStorageEnabled;
        });
      }
    });
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null && mounted) setState(() => _avatarPath = picked.path);
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final profile = PatientProfile(
      fullName: _nameController.text.trim(),
      phone: auth.currentUser?.phone ?? '',
      dob: _selectedDob,
      gender: _selectedGender,
      address: _addressController.text.trim(),
      bloodType: _selectedBloodType,
      allergies: _allergiesController.text.trim(),
      medicalHistory: _historyController.text.trim(),
      email: _emailController.text.trim(),
      receiveEmail: _receiveEmail,
      cloudStorageEnabled: _cloudStorageEnabled,
    );
    final success = await context.read<PatientProfileController>().updateProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Cập nhật thành công!' : 'Lỗi: ${context.read<PatientProfileController>().errorMessage}'),
      backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
      behavior: SnackBarBehavior.floating,
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
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: widget.embeddedInTab
          ? null
          : const BrandedAppBar(title: 'Hồ sơ cá nhân', showBackButton: true),
      body: Consumer<PatientProfileController>(
        builder: (context, controller, _) {
          if (controller.status == PatientProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _HeroHeader(
                    name: _nameController.text.isNotEmpty ? _nameController.text : 'Người dùng',
                    phone: context.read<AuthController>().currentUser?.phone ?? '',
                    bloodType: _selectedBloodType,
                    avatarPath: _avatarPath,
                    onPickAvatar: _pickAvatar,
                  ),
                  const SizedBox(height: 20),
                  _MedicalManagementSection(controller: controller),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    icon: Icons.person_rounded,
                    title: 'Thông tin cá nhân',
                    children: [
                      _inputField(
                        label: 'Họ và tên',
                        controller: _nameController,
                        icon: Icons.badge_outlined,
                        validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
                      ),
                      _readOnlyField(
                        label: 'Số điện thoại',
                        value: context.read<AuthController>().currentUser?.phone ?? '',
                        icon: Icons.phone_android_rounded,
                      ),
                      _datePicker(),
                      _genderPicker(),
                      _inputField(
                        label: 'Địa chỉ thường trú',
                        controller: _addressController,
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.health_and_safety_rounded,
                    title: 'Thông tin y tế',
                    iconColor: Colors.green,
                    children: [
                      _bloodTypePicker(),
                      _inputField(
                        label: 'Tình trạng dị ứng',
                        controller: _allergiesController,
                        icon: Icons.warning_amber_rounded,
                        hint: 'VD: Hải sản, Penicillin...',
                        iconColor: Colors.orange,
                      ),
                      _inputField(
                        label: 'Tiền sử bệnh lý',
                        controller: _historyController,
                        icon: Icons.history_edu_rounded,
                        maxLines: 3,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.settings_rounded,
                    title: 'Cài đặt & Thông báo',
                    iconColor: Colors.purple,
                    children: [
                      _inputField(
                        label: 'Email nhận hồ sơ',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (_receiveEmail) {
                            if (v == null || v.isEmpty) return 'Cần nhập email để nhận hồ sơ';
                            if (!v.contains('@')) return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      _switchTile(
                        label: 'Nhận kết quả khám qua Email',
                        subtitle: 'Tự động gửi hồ sơ PDF khi có kết quả',
                        value: _receiveEmail,
                        onChanged: (v) => setState(() => _receiveEmail = v),
                      ),
                      _switchTile(
                        label: 'Lưu trữ hồ sơ online',
                        subtitle: 'Truy cập hồ sơ bệnh án mọi lúc',
                        value: _cloudStorageEnabled,
                        onChanged: (v) => setState(() => _cloudStorageEnabled = v),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildActionButtons(controller),
                  const SizedBox(height: 12),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section card ─────────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Color iconColor = _kPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ── Input field ───────────────────────────────────────────────────────────────
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Color iconColor = const Color(0xFF64748B),
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 8 : 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: iconColor),
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          floatingLabelStyle: TextStyle(color: _kPrimary, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _kPrimary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }

  Widget _readOnlyField({required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                ],
              ),
            ),
            const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDob ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => _selectedDob = picked);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ngày sinh', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      _selectedDob == null ? 'Chưa cập nhật' : DateFormat('dd/MM/yyyy').format(_selectedDob!),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _selectedDob == null ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _genderPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('Giới tính', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Row(
            children: ['Nam', 'Nữ', 'Khác'].map((g) {
              final selected = _selectedGender == g;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? _kPrimary.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? _kPrimary : const Color(0xFFE2E8F0),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        g,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? _kPrimary : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _bloodTypePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.bloodtype_outlined, size: 18, color: Colors.red),
                SizedBox(width: 6),
                Text('Nhóm máu', style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bloodTypes.map((bt) {
              final selected = _selectedBloodType == bt;
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodType = bt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.red : const Color(0xFFE2E8F0),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bt,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        color: selected ? Colors.red : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 4 : 0),
      child: SwitchListTile.adaptive(
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        value: value,
        onChanged: onChanged,
        activeColor: _kPrimary,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  Widget _buildActionButtons(PatientProfileController controller) {
    final isUpdating = controller.status == PatientProfileStatus.updating;
    final saveBtn = SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isUpdating ? null : _saveProfile,
        icon: isUpdating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save_rounded, size: 18),
        label: Text(isUpdating ? 'Đang lưu...' : 'Lưu thông tin',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );

    if (widget.embeddedInTab) {
      return Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: double.infinity, child: saveBtn));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: saveBtn),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                if (!widget.embeddedInTab && mounted) Navigator.pop(context);
                await context.read<AuthController>().logout();
                if (mounted) context.go('/login');
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
      label: const Text('Đăng xuất khỏi ứng dụng', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String? bloodType;
  final String? avatarPath;
  final VoidCallback onPickAvatar;

  const _HeroHeader({
    required this.name,
    required this.phone,
    required this.bloodType,
    required this.avatarPath,
    required this.onPickAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D62A2), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ClipOval(
                      child: avatarPath != null
                          ? Image.file(
                              File(avatarPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onPickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Color(0xFF0D62A2)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              // Phone
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone_android_rounded, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              if (bloodType != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bloodtype_rounded, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('Nhóm máu $bloodType', style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFBFDBFE),
      child: const Icon(Icons.person_rounded, size: 56, color: Color(0xFF0D62A2)),
    );
  }
}

// ── Medical Management Section ────────────────────────────────────────────────
class _MedicalManagementSection extends StatelessWidget {
  final PatientProfileController controller;

  const _MedicalManagementSection({required this.controller});

  static const _items = [
    _MedNavItem(Icons.history_rounded, 'Lịch sử khám', '/appointments', Color(0xFF7C3AED)),
    _MedNavItem(Icons.folder_copy_rounded, 'Hồ sơ bệnh án', '/medical-records', Color(0xFF0D62A2)),
    _MedNavItem(Icons.science_rounded, 'Kết quả CLS', '/surveys', Color(0xFF0891B2)),
    _MedNavItem(Icons.receipt_long_rounded, 'Đơn thuốc', '/prescriptions', Color(0xFFE11D48)),
    _MedNavItem(Icons.medication_liquid_rounded, 'Theo dõi thuốc', '/medication', Color(0xFF16A34A)),
    _MedNavItem(Icons.local_hospital_rounded, 'Đăng ký nhập viện', '/admission/history/me', Color(0xFF5C6BC0)),
  ];

  @override
  Widget build(BuildContext context) {
    final uid = fb_auth.FirebaseAuth.instance.currentUser?.uid ?? 'me';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D62A2).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0D62A2), size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Quản lý khám bệnh', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              return _MedNavTile(item: item, uid: uid);
            },
          ),
        ],
      ),
    );
  }
}

class _MedNavItem {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _MedNavItem(this.icon, this.label, this.route, this.color);
}

class _MedNavTile extends StatelessWidget {
  final _MedNavItem item;
  final String uid;

  const _MedNavTile({required this.item, required this.uid});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        String route = item.route;
        if (route == '/admission/history/me') {
          route = '/admission/history/$uid';
        }
        context.push(route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: item.color.withValues(alpha: 0.9),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
