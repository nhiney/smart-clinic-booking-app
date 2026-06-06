import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Cấp cứu SOS — nhấn giữ 3 giây để gọi 115 và gửi vị trí, kèm các nút gọi nhanh.
///
/// Route /sos. Nút gọi dùng url_launcher (tel:) nên quay số thật trên thiết bị.
class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _holdCtrl;
  Timer? _holdTimer;

  static const _bg = Color(0xFF1A0E12);
  static const _red = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _holdCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _holdCtrl.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  Future<void> _call(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể gọi $number trên thiết bị này.')),
      );
    }
  }

  void _startHold() {
    _holdCtrl.forward(from: 0);
    _holdTimer = Timer(const Duration(seconds: 3), () {
      _call('115');
    });
  }

  void _cancelHold() {
    _holdCtrl.reverse();
    _holdTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1)),
                  ),
                  const Spacer(),
                  const Icon(Icons.circle, color: _red, size: 10),
                  const SizedBox(width: 6),
                  const Text('CHẾ ĐỘ KHẨN CẤP',
                      style: TextStyle(
                          color: _red,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Bạn đang cần\ncấp cứu?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.15)),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Nhấn giữ nút bên dưới 3 giây để gọi cấp cứu 115 và gửi vị trí GPS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 28),
            _sosButton(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('GỌI NHANH',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ),
                  _quickCall(
                    color: _red,
                    initials: null,
                    icon: Icons.emergency_rounded,
                    title: 'Cấp cứu 115',
                    subtitle: 'Trung tâm cấp cứu quốc gia',
                    number: '115',
                  ),
                  const SizedBox(height: 10),
                  _quickCall(
                    color: const Color(0xFF3B82F6),
                    initials: 'MQ',
                    title: 'BS. Trần Minh Quân',
                    subtitle: 'Tim mạch · Bác sĩ của bạn',
                    number: '02838221234',
                  ),
                  const SizedBox(height: 10),
                  _quickCall(
                    color: const Color(0xFF10B981),
                    initials: 'K',
                    title: 'Liên hệ khẩn (Vợ)',
                    subtitle: 'Phạm Thu Hà · 0987 654 321',
                    number: '0987654321',
                  ),
                  const SizedBox(height: 12),
                  _healthChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sosButton() {
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _holdCtrl,
        builder: (_, __) {
          return SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withValues(alpha: 0.12),
                  ),
                ),
                Container(
                  width: 175,
                  height: 175,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withValues(alpha: 0.22),
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _holdCtrl.value,
                    strokeWidth: 5,
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEF5350), Color(0xFFC62828)],
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: _red.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 4),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('SOS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                      Text('NHẤN GIỮ 3S',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quickCall({
    required Color color,
    String? initials,
    IconData? icon,
    required String title,
    required String subtitle,
    required String number,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: icon != null
                ? Icon(icon, color: color, size: 22)
                : Center(
                    child: Text(initials ?? '',
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 15)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _call(number),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthChip() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFFF59E0B), size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Hồ sơ y tế khẩn: ',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'Nhóm máu O+ · THA độ 2 · Dị ứng Penicillin',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
