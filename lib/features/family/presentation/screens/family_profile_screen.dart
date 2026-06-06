import 'package:flutter/material.dart';

/// Hồ sơ gia đình — quản lý lịch khám, đơn thuốc cho các thành viên trong nhà.
/// Route /family. Dữ liệu demo theo thiết kế.
class FamilyProfileScreen extends StatefulWidget {
  const FamilyProfileScreen({super.key});

  @override
  State<FamilyProfileScreen> createState() => _FamilyProfileScreenState();
}

class _FamilyProfileScreenState extends State<FamilyProfileScreen> {
  static const _primary = Color(0xFF1D4ED8);
  static const _bg = Color(0xFFF8FAFC);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textSecondary = Color(0xFF64748B);

  int _selected = 0;

  static const _members = [
    _Member('Phạm Anh Tuấn', 'AT', 'Bản thân · Chủ tài khoản · 35 tuổi · BHYT GD4',
        'Hôm nay', Color(0xFF3B82F6), isSelf: true),
    _Member('Phạm Thu Hà', 'TH', 'Vợ · 32 tuổi · BHYT TN5', '2 tuần trước',
        Color(0xFFEC4899)),
    _Member('Phạm Minh Khang', 'MK', 'Con trai · 8 tuổi · BHYT TE1', '1 tháng trước',
        Color(0xFF10B981)),
    _Member('Phạm Văn Thành', 'VT', 'Bố · 64 tuổi · BHYT HT3', '3 ngày trước',
        Color(0xFFF59E0B)),
    _Member('Nguyễn Thị Mai', 'TM', 'Mẹ · 60 tuổi · BHYT HT3', '5 ngày trước',
        Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: const Text('Hồ sơ gia đình',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _addMember,
            icon: const Icon(Icons.add_rounded, color: _primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Chăm sóc cả nhà',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary)),
          const SizedBox(height: 6),
          const Text(
            'Quản lý lịch khám, đơn thuốc cho 5 thành viên. Bố và con trai có lịch sắp tới.',
            style: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _premiumCard(),
          const SizedBox(height: 14),
          Row(
            children: [
              _statCard('5', 'THÀNH VIÊN', ''),
              const SizedBox(width: 12),
              _statCard('2', 'LỊCH HẸN', 'trong tuần'),
              const SizedBox(width: 12),
              _statCard('3', 'THUỐC', 'đang dùng'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Thành viên',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Quản lý',
                    style: TextStyle(
                        color: _primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Text('Chạm để chọn người khám',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          ...List.generate(_members.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _memberCard(_members[i], i == _selected,
                  () => setState(() => _selected = i)),
            );
          }),
        ],
      ),
    );
  }

  void _addMember() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thêm thành viên gia đình')),
    );
  }

  Widget _premiumCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0E7FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GÓI GIA ĐÌNH PREMIUM',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                SizedBox(height: 4),
                Text('Bảo vệ toàn diện',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Còn 248 ngày · Tới 26/01/2027',
                    style: TextStyle(color: _textSecondary, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            height: 40,
            child: Stack(
              children: List.generate(5, (i) {
                const colors = [
                  Color(0xFF3B82F6),
                  Color(0xFFEC4899),
                  Color(0xFF10B981),
                  Color(0xFFF59E0B),
                  Color(0xFF8B5CF6),
                ];
                return Positioned(
                  left: i * 16.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors[i],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 18),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900)),
            if (sub.isNotEmpty)
              Text(sub,
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _memberCard(_Member m, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _primary : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: m.color.withValues(alpha: 0.18),
                  child: Text(m.initials,
                      style: TextStyle(
                          color: m.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 15)),
                ),
                if (selected)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: _primary,
                      child: Icon(Icons.check_rounded,
                          color: Colors.white, size: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(m.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary)),
                      ),
                      if (m.isSelf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('BẠN',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(m.detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: _textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Khám gần nhất',
                    style: TextStyle(fontSize: 10, color: _textSecondary)),
                const SizedBox(height: 2),
                Text(m.lastVisit,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Member {
  final String name;
  final String initials;
  final String detail;
  final String lastVisit;
  final Color color;
  final bool isSelf;
  const _Member(this.name, this.initials, this.detail, this.lastVisit, this.color,
      {this.isSelf = false});
}
