import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';
import '../../../patient_pov/domain/entities/doctor_entity.dart';

class DoctorWorkspaceScreen extends StatelessWidget {
  const DoctorWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final doc = ctrl.currentDoctor;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, doc),
          SliverToBoxAdapter(child: _buildStatsRow(doc)),
          SliverToBoxAdapter(child: _buildBioSection(doc)),
          SliverToBoxAdapter(child: _buildQuickLinks(context)),
          SliverToBoxAdapter(child: _buildCertsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, DoctorEntity? doc) {
    final initials = (doc?.name ?? 'BS').split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join().toUpperCase();
    return SliverAppBar(
      expandedHeight: 264,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF1D4ED8),
      leading: const BackButton(color: Colors.white),
      actions: [
        IconButton(
          tooltip: 'Thông báo',
          icon: const Icon(Icons.notifications_rounded, color: Colors.white),
          onPressed: () => context.push('/notifications'),
        ),
        IconButton(
          tooltip: 'Cài đặt',
          icon: const Icon(Icons.settings_rounded, color: Colors.white),
          onPressed: () => context.push('/notifications/settings'),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF38BDF8), Color(0xFF0EA5E9)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Center(child: Text(initials, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white))),
                      ),
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(color: const Color(0xFF2563EB), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(doc?.name ?? 'BS.', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${doc?.specialty ?? 'Chuyên khoa'} · ${doc?.experience ?? 0} năm KN',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _BadgePill(icon: Icons.star_rounded, label: doc?.rating.toStringAsFixed(1) ?? '4.9', color: const Color(0xFFFBBF24)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: _BadgePill(
                            icon: Icons.local_hospital_rounded,
                            label: (doc?.hospital.isNotEmpty ?? false)
                                ? doc!.hospital
                                : 'BV Bạch Mai',
                            color: Colors.white.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text('Hồ sơ bác sĩ', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  Widget _buildStatsRow(DoctorEntity? doc) {
    return Container(
      color: const Color(0xFF1D4ED8),
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            _StatItem(value: '4.2K', label: 'Bệnh nhân'),
            _Divider(),
            _StatItem(value: '${doc?.totalReviews ?? 312}', label: 'Đánh giá'),
            _Divider(),
            const _StatItem(value: '97%', label: 'Hài lòng'),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(DoctorEntity? doc) {
    final about = doc?.about ?? 'Bác sĩ chuyên khoa II, tốt nghiệp ĐH Y Hà Nội. Chuyên về can thiệp mạch vành và rối loạn nhịp tim.';
    final tags = ['Can thiệp mạch vành', 'Siêu âm tim', 'Holter 24h', 'ECG'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Giới thiệu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(about, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: tags.map((t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20)),
              child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      (Icons.calendar_month_rounded, 'Lịch làm việc', '5 ngày/tuần', const Color(0xFF1D4ED8), '/doctor/schedule-settings'),
      (Icons.account_balance_wallet_rounded, 'Thu nhập', 'đ24.8M tháng', const Color(0xFF059669), '/doctor/income'),
      (Icons.star_rounded, 'Đánh giá', '312 lượt · 4.9', const Color(0xFFF59E0B), '/doctor/analytics'),
      (Icons.notifications_rounded, 'Tin nhắn', '3 mới', const Color(0xFF7C3AED), '/doctor/chat'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: links.map((l) => GestureDetector(
          onTap: () => context.push(l.$5),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: l.$4.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(l.$1, color: l.$4, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A))),
                      Text(l.$3, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCertsSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bằng cấp & Chứng chỉ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF0F172A))),
              TextButton(onPressed: () {}, child: const Text('3 mục', style: TextStyle(color: Color(0xFF1D4ED8)))),
            ],
          ),
          const SizedBox(height: 8),
          _CertItem(icon: Icons.school_rounded, title: 'Bác sĩ CK II Tim mạch', subtitle: 'ĐH Y Hà Nội · 2012'),
          _CertItem(icon: Icons.workspace_premium_rounded, title: 'Fellowship Can thiệp Tim mạch', subtitle: "St. Mary's London · 2018"),
          _CertItem(icon: Icons.verified_rounded, title: 'Chứng chỉ Siêu âm Tim', subtitle: 'Hội Tim mạch VN · 2015'),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _BadgePill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
      ]),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: const Color(0xFFE2E8F0));
  }
}

class _CertItem extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _CertItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: const Color(0xFF1D4ED8)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ])),
      ]),
    );
  }
}
