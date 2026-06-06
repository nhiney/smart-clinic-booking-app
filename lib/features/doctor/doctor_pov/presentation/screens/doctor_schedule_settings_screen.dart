import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';
import '../../../patient_pov/domain/entities/doctor_workspace_models.dart';

class DoctorScheduleSettingsScreen extends StatefulWidget {
  const DoctorScheduleSettingsScreen({super.key});

  @override
  State<DoctorScheduleSettingsScreen> createState() => _DoctorScheduleSettingsScreenState();
}

class _DoctorScheduleSettingsScreenState extends State<DoctorScheduleSettingsScreen> {
  static const _accent = Color(0xFF0891B2);

  Future<void> _save() async {
    final ctrl = context.read<DoctorController>();
    await ctrl.saveWorkSchedule();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu lịch làm việc'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final days = ctrl.workDays;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildLegend(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _DayCard(
                  day: days[i],
                  dayIndex: i,
                  accent: _accent,
                  onToggle: () => ctrl.toggleWorkDay(i),
                  onAddSlot: () => _showAddSlotDialog(context, ctrl, i),
                  onRemoveSlot: (slotId) => ctrl.removeWorkSlot(i, slotId),
                ),
                childCount: days.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ctrl.isLoading ? null : _save,
        backgroundColor: _accent,
        icon: ctrl.isLoading
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text('Lưu lịch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showAddSlotDialog(BuildContext context, DoctorController ctrl, int dayIndex) {
    final labelCtrl = TextEditingController();
    final rangeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thêm khung giờ', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: InputDecoration(
                labelText: 'Giờ (vd: 08:00–11:30)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rangeCtrl,
              decoration: InputDecoration(
                labelText: 'Mô tả (vd: 4 slot 30 phút)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _accent, foregroundColor: Colors.white),
            onPressed: () {
              final label = labelCtrl.text.trim();
              final range = rangeCtrl.text.trim();
              if (label.isNotEmpty) {
                ctrl.addWorkSlot(dayIndex, label, range.isNotEmpty ? range : 'Khung giờ làm việc');
              }
              Navigator.pop(ctx);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      backgroundColor: _accent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E7490), Color(0xFF06B6D4)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cài đặt lịch làm việc', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Bật/tắt ngày và thêm khung giờ khám', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        title: const Text('Cài đặt lịch', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        collapseMode: CollapseMode.pin,
      ),
      leading: const BackButton(color: Colors.white),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: _accent),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Bật/tắt từng ngày và thêm các khung giờ khám cụ thể. Nhấn "Lưu lịch" để áp dụng.',
                style: TextStyle(fontSize: 12, color: Color(0xFF0E7490))),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DoctorWorkDay day;
  final int dayIndex;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onAddSlot;
  final void Function(String slotId) onRemoveSlot;

  const _DayCard({
    required this.day,
    required this.dayIndex,
    required this.accent,
    required this.onToggle,
    required this.onAddSlot,
    required this.onRemoveSlot,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: day.enabled ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: day.enabled ? accent.withValues(alpha: 0.25) : const Color(0xFFE2E8F0)),
        boxShadow: day.enabled ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))] : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: day.enabled ? accent.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today_rounded, size: 18, color: day.enabled ? accent : const Color(0xFF94A3B8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.dayLabel, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: day.enabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8))),
                      Text('${day.slots.length} khung giờ', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: day.enabled,
                  onChanged: (_) => onToggle(),
                  activeColor: accent,
                ),
              ],
            ),
          ),
          if (day.enabled) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ...day.slots.map((slot) => _SlotTile(slot: slot, accent: accent, onDelete: () => onRemoveSlot(slot.id))),
            InkWell(
              onTap: onAddSlot,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 18, color: accent),
                    const SizedBox(width: 6),
                    Text('Thêm khung giờ', style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final DoctorWorkSlot slot;
  final Color accent;
  final VoidCallback onDelete;
  const _SlotTile({required this.slot, required this.accent, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(slot.label, style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(slot.timeRange, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.redAccent),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
