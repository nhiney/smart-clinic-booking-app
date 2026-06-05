import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/icare_tokens.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Admin KYC Approval Screen — review, approve or reject doctor applications
// submitted from [KycUploadScreen] (collection: doctor_applications).
// ═══════════════════════════════════════════════════════════════════════════

class KycApprovalScreen extends StatefulWidget {
  const KycApprovalScreen({super.key});

  @override
  State<KycApprovalScreen> createState() => _KycApprovalScreenState();
}

class _KycApprovalScreenState extends State<KycApprovalScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = ['pending', 'approved', 'rejected'];
  static const _tabLabels = ['Chờ duyệt', 'Đã duyệt', 'Từ chối'];

  final _processing = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  CollectionReference<Map<String, dynamic>> get _applications =>
      FirebaseFirestore.instance.collection('doctor_applications');

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _approve(String appId, Map<String, dynamic> data) async {
    final doctorUid = (data['doctorUid'] as String?) ?? '';
    setState(() => _processing.add(appId));
    try {
      final db = FirebaseFirestore.instance;
      final batch = db.batch();

      batch.update(_applications.doc(appId), {
        'status': 'approved',
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': FirebaseAuth.instance.currentUser?.uid,
      });

      // Promote the applicant's user record to an active doctor account.
      if (doctorUid.isNotEmpty) {
        batch.set(
          db.collection('users').doc(doctorUid),
          {
            'role': 'doctor',
            'status': 'active',
            'is_verified': true,
            'specialty': data['specialty'],
            'medical_cert_url': data['licenceNumber'],
            'updated_at': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      _toast('Đã phê duyệt hồ sơ của ${data['fullName'] ?? 'bác sĩ'}', IColors.success);
    } catch (e) {
      _toast('Lỗi phê duyệt: $e', IColors.danger);
    } finally {
      if (mounted) setState(() => _processing.remove(appId));
    }
  }

  Future<void> _reject(String appId, Map<String, dynamic> data) async {
    final reason = await _askRejectReason();
    if (reason == null) return; // cancelled

    setState(() => _processing.add(appId));
    try {
      await _applications.doc(appId).update({
        'status': 'rejected',
        'rejectReason': reason,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      _toast('Đã từ chối hồ sơ của ${data['fullName'] ?? 'bác sĩ'}', IColors.ink2);
    } catch (e) {
      _toast('Lỗi từ chối: $e', IColors.danger);
    } finally {
      if (mounted) setState(() => _processing.remove(appId));
    }
  }

  Future<String?> _askRejectReason() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối hồ sơ'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Lý do từ chối (không bắt buộc)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: IColors.danger),
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.bg,
      appBar: AppBar(
        backgroundColor: IColors.surface,
        foregroundColor: IColors.ink,
        elevation: 0,
        title: const Text('Duyệt hồ sơ bác sĩ'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: IColors.primary500,
          unselectedLabelColor: IColors.ink3,
          indicatorColor: IColors.primary500,
          tabs: [for (final l in _tabLabels) Tab(text: l)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [for (final s in _tabs) _buildList(s)],
      ),
    );
  }

  Widget _buildList(String status) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _applications
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _emptyState(
            Icons.error_outline_rounded,
            'Không tải được danh sách',
            '${snapshot.error}',
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        // Sort newest-first client-side to avoid requiring a composite index.
        docs.sort((a, b) {
          final ta = a.data()['submittedAt'];
          final tb = b.data()['submittedAt'];
          if (ta is Timestamp && tb is Timestamp) return tb.compareTo(ta);
          return 0;
        });

        if (docs.isEmpty) {
          return _emptyState(
            Icons.inbox_rounded,
            'Không có hồ sơ',
            status == 'pending'
                ? 'Chưa có hồ sơ nào chờ duyệt.'
                : 'Danh sách trống.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _applicationCard(docs[i].id, docs[i].data(), status),
        );
      },
    );
  }

  Widget _applicationCard(
      String appId, Map<String, dynamic> data, String status) {
    final busy = _processing.contains(appId);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IColors.line),
        boxShadow: IColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: IColors.primary50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services_outlined,
                  color: IColors.primary500, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['fullName'] as String?) ?? 'Không rõ tên',
                    style: IText.body(
                        size: 15, weight: FontWeight.w700, color: IColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    (data['specialty'] as String?) ?? '—',
                    style: IText.body(size: 12.5, color: IColors.primary500),
                  ),
                ],
              ),
            ),
            _statusBadge(status),
          ]),
          const SizedBox(height: 14),
          _detailRow(Icons.badge_outlined, 'Số CCHN',
              (data['licenceNumber'] as String?) ?? '—'),
          const SizedBox(height: 8),
          _detailRow(Icons.local_hospital_outlined, 'Cơ sở y tế',
              (data['hospital'] as String?) ?? '—'),
          if (status == 'rejected' &&
              (data['rejectReason'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _detailRow(Icons.notes_rounded, 'Lý do', data['rejectReason']),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : () => _reject(appId, data),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: IColors.danger,
                    side: const BorderSide(color: IColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : () => _approve(appId, data),
                  style: FilledButton.styleFrom(
                    backgroundColor: IColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Phê duyệt'),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    late Color bg, fg;
    late String label;
    switch (status) {
      case 'approved':
        bg = IColors.successBg;
        fg = IColors.success;
        label = 'Đã duyệt';
        break;
      case 'rejected':
        bg = IColors.danger.withValues(alpha: 0.12);
        fg = IColors.danger;
        label = 'Từ chối';
        break;
      default:
        bg = IColors.warningBg;
        fg = IColors.warning;
        label = 'Chờ duyệt';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: IText.label(size: 10.5, color: fg)),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 16, color: IColors.ink3),
      const SizedBox(width: 8),
      Text('$label: ',
          style: IText.body(size: 13, color: IColors.ink3)),
      Expanded(
        child: Text(value,
            style: IText.body(
                size: 13, weight: FontWeight.w600, color: IColors.ink2)),
      ),
    ]);
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: IColors.ink200),
            const SizedBox(height: 16),
            Text(title,
                style: IText.display(size: 18, color: IColors.ink2),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: IText.body(size: 13, color: IColors.ink3),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
