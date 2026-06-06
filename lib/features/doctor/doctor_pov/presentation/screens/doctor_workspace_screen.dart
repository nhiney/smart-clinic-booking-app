import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';
import '../../../patient_pov/domain/entities/doctor_entity.dart';

class DoctorWorkspaceScreen extends StatefulWidget {
  const DoctorWorkspaceScreen({super.key});

  @override
  State<DoctorWorkspaceScreen> createState() => _DoctorWorkspaceScreenState();
}

class _DoctorWorkspaceScreenState extends State<DoctorWorkspaceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _specialtyCtrl;
  late TextEditingController _hospitalCtrl;
  late TextEditingController _clinicCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _aboutCtrl;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final doc = context.read<DoctorController>().currentDoctor;
    _nameCtrl = TextEditingController(text: doc?.name ?? '');
    _specialtyCtrl = TextEditingController(text: doc?.specialty ?? '');
    _hospitalCtrl = TextEditingController(text: doc?.hospital ?? '');
    _clinicCtrl = TextEditingController(text: doc?.clinicName ?? '');
    _locationCtrl = TextEditingController(text: doc?.location ?? '');
    _phoneCtrl = TextEditingController(text: doc?.phone ?? '');
    _aboutCtrl = TextEditingController(text: doc?.about ?? '');
    for (final c in [_nameCtrl, _specialtyCtrl, _hospitalCtrl, _clinicCtrl, _locationCtrl, _phoneCtrl, _aboutCtrl]) {
      c.addListener(() => setState(() => _dirty = true));
    }
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _specialtyCtrl, _hospitalCtrl, _clinicCtrl, _locationCtrl, _phoneCtrl, _aboutCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<DoctorController>();
    await ctrl.updateDoctorWorkspaceProfile(
      name: _nameCtrl.text.trim(),
      specialty: _specialtyCtrl.text.trim(),
      hospital: _hospitalCtrl.text.trim(),
      about: _aboutCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      clinicName: _clinicCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật hồ sơ'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final doc = ctrl.currentDoctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(doc),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildAvatarCard(doc),
                    const SizedBox(height: 16),
                    _buildInfoCard(),
                    const SizedBox(height: 16),
                    _buildContactCard(),
                    const SizedBox(height: 16),
                    _buildAboutCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(ctrl),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(DoctorEntity? doc) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF0F4C8A),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F4C8A), Color(0xFF1976D2)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hồ sơ bác sĩ', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(doc?.name ?? '—', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Hồ sơ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
      leading: const BackButton(color: Colors.white),
      actions: [
        if (_dirty)
          TextButton(
            onPressed: _save,
            child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ),
      ],
    );
  }

  Widget _buildAvatarCard(DoctorEntity? doc) {
    final initials = (doc?.name ?? 'BS').split(' ').last.substring(0, 1).toUpperCase();
    return _Card(
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.15),
                backgroundImage: (doc?.imageUrl.isNotEmpty ?? false) ? NetworkImage(doc!.imageUrl) : null,
                child: (doc?.imageUrl.isEmpty ?? true) ? Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF1976D2))) : null,
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: const Color(0xFF1976D2), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc?.name ?? '—', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text(doc?.specialty ?? '—', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 4),
                  Text('${doc?.rating.toStringAsFixed(1) ?? '—'}  •  ${doc?.totalReviews ?? 0} đánh giá',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _Card(
      title: 'Thông tin cơ bản',
      child: Column(
        children: [
          _Field(ctrl: _nameCtrl, label: 'Họ và tên', icon: Icons.person_rounded, required: true),
          _Field(ctrl: _specialtyCtrl, label: 'Chuyên khoa', icon: Icons.medical_services_rounded, required: true),
          _Field(ctrl: _hospitalCtrl, label: 'Bệnh viện / Cơ sở', icon: Icons.local_hospital_rounded),
          _Field(ctrl: _clinicCtrl, label: 'Phòng khám', icon: Icons.room_service_rounded),
          _Field(ctrl: _locationCtrl, label: 'Địa điểm', icon: Icons.location_on_rounded, isLast: true),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return _Card(
      title: 'Liên hệ',
      child: _Field(ctrl: _phoneCtrl, label: 'Số điện thoại', icon: Icons.phone_rounded, keyboardType: TextInputType.phone, isLast: true),
    );
  }

  Widget _buildAboutCard() {
    return _Card(
      title: 'Giới thiệu bản thân',
      child: _Field(ctrl: _aboutCtrl, label: 'Mô tả', icon: Icons.description_rounded, maxLines: 5, isLast: true),
    );
  }

  Widget _buildSaveButton(DoctorController ctrl) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: ctrl.isLoading ? null : _save,
        icon: ctrl.isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(ctrl.isLoading ? 'Đang lưu...' : 'Lưu hồ sơ', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final Widget child;
  const _Card({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
            const Divider(height: 20, color: Color(0xFFF1F5F9)),
          ],
          child,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool required;
  final bool isLast;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.required = false,
    this.isLast = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập $label' : null : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
