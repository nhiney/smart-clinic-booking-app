import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/booking/domain/entities/booking_entity.dart';

/// Displays a signed QR check-in code for a confirmed booking.
/// Shows appointment details, QR code, and a live countdown to expiry.
class AppointmentQrScreen extends StatefulWidget {
  final BookingEntity booking;

  const AppointmentQrScreen({super.key, required this.booking});

  @override
  State<AppointmentQrScreen> createState() => _AppointmentQrScreenState();
}

class _AppointmentQrScreenState extends State<AppointmentQrScreen> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    final exp = widget.booking.qrExpiresAt;
    if (exp == null) return;
    final diff = exp.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  bool get _isExpired => _remaining == Duration.zero;

  bool get _isNotYetValid {
    final nbf = widget.booking.qrValidFrom;
    if (nbf == null) return false;
    return DateTime.now().isBefore(nbf);
  }

  String get _countdownText {
    if (_isExpired) return 'Mã QR đã hết hạn';
    if (_isNotYetValid) {
      final diff = widget.booking.qrValidFrom!.difference(DateTime.now());
      return 'Có hiệu lực sau ${_fmt(diff)}';
    }
    return 'Hết hạn sau ${_fmt(_remaining)}';
  }

  Color get _countdownColor {
    if (_isExpired) return Colors.red;
    if (_isNotYetValid) return Colors.orange;
    if (_remaining.inMinutes < 10) return Colors.orange;
    return AppColors.primary;
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h}h ${m}m';
    return '$m:$s';
  }

  String _fmtDate(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year}';
  }

  String _fmtTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final token = widget.booking.checkInToken ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(
        title: 'Mã QR Check-in',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildQrCard(token),
            const SizedBox(height: 20),
            _buildHintCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final apptDate = widget.booking.qrValidFrom != null
        ? _fmtDate(widget.booking.date)
        : _fmtDate(widget.booking.date);
    final apptTime = widget.booking.timeSlot;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin lịch khám',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$apptDate  •  $apptTime',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _infoRow(Icons.person_outline_rounded, 'Khoa / chuyên khoa',
              widget.booking.specialty),
          const SizedBox(height: 8),
          _infoRow(Icons.bookmark_border_rounded, 'Mã đặt lịch',
              widget.booking.id),
          if (widget.booking.qrValidFrom != null &&
              widget.booking.qrExpiresAt != null) ...[
            const SizedBox(height: 8),
            _infoRow(
              Icons.access_time_rounded,
              'Thời gian check-in hợp lệ',
              '${_fmtTime(widget.booking.qrValidFrom!)} – ${_fmtTime(widget.booking.qrExpiresAt!)}  '
                  '${_fmtDate(widget.booking.qrValidFrom!)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8))),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQrCard(String token) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (token.isEmpty || _isExpired)
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isExpired
                        ? Icons.qr_code_2_rounded
                        : Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isExpired
                        ? 'Mã QR đã hết hạn'
                        : 'Không có mã QR',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          else
            QrImageView(
              data: token,
              version: QrVersions.auto,
              size: 250,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF0D47A1),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: Color(0xFF1565C0),
              ),
            ),
          const SizedBox(height: 20),
          // Countdown pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: _countdownColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 16, color: _countdownColor),
                const SizedBox(width: 6),
                Text(
                  _countdownText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _countdownColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quét tại quầy check-in bệnh viện',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mã QR được ký bảo mật bằng HMAC-SHA256. Chỉ cần trình mã này tại quầy check-in — không cần in giấy hay mang theo CCCD.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
