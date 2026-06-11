import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  final List<_Member> _members = [
    _Member('Phạm Anh Tuấn', 'AT', 'Bản thân · Chủ tài khoản · 35 tuổi · BHYT GD4',
        'Hôm nay', const Color(0xFF3B82F6), isSelf: true),
    _Member('Phạm Thu Hà', 'TH', 'Vợ · 32 tuổi · BHYT TN5', '2 tuần trước',
        const Color(0xFFEC4899)),
    _Member('Phạm Minh Khang', 'MK', 'Con trai · 8 tuổi · BHYT TE1', '1 tháng trước',
        const Color(0xFF10B981)),
    _Member('Phạm Văn Thành', 'VT', 'Bố · 64 tuổi · BHYT HT3', '3 ngày trước',
        const Color(0xFFF59E0B)),
    _Member('Nguyễn Thị Mai', 'TM', 'Mẹ · 60 tuổi · BHYT HT3', '5 ngày trước',
        const Color(0xFF8B5CF6)),
  ];

  static const _relationships = ['Bản thân', 'Vợ', 'Chồng', 'Con trai', 'Con gái', 'Bố', 'Mẹ', 'Anh', 'Em', 'Ông', 'Bà', 'Khác'];
  static const _memberColors = [
    Color(0xFF3B82F6), Color(0xFFEC4899), Color(0xFF10B981),
    Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF06B6D4),
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
            onPressed: _showAddMemberDialog,
            icon: const Icon(Icons.add_rounded, color: _primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Chăm sóc cả nhà',
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary)),
          const SizedBox(height: 6),
          Text(
            'Quản lý lịch khám, đơn thuốc cho ${_members.length} thành viên.',
            style: const TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          _premiumCard(),
          const SizedBox(height: 14),
          Row(
            children: [
              _statCard('${_members.length}', 'THÀNH VIÊN', ''),
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
                onPressed: _showManageSheet,
                child: const Text('Quản lý',
                    style: TextStyle(
                        color: _primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const Text('Chạm để đặt lịch cho thành viên',
              style: TextStyle(color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          ...List.generate(_members.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _memberCard(_members[i], i == _selected, () {
                setState(() => _selected = i);
                _showMemberOptions(_members[i]);
              }),
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _showAddMemberDialog,
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Thêm thành viên gia đình'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              side: const BorderSide(color: _primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final insuranceCtrl = TextEditingController();
    String selectedRelationship = _relationships[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Thêm thành viên',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary)),
              const SizedBox(height: 20),
              _inputField('Họ và tên', nameCtrl, Icons.person_outline_rounded),
              const SizedBox(height: 14),
              const Text('Mối quan hệ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _relationships.map((r) {
                  final sel = r == selectedRelationship;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedRelationship = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? _primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(r, style: TextStyle(
                        color: sel ? Colors.white : _textSecondary,
                        fontWeight: FontWeight.w600, fontSize: 13,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _inputField('Tuổi', ageCtrl, Icons.cake_outlined, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('Số BHYT', insuranceCtrl, Icons.credit_card_rounded)),
              ]),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    final initials = nameCtrl.text.trim().split(' ')
                        .where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase();
                    final age = int.tryParse(ageCtrl.text) ?? 0;
                    final detail = '$selectedRelationship · ${age > 0 ? '$age tuổi · ' : ''}${insuranceCtrl.text.trim().isNotEmpty ? insuranceCtrl.text.trim() : 'Chưa có BHYT'}';
                    final color = _memberColors[_members.length % _memberColors.length];
                    setState(() {
                      _members.add(_Member(nameCtrl.text.trim(), initials, detail, 'Chưa khám', color));
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm ${nameCtrl.text.trim()} vào hồ sơ gia đình'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Thêm thành viên', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: _textSecondary),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showManageSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Quản lý thành viên',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textPrimary)),
              const SizedBox(height: 4),
              const Text('Nhấn giữ để xóa thành viên',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
              const SizedBox(height: 16),
              ..._members.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: m.color.withValues(alpha: 0.18),
                    child: Text(m.initials, style: TextStyle(color: m.color, fontWeight: FontWeight.w800)),
                  ),
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700, color: _textPrimary)),
                  subtitle: Text(m.detail, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _textSecondary)),
                  trailing: m.isSelf
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Bạn', style: TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.w700)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                          onPressed: () {
                            setModalState(() {});
                            setState(() {
                              if (_selected >= i && _selected > 0) _selected--;
                              _members.removeAt(i);
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã xóa ${m.name} khỏi hồ sơ gia đình')),
                            );
                          },
                        ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showAddMemberDialog();
                  },
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('Thêm thành viên mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: const BorderSide(color: _primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberOptions(_Member member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: member.color.withValues(alpha: 0.18),
                child: Text(member.initials, style: TextStyle(color: member.color, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(member.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textPrimary)),
                Text(member.detail, maxLines: 2, style: const TextStyle(fontSize: 12, color: _textSecondary)),
              ])),
            ]),
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),
            _optionTile(ctx, Icons.calendar_month_rounded, 'Đặt lịch khám', const Color(0xFF1D4ED8),
                () => context.push('/doctor/find')),
            _optionTile(ctx, Icons.history_rounded, 'Lịch hẹn của thành viên', const Color(0xFF7C3AED),
                () => context.push('/appointments')),
            _optionTile(ctx, Icons.medication_rounded, 'Lịch thuốc', const Color(0xFFE91E63),
                () => context.push('/medication-schedule')),
            _optionTile(ctx, Icons.folder_open_rounded, 'Hồ sơ bệnh án', const Color(0xFFFF6D00),
                () => context.push('/medical-history')),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: _textPrimary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      onTap: () {
        Navigator.pop(ctx);
        onTap();
      },
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
