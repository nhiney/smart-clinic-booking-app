import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/presentation/state/qr_checkin_controller.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/presentation/state/qr_checkin_state.dart';
import 'package:smart_clinic_booking/apps/qr_checkin_device/presentation/widgets/qr_scanner_overlay.dart';

class QRCheckInPage extends ConsumerStatefulWidget {
  const QRCheckInPage({super.key});

  @override
  ConsumerState<QRCheckInPage> createState() => _QRCheckInPageState();
}

class _QRCheckInPageState extends ConsumerState<QRCheckInPage> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe sự thay đổi trạng thái để hiển thị Dialog
    ref.listen<QRCheckInState>(qrCheckInControllerProvider, (previous, next) {
      if (next is QRCheckInSuccess) {
        _showSuccessDialog(context, next);
      } else if (next is QRCheckInFailure) {
        _showErrorDialog(context, next.message);
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  ref.read(qrCheckInControllerProvider.notifier).onQRCodeScanned(code);
                }
              }
            },
          ),

          // 2. Overlay
          const QRScannerOverlay(),

          // 3. Loading Indicator khi đang xử lý
          if (ref.watch(qrCheckInControllerProvider) is QRCheckInProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            
          // 4. Nút Back (Nếu cần)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 32),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, QRCheckInSuccess state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'CHECK-IN THÀNH CÔNG',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 32),
            Text(
              'Bệnh nhân: ${state.result.patientName}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'Bác sĩ: ${state.result.doctorName}',
              style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
            ),
            const SizedBox(height: 24),
            const Text('SỐ THỨ TỰ CỦA BẠN:', style: TextStyle(fontSize: 18)),
            Text(
              state.result.queueNumber,
              style: const TextStyle(
                fontSize: 100, 
                fontWeight: FontWeight.black, 
                color: Colors.blue
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(qrCheckInControllerProvider.notifier).reset();
              },
              child: const Text('XÁC NHẬN', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
    // Reset state sau khi hiển thị lỗi để có thể quét lại
    ref.read(qrCheckInControllerProvider.notifier).reset();
  }
}
