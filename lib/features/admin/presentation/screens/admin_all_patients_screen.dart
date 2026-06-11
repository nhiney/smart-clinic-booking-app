import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/icare_tokens.dart';
import '../controllers/admin_controller.dart';

class AdminAllPatientsScreen extends StatefulWidget {
  const AdminAllPatientsScreen({super.key});

  @override
  State<AdminAllPatientsScreen> createState() => _AdminAllPatientsScreenState();
}

class _AdminAllPatientsScreenState extends State<AdminAllPatientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAllPatientUsers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    setState(() => _query = q);
    context.read<AdminController>().fetchAllPatientUsers(searchQuery: q);
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminController>();
    final patients = ctrl.allPatientUsers;
    final vipCount = patients.where((p) => p['isVip'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildSearch(),
                _buildStats(patients.length, vipCount),
              ],
            ),
          ),
          if (ctrl.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (patients.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _PatientCard(data: patients[i]),
                  childCount: patients.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF059669),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF047857), Color(0xFF10B981)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quản lý bệnh nhân',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Tìm kiếm và xem hồ sơ toàn bộ bệnh nhân',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Bệnh nhân', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
      leading: const BackButton(color: Colors.white),
    );
  }

  Widget _buildSearch() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, số điện thoại...',
          hintStyle: const TextStyle(color: Color(0xFFBFC8D4), fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchCtrl.clear();
                    _search('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF059669), width: 2)),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStats(int total, int vip) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _StatPill(label: 'Tổng', value: total.toString(), color: const Color(0xFF059669)),
          const SizedBox(width: 10),
          _StatPill(label: 'VIP', value: vip.toString(), color: const Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          _StatPill(label: 'Thường', value: (total - vip).toString(), color: const Color(0xFF6366F1)),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Không tìm thấy bệnh nhân', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12)),
        ],
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PatientCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? 'Bệnh nhân';
    final phone = data['phone'] as String? ?? '';
    final isVip = data['isVip'] == true;
    final totalVisits = data['totalVisits'] as int? ?? 0;
    final bloodType = data['bloodType'] as String? ?? '';
    final dept = data['departmentId'] as String? ?? '';
    final initials = name.isNotEmpty ? name.trim().split(' ').last.substring(0, 1).toUpperCase() : 'P';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isVip
                  ? const Color(0xFFFEF3C7)
                  : const Color(0xFF059669).withValues(alpha: 0.12),
              child: Text(initials, style: TextStyle(
                color: isVip ? const Color(0xFFF59E0B) : const Color(0xFF059669),
                fontWeight: FontWeight.w700,
                fontSize: 18,
              )),
            ),
            if (isVip)
              Positioned(
                right: -4, bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: const Color(0xFFF59E0B), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                  child: const Icon(Icons.star_rounded, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
            if (bloodType.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(bloodType, style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (phone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  const Icon(Icons.phone_rounded, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(phone, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ]),
              ),
            if (totalVisits > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(children: [
                  const Icon(Icons.history_rounded, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text('$totalVisits lần khám', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ]),
              ),
          ],
        ),
        trailing: isVip
            ? const Icon(Icons.chevron_right_rounded, color: Color(0xFFF59E0B))
            : const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
      ),
    );
  }
}
