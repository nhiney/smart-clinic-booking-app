import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/state/kiosk_controller.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/state/kiosk_state.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/presentation/widgets/kiosk_large_button.dart';
import 'voice_registration_page.dart';

class SlotSelectionPage extends ConsumerWidget {
  const SlotSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const doctorId = 'doctor_default_branch_a';
    final slotsAsync = ref.watch(availableSlotsProvider(doctorId));

    ref.listen<KioskState>(kioskControllerProvider, (previous, next) {
      if (next is KioskBookingSuccess) {
        _showSuccessDialog(context, next.bookingId);
      } else if (next is KioskError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('CHỌN GIỜ KHÁM', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
        toolbarHeight: 120,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: slotsAsync.when(
        data: (slots) {
          if (slots.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 100, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  const Text(
                    'HIỆN TẠI KHÔNG CÓ GIỜ KHÁM NÀO TRỐNG',
                    style: TextStyle(fontSize: 30, color: Colors.grey, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(32),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 32,
              mainAxisSpacing: 32,
            ),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final timeStr = DateFormat('HH:mm').format(slot.startTime);
              
              return SizedBox(
                height: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade900,
                    side: BorderSide(color: Colors.blue.shade900, width: 3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VoiceRegistrationPage(selectedSlot: slot),
                      ),
                    );
                  },
                  child: Text(
                    timeStr,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 8)),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'LỖI KẾT NỐI: $err\n\nVui lòng kiểm tra lại Rules hoặc Internet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        content: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 150),
              const SizedBox(height: 30),
              const Text('ĐẶT KHÁM THÀNH CÔNG!', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Text('Mã lịch hẹn của bạn: $bookingId', style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 40),
              const Text(
                'Vui lòng nhận phiếu tại máy in bên dưới và chờ gọi tên.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              KioskLargeButton(
                label: 'HOÀN TẤT',
                color: Colors.green,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
