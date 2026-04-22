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
    // Giả lập doctorId cho trạm Kiosk tại chi nhánh
    const doctorId = 'doctor_default_branch_a';
    final slotsAsync = ref.watch(availableSlotsProvider(doctorId));

    // Lắng nghe trạng thái thành công để chuyển màn hình xác nhận
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
        title: const Text('CHỌN GIỜ KHÁM', style: TextStyle(fontSize: 40, fontWeight: FontWeight.black)),
        toolbarHeight: 120,
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: slotsAsync.when(
        data: (slots) => GridView.builder(
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
            
            return KioskLargeButton(
              label: timeStr,
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VoiceRegistrationPage(selectedSlot: slot),
                  ),
                );
              },
            ).buildWithCustomStyle(context); // Custom method for white background theme
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 8)),
        error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(fontSize: 30))),
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
              const Text('ĐẶT KHÁM THÀNH CÔNG!', style: TextStyle(fontSize: 48, fontWeight: FontWeight.black)),
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
                  // ref.read(kioskControllerProvider.notifier).reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension to add a custom white style for the slot buttons
extension on KioskLargeButton {
  Widget buildWithCustomStyle(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade900,
          side: BorderSide(color: Colors.blue.shade900, width: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
