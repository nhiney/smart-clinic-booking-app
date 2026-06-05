import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/services/qr_token_service.dart';

/// Clinic check-in scanner used by the `scanner_device` role.
/// Scans a patient's booking QR, verifies its HMAC signature + validity window
/// with [QrTokenService], then marks the booking as checked-in.
class ClinicScannerScreen extends StatefulWidget {
  const ClinicScannerScreen({super.key});

  @override
  State<ClinicScannerScreen> createState() => _ClinicScannerScreenState();
}

class _ClinicScannerScreenState extends State<ClinicScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (raw == null || raw.isEmpty) return;

    setState(() => _processing = true);
    try {
      // 1) Verify signature + validity window (throws QrTokenException on failure).
      final payload = QrTokenService.verify(raw);
      final bookingId = payload['bid'] as String;

      // 2) Mark the booking checked-in atomically (reject double check-in).
      final ref = FirebaseFirestore.instance.collection('bookings').doc(bookingId);
      final result = await FirebaseFirestore.instance.runTransaction<String>((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) return 'not_found';
        if ((snap.data()?['status']) == 'checked_in') return 'already';
        tx.update(ref, {
          'status': 'checked_in',
          'checkedInAt': FieldValue.serverTimestamp(),
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });
        return 'ok';
      });

      if (!mounted) return;
      switch (result) {
        case 'ok':
          await _showResult(true, 'Check-in thành công', 'Mã đặt khám: $bookingId');
          break;
        case 'already':
          await _showResult(false, 'Đã check-in trước đó', 'Bệnh nhân này đã được check-in.');
          break;
        default:
          await _showResult(false, 'Không tìm thấy lịch hẹn', 'Mã đặt khám không tồn tại.');
      }
    } on QrTokenException catch (e) {
      if (mounted) await _showResult(false, 'Mã QR không hợp lệ', e.message);
    } catch (e) {
      if (mounted) await _showResult(false, 'Lỗi check-in', e.toString());
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _showResult(bool success, String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          color: success ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục quét'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in tại quầy')),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Scan frame guide.
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_processing)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  const Text(
                    'Đưa mã QR của bệnh nhân vào khung để check-in',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
