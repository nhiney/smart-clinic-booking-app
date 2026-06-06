import 'package:flutter/material.dart';

class _C {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF059669);
}

/// Cá nhân — hồ sơ bệnh nhân, hạng thành viên, thông tin, hồ sơ y tế.
/// Route /profile-detail.
class PatientProfileDetailScreen extends StatelessWidget {
  const PatientProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _C.bg,
            foregroundColor: _C.textPrimary,
            elevation: 0,
            pinned: true,
            title: const Text('Hồ sơ',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
            actions: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _profileCard(),
                  const SizedBox(height: 14),
                  _statsRow(),
                  const SizedBox(height: 22),
                  _sectionLabel('THÔNG TIN CÁ NHÂN'),
                  const SizedBox(height: 10),
                  _infoGroup([
                    _info(Icons.person_outline_rounded, 'Họ tên', 'Phạm Anh Tuấn'),
                    _info(Icons.cake_outlined, 'Ngày sinh', '12/08/1990 · 35 tuổi'),
                    _info(Icons.shield_outlined, 'CCCD', '001090012345 · Đã xác minh',
                        verified: true),
                    _info(Icons.location_on_outlined, 'Địa chỉ',
                        'Quận Cầu Giấy, Hà Nội'),
                  ]),
                  const SizedBox(height: 22),
                  _sectionLabel('HỒ SƠ Y TẾ'),
                  const SizedBox(height: 10),
                  _infoGroup([
                    _info(Icons.description_outlined, 'Hồ sơ bệnh án', '12 lượt khám',
                        route: '/medical-history'),
                    _info(Icons.medication_outlined, 'Lịch uống thuốc',
                        '3 thuốc đang dùng', route: '/medication-schedule'),
                    _info(Icons.science_outlined, 'Kết quả xét nghiệm',
                        'Mới nhất 23/05', route: '/lab-results'),
                    _info(Icons.groups_outlined, 'Hồ sơ gia đình', '5 thành viên',
                        route: '/family'),
                  ], context: context),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Đăng xuất'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _C.primary.withValues(alpha: 0.8),
                      const Color(0xFF60A5FA)
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('AT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900)),
                ),
              ),
              const Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: _C.primary,
                  child: Icon(Icons.verified_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Phạm Anh Tuấn',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _C.textPrimary)),
                const SizedBox(height: 2),
                const Text('+84 912 345 678 · BHYT GD4',
                    style: TextStyle(fontSize: 13, color: _C.textSecondary)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _badge(Icons.verified_user_rounded, 'Đã xác minh',
                        _C.primary, _C.primary.withValues(alpha: 0.1)),
                    const SizedBox(width: 8),
                    _badge(Icons.workspace_premium_rounded, 'Hạng Vàng',
                        _C.green, _C.green.withValues(alpha: 0.1)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: [
        _stat('12', 'Lượt khám'),
        const SizedBox(width: 12),
        _stat('8', 'Bác sĩ'),
        const SizedBox(width: 12),
        _stat('3', 'BV thường khám'),
      ],
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _C.primary)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: _C.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(t,
          style: const TextStyle(
              color: _C.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5)),
    );
  }

  Widget _infoGroup(List<_InfoItem> items, {BuildContext? context}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: _C.border, indent: 56),
            _infoTile(items[i], context),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(_InfoItem it, BuildContext? context) {
    return InkWell(
      onTap: (it.route != null && context != null)
          ? () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Mở ${it.label}'),
                    duration: const Duration(milliseconds: 800)),
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(it.icon, color: _C.textSecondary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.label,
                      style: const TextStyle(
                          fontSize: 12, color: _C.textSecondary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(it.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _C.textPrimary)),
                      ),
                      if (it.verified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle_rounded,
                            color: _C.green, size: 16),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _C.textSecondary),
          ],
        ),
      ),
    );
  }

  _InfoItem _info(IconData icon, String label, String value,
          {bool verified = false, String? route}) =>
      _InfoItem(icon, label, value, verified, route);
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;
  final String? route;
  _InfoItem(this.icon, this.label, this.value, this.verified, this.route);
}
