import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/patient_profile_controller.dart';
import '../../domain/entities/patient_profile.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key, this.embeddedInTab = false});

  /// Khi true: không nút back, chỉ nút Lưu; phù hợp nhúng trong tab tài khoản trang chủ bệnh nhân.
  final bool embeddedInTab;

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Info
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  DateTime? _selectedDob;
  String? _selectedGender;
  
  // Medical Info
  String? _selectedBloodType;
  late TextEditingController _allergiesController;
  late TextEditingController _historyController;
  
  // Email Settings
  late TextEditingController _emailController;
  bool _receiveEmail = false;
  bool _cloudStorageEnabled = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _initControllers() {
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _allergiesController = TextEditingController();
    _historyController = TextEditingController();
    _emailController = TextEditingController();
  }

  void _loadData() {
    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.id ?? '';
    final userPhone = auth.currentUser?.phone ?? '';
    
    context.read<PatientProfileController>().loadProfile(userId, userPhone).then((_) {
      final profile = context.read<PatientProfileController>().profile;
      if (profile != null) {
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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _allergiesController.dispose();
    _historyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.embeddedInTab,
        leading: widget.embeddedInTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          widget.embeddedInTab ? "Tài khoản" : "Hồ sơ cá nhân",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Consumer<PatientProfileController>(
        builder: (context, controller, child) {
          if (controller.status == PatientProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                   _buildAvatarSection(),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle("Thông tin cá nhân"),
                  _buildCard([
                    _buildInputField(
                      label: "Họ và tên",
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập họ tên" : null,
                    ),
                    _buildReadOnlyField(
                      label: "Số điện thoại",
                      value: context.read<AuthController>().currentUser?.phone ?? '',
                      icon: Icons.phone_android_rounded,
                    ),
                    _buildDatePicker(),
                    _buildGenderDropdown(),
                    _buildInputField(
                      label: "Địa chỉ thường trú",
                      controller: _addressController,
                      icon: Icons.location_on_outlined,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle("Thông tin y tế"),
                  _buildCard([
                    _buildBloodTypeDropdown(),
                    _buildInputField(
                      label: "Tình trạng dị ứng",
                      controller: _allergiesController,
                      icon: Icons.warning_amber_rounded,
                      hint: "VD: Hải sản, Penicillin...",
                    ),
                    _buildInputField(
                      label: "Tiền sử bệnh lý",
                      controller: _historyController,
                      icon: Icons.history_edu_rounded,
                      maxLines: 3,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle("Cài đặt & Email"),
                  _buildCard([
                    _buildInputField(
                      label: "Email nhận hồ sơ",
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (_receiveEmail) {
                          if (v == null || v.isEmpty) return "Cần nhập email để nhận hồ sơ";
                          if (!v.contains('@')) return "Email không hợp lệ";
                        }
                        return null;
                      },
                    ),
                    _buildSwitchTile(
                      label: "Nhận kết quả khám qua Email",
                      subtitle: "Tự động gửi hồ sơ PDF khi có kết quả",
                      value: _receiveEmail,
                      onChanged: (v) => setState(() => _receiveEmail = v),
                    ),
                    _buildSwitchTile(
                      label: "Lưu trữ hồ sơ online",
                      subtitle: "Truy cập hồ sơ bệnh án mọi lúc",
                      value: _cloudStorageEnabled,
                      onChanged: (v) => setState(() => _cloudStorageEnabled = v),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  
                  _buildActionButtons(controller),
                  const SizedBox(height: 16),
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

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 54,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person_rounded, size: 64, color: Color(0xFF94A3B8)),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {}, // Pick image logic
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          floatingLabelStyle: const TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.w600),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4A90E2), width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                Divider(color: Colors.grey.shade200, height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDob ?? DateTime(1990),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) setState(() => _selectedDob = picked);
        },
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 19, color: Color(0xFF64748B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Ngày sinh", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDob == null ? "Chưa cập nhật" : DateFormat('dd/MM/yyyy').format(_selectedDob!),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade200, height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          labelText: "Giới tính",
          prefixIcon: const Icon(Icons.people_outline_rounded, size: 20, color: Color(0xFF64748B)),
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        items: ["Nam", "Nữ", "Khác"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _selectedGender = v),
      ),
    );
  }

  Widget _buildBloodTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedBloodType,
        decoration: InputDecoration(
          labelText: "Nhóm máu",
          prefixIcon: const Icon(Icons.bloodtype_outlined, size: 20, color: Color(0xFF64748B)),
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade200)),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        items: ["A", "B", "AB", "O"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => _selectedBloodType = v),
      ),
    );
  }

  Widget _buildSwitchTile({required String label, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile.adaptive(
      title: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF4A90E2),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons(PatientProfileController controller) {
    final saveButton = ElevatedButton(
      onPressed: controller.status == PatientProfileStatus.updating ? null : _saveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: controller.status == PatientProfileStatus.updating
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("Lưu thông tin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );

    if (widget.embeddedInTab) {
      return SizedBox(width: double.infinity, child: saveButton);
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Text("Hủy", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: saveButton),
      ],
    );
  }

  Widget _buildLogoutButton() {
     return TextButton.icon(
       onPressed: () => _showLogoutDialog(context),
       icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
       label: const Text("Đăng xuất khỏi ứng dụng", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
     );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              if (!widget.embeddedInTab) {
                Navigator.pop(context); // Close pushed profile screen
              }
              await context.read<AuthController>().logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thành công!"),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) context.read<PatientProfileController>().resetStatus();
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: ${context.read<PatientProfileController>().errorMessage}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

