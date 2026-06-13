import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';
import '../controllers/admin_controller.dart';

class AdminNotificationBroadcastScreen extends StatefulWidget {
  const AdminNotificationBroadcastScreen({super.key});

  @override
  State<AdminNotificationBroadcastScreen> createState() => _AdminNotificationBroadcastScreenState();
}

class _AdminNotificationBroadcastScreenState extends State<AdminNotificationBroadcastScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _targetRole = 'all';
  final _formKey = GlobalKey<FormState>();

  static const _targets = [
    ('all', 'Tất cả', Icons.people_rounded),
    ('patient', 'Bệnh nhân', Icons.person_rounded),
    ('doctor', 'Bác sĩ', Icons.medical_services_rounded),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchBroadcastHistory();
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<AdminController>();
    final count = await ctrl.broadcastNotification(
      title: _titleCtrl.text.trim(),
      body: _bodyCtrl.text.trim(),
      targetRole: _targetRole,
    );
    if (!mounted) return;
    _titleCtrl.clear();
    _bodyCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi thông báo tới $count người dùng'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Đối tượng nhận',
                      child: _buildTargetSelector(),
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Nội dung thông báo',
                      child: Column(
                        children: [
                          _buildField(
                            controller: _titleCtrl,
                            label: 'Tiêu đề',
                            hint: 'Nhập tiêu đề thông báo...',
                            maxLines: 1,
                            icon: Icons.title_rounded,
                          ),
                          const SizedBox(height: 12),
                          _buildField(
                            controller: _bodyCtrl,
                            label: 'Nội dung',
                            hint: 'Nhập nội dung chi tiết...',
                            maxLines: 4,
                            icon: Icons.message_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildSendButton(ctrl),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Lịch sử gửi',
                      child: ctrl.broadcastHistory.isEmpty
                          ? _buildEmptyHistory()
                          : Column(
                              children: ctrl.broadcastHistory
                                  .map((h) => _BroadcastHistoryTile(data: h))
                                  .toList(),
                            ),
                    ),
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

  Widget _buildTargetSelector() {
    return Row(
      children: _targets.map((t) {
        final selected = _targetRole == t.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: t.$1 != 'doctor' ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _targetRole = t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? IColors.primary500 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? IColors.primary500 : const Color(0xFFE2E8F0),
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: IColors.primary500.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(t.$3, color: selected ? Colors.white : const Color(0xFF94A3B8), size: 22),
                    const SizedBox(height: 6),
                    Text(t.$2,
                        style: TextStyle(
                          color: selected ? Colors.white : const Color(0xFF64748B),
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập $label' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBFC8D4), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: IColors.primary500, width: 2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton(AdminController ctrl) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: ctrl.broadcastLoading ? null : _send,
        icon: ctrl.broadcastLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(ctrl.broadcastLoading ? 'Đang gửi...' : 'Gửi thông báo', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: IColors.primary500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text('Chưa có thông báo nào được gửi', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6366F1),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gửi thông báo',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Broadcast tin nhắn tới người dùng trong hệ thống',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      leading: const BackButton(color: Colors.white),
    );
  }
}

class _BroadcastHistoryTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _BroadcastHistoryTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '—';
    final body = data['body'] as String? ?? '';
    final count = data['recipientCount'] as int? ?? 0;
    final role = data['targetRole'] as String? ?? 'all';
    final rawTime = data['sentAt'];
    String timeStr = '';
    try {
      if (rawTime != null) {
        final dt = (rawTime as dynamic).toDate() as DateTime;
        timeStr = DateFormat('dd/MM/yyyy HH:mm').format(dt);
      }
    } catch (_) {}

    final roleLabel = role == 'patient' ? 'Bệnh nhân' : role == 'doctor' ? 'Bác sĩ' : 'Tất cả';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: const Border(left: BorderSide(color: Color(0xFF6366F1), width: 3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                if (body.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(body, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  ),
                const SizedBox(height: 4),
                Text(timeStr, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$count người', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF6366F1))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(roleLabel, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
