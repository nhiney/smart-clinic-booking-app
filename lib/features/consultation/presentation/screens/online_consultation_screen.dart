import 'dart:async';
import 'package:flutter/material.dart';

/// Khám trực tuyến — màn gọi video/điện thoại với bác sĩ, kèm AI ghi chú tự động.
///
/// Truy cập từ trang chủ (quick action "Khám trực tuyến") hoặc route /consultation.
/// Dữ liệu hội thoại là demo theo thiết kế; phần video là placeholder.
class OnlineConsultationScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;

  const OnlineConsultationScreen({
    super.key,
    this.doctorName = 'BS. Trần Minh Quân',
    this.specialty = 'Tim mạch',
  });

  @override
  State<OnlineConsultationScreen> createState() =>
      _OnlineConsultationScreenState();
}

class _OnlineConsultationScreenState extends State<OnlineConsultationScreen> {
  bool _micOn = false;
  bool _camOn = true;
  bool _speakerOn = true;
  bool _showNotes = true;
  bool _recording = true;
  Duration _elapsed = const Duration(minutes: 14, seconds: 23);
  Timer? _timer;

  static const _bg = Color(0xFF0B1A2A);
  static const _panel = Color(0xFF14283D);
  static const _accent = Color(0xFF3B82F6);
  static const _danger = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _elapsedStr {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _endCall() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kết thúc cuộc gọi?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'Bản ghi và ghi chú AI sẽ được lưu vào hồ sơ bệnh án của bạn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).maybePop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _danger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Stack(
                children: [
                  // Vùng video bác sĩ (placeholder)
                  const Positioned.fill(child: _VideoPlaceholder()),
                  // AI ghi chú
                  if (_showNotes)
                    Positioned(
                      left: 16,
                      right: 120,
                      top: 16,
                      child: _aiNotes(),
                    ),
                  // Self view
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _selfView(),
                  ),
                  // Hành động phụ
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: _secondaryActions(),
                  ),
                ],
              ),
            ),
            _controlBar(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _accent.withValues(alpha: 0.25),
            child: const Text('QT',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    const Icon(Icons.videocam_rounded,
                        color: Colors.white54, size: 13),
                    const SizedBox(width: 4),
                    Text('$_elapsedStr · HD',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          if (_recording)
            GestureDetector(
              onTap: () => setState(() => _recording = false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _danger,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                    SizedBox(width: 5),
                    Text('REC',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _aiNotes() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF34D399), size: 8),
              const SizedBox(width: 6),
              const Text('AI GHI CHÚ TỰ ĐỘNG',
                  style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _showNotes = false),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white38, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _noteLine('BS', 'Anh đau ngực thế nào? Có lan ra cánh tay không?'),
          const SizedBox(height: 8),
          _noteLine('BN', 'Tức nặng, lan ra tay trái khi leo cầu thang. Đỡ khi nghỉ.'),
          const SizedBox(height: 8),
          _noteLine('BS', 'Đó là dấu hiệu đau thắt ngực điển hình. Tôi sẽ kê thuốc...'),
        ],
      ),
    );
  }

  Widget _noteLine(String who, String text) {
    final isDoctor = who == 'BS';
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$who: ',
            style: TextStyle(
              color: isDoctor ? _accent : const Color(0xFF34D399),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: text,
            style: const TextStyle(
                color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _selfView() {
    return Container(
      width: 96,
      height: 130,
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(_camOn ? Icons.person_rounded : Icons.videocam_off_rounded,
              color: Colors.white24, size: 40),
          Positioned(
            bottom: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _micOn ? _accent : _danger,
                shape: BoxShape.circle,
              ),
              child: Icon(_micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                  color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secondaryActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _chip(Icons.favorite_border_rounded, 'Chia sẻ ECG'),
        const SizedBox(width: 10),
        _chip(Icons.crop_rounded, 'Chụp ảnh'),
        const SizedBox(width: 10),
        _chip(Icons.sticky_note_2_outlined, 'Ghi chú'),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(label), duration: const Duration(seconds: 1)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _panel.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _controlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ctrl(_micOn ? Icons.mic_rounded : Icons.mic_off_rounded, 'Mic',
              active: _micOn, onTap: () => setState(() => _micOn = !_micOn)),
          _ctrl(_camOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
              'Cam',
              active: _camOn, onTap: () => setState(() => _camOn = !_camOn)),
          _ctrl(Icons.cameraswitch_rounded, 'Đổi', onTap: () {}),
          _ctrl(_speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              'Loa',
              active: _speakerOn,
              onTap: () => setState(() => _speakerOn = !_speakerOn)),
          _ctrl(Icons.call_end_rounded, 'Kết thúc',
              danger: true, onTap: _endCall),
        ],
      ),
    );
  }

  Widget _ctrl(IconData icon, String label,
      {bool active = false, bool danger = false, VoidCallback? onTap}) {
    final Color bg = danger
        ? _danger
        : active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.12);
    final Color fg = danger
        ? Colors.white
        : active
            ? _bg
            : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: fg, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF13293D), Color(0xFF0B1A2A)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white24, size: 60),
            ),
            const SizedBox(height: 16),
            const Text('Đang kết nối video...',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
