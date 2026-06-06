import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../patient_pov/presentation/controllers/doctor_controller.dart';
import '../../../patient_pov/domain/entities/doctor_workspace_models.dart';

class DoctorScheduleSettingsScreen extends StatefulWidget {
  const DoctorScheduleSettingsScreen({super.key});

  @override
  State<DoctorScheduleSettingsScreen> createState() => _State();
}

class _State extends State<DoctorScheduleSettingsScreen> {
  Future<void> _save() async {
    await context.read<DoctorController>().saveWorkSchedule();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu lịch làm việc'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DoctorController>();
    final days = ctrl.workDays;
    final activeDays = days.where((d) => d.enabled).length;
    final totalSlots = days.fold<int>(0, (s, d) => s + d.slots.length);
    final totalHours = totalSlots * 3.5; // rough: each slot ~3.5h

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        title: const Text('Lịch làm việc', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF0F172A))),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Lưu', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title
          const Text('Khung giờ của tôi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              children: [
                TextSpan(text: 'Cài đặt khung giờ bệnh nhân có thể đặt khám. Áp dụng từ '),
                TextSpan(text: 'tuần này', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _StatPill(value: '$activeDays', label: 'Ngày/tuần', color: const Color(0xFF1D4ED8)),
              const SizedBox(width: 10),
              _StatPill(value: '$totalSlots', label: 'Khung giờ', color: const Color(0xFF059669)),
              const SizedBox(width: 10),
              _StatPill(value: '${totalHours.toStringAsFixed(0)}h', label: 'Tổng giờ', color: const Color(0xFF7C3AED)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Theo ngày trong tuần', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('Nhấn ngày để chỉnh sửa', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          const SizedBox(height: 12),
          ...days.asMap().entries.map((e) => _DayCard(
            day: e.value,
            index: e.key,
            onToggle: () => ctrl.toggleWorkDay(e.key),
            onAddSlot: () => _showAddSlot(ctrl, e.key),
            onRemoveSlot: (id) => ctrl.removeWorkSlot(e.key, id),
          )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddSlot(DoctorController ctrl, int dayIndex) {
    final labelCtrl = TextEditingController(text: '08:00–11:30');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thêm ca làm việc', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: labelCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Giờ làm việc (vd: 08:00–11:30)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: const Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1D4ED8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  final label = labelCtrl.text.trim();
                  if (label.isNotEmpty) ctrl.addWorkSlot(dayIndex, label, 'Khung giờ làm việc');
                  Navigator.pop(ctx);
                },
                child: const Text('Thêm ca', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DoctorWorkDay day;
  final int index;
  final VoidCallback onToggle, onAddSlot;
  final void Function(String) onRemoveSlot;
  const _DayCard({required this.day, required this.index, required this.onToggle, required this.onAddSlot, required this.onRemoveSlot});

  @override
  Widget build(BuildContext context) {
    final slotCount = day.slots.length;
    final slotDesc = slotCount > 0 ? '$slotCount ca · ${slotCount * 7} slot 30 phút' : 'Chưa có ca';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.dayLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                      Text(slotDesc, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
                Switch(
                  value: day.enabled,
                  onChanged: (_) => onToggle(),
                  activeColor: const Color(0xFF1D4ED8),
                  trackColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected) ? const Color(0xFF1D4ED8).withValues(alpha: 0.25) : const Color(0xFFE2E8F0)),
                ),
              ],
            ),
            if (day.enabled) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  ...day.slots.map((slot) => _SlotChip(label: slot.label, onRemove: () => onRemoveSlot(slot.id))),
                  _AddSlotChip(onTap: onAddSlot),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _SlotChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1D4ED8))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64A0FF)),
          ),
        ],
      ),
    );
  }
}

class _AddSlotChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSlotChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 14, color: Color(0xFF94A3B8)),
            SizedBox(width: 4),
            Text('Thêm ca', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
