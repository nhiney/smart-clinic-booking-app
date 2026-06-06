import 'package:flutter/material.dart';

class _C {
  static const primary = Color(0xFF1D4ED8);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const gold = Color(0xFFF59E0B);
}

/// Đánh giá bác sĩ — chọn sao, tag ấn tượng, nhận xét và gửi.
/// Route /rate-doctor.
class RateDoctorScreen extends StatefulWidget {
  final String doctorName;
  final String specialty;
  final String dateTime;

  const RateDoctorScreen({
    super.key,
    this.doctorName = 'BS. Trần Minh Quân',
    this.specialty = 'Tim mạch',
    this.dateTime = '23/05/2026 · 09:30',
  });

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  int _stars = 5;
  final _commentCtrl = TextEditingController();
  final Set<String> _selectedTags = {'Tận tâm', 'Chẩn đoán chính xác', 'Giải thích kỹ'};

  static const _tags = [
    'Tận tâm',
    'Chẩn đoán chính xác',
    'Giải thích kỹ',
    'Đúng giờ',
    'Phòng khám sạch',
    'Giá hợp lý',
  ];

  static const _labels = ['', 'Tệ', 'Chưa tốt', 'Bình thường', 'Tốt', 'Tuyệt vời!'];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.favorite_rounded, color: _C.gold, size: 44),
        title: const Text('Cảm ơn bạn!',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Đánh giá $_stars sao của bạn đã được gửi tới ${widget.doctorName}.',
            textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).maybePop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary, foregroundColor: Colors.white),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Đánh giá',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Bỏ qua',
                style: TextStyle(color: _C.textSecondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _C.primary.withValues(alpha: 0.15),
                  child: const Text('QT',
                      style: TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22)),
                ),
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: Color(0xFF10B981),
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Center(
            child: Text('Bạn vừa khám xong với',
                style: TextStyle(color: _C.textSecondary, fontSize: 13)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(widget.doctorName,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _C.textPrimary)),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text('${widget.specialty} · ${widget.dateTime}',
                style: const TextStyle(color: _C.textSecondary, fontSize: 13)),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text('Trải nghiệm khám của\nbạn thế nào?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _C.textPrimary,
                    height: 1.2)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _stars;
              return GestureDetector(
                onTap: () => setState(() => _stars = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedScale(
                    scale: filled ? 1.0 : 0.85,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled ? _C.gold : _C.border,
                      size: 44,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(_labels[_stars],
                style: const TextStyle(
                    color: _C.gold, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Điều gì bạn ấn tượng nhất?',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.textSecondary)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _tags.map((t) {
              final sel = _selectedTags.contains(t);
              return GestureDetector(
                onTap: () => setState(() {
                  if (!_selectedTags.add(t)) _selectedTags.remove(t);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? _C.primary : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: sel ? _C.primary : _C.border, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel) ...[
                        const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                      ],
                      Text(t,
                          style: TextStyle(
                              color: sel ? Colors.white : _C.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Chia sẻ thêm về trải nghiệm của bạn (không bắt buộc)...',
              hintStyle: const TextStyle(color: _C.textSecondary, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _C.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Gửi đánh giá',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
