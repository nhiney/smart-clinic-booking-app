import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';
import '../riverpod/assistant_state.dart';

/// Bottom sheet shown after a booking intent is detected from voice.
/// Displays extracted info and lets the user proceed to the booking screen.
class VoiceBookingConfirmSheet extends StatefulWidget {
  const VoiceBookingConfirmSheet({
    super.key,
    required this.data,
    /// Called when the sheet is closed (either dismiss or confirm).
    required this.onClose,
  });

  final BookingIntentData data;
  final VoidCallback onClose;

  @override
  State<VoiceBookingConfirmSheet> createState() => _VoiceBookingConfirmSheetState();
}

class _VoiceBookingConfirmSheetState extends State<VoiceBookingConfirmSheet> {
  late final TextEditingController _symptomsCtrl;

  @override
  void initState() {
    super.initState();
    _symptomsCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _symptomsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: IColors.primary50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.mic_rounded, color: IColors.primary500, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xác nhận đặt lịch',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: IColors.ink,
                      ),
                    ),
                    Text(
                      'Thông tin được nhận dạng từ giọng nói',
                      style: TextStyle(fontSize: 12, color: IColors.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info cards
          _InfoRow(
            icon: Icons.medical_services_rounded,
            label: 'Chuyên khoa',
            value: widget.data.specialty ?? 'Chưa xác định',
            hasValue: widget.data.specialty != null,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Ngày khám',
            value: widget.data.date ?? 'Ngày mai',
            hasValue: true,
          ),
          if (widget.data.timeSlot != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Buổi khám',
              value: widget.data.timeSlot!,
              hasValue: true,
            ),
          ],

          const SizedBox(height: 16),

          // Symptoms input
          TextField(
            controller: _symptomsCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Mô tả triệu chứng (tùy chọn)...',
              hintStyle: const TextStyle(fontSize: 13, color: IColors.ink3),
              filled: true,
              fillColor: IColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClose();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: IColors.ink3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Nói lại',
                    style: TextStyle(color: IColors.ink2, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    // Capture router before popping to avoid invalid context.
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    widget.onClose();
                    router.push('/patient/create-appointment');
                  },
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text(
                    'Đặt lịch ngay',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: IColors.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hasValue ? IColors.primary50 : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue ? IColors.primary100 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: hasValue ? IColors.primary500 : Colors.orange.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: IColors.ink3),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasValue ? IColors.ink : Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          if (!hasValue)
            Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange.shade600),
        ],
      ),
    );
  }
}
