import 'package:flutter/material.dart';

class RevenueChartCard extends StatelessWidget {
  final double averageRevenue;

  const RevenueChartCard({super.key, required this.averageRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('XU HƯỚNG 6 THÁNG', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text('TB ', style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('đ', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('${averageRevenue.toInt()}M', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text(' / tháng', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(
                width: 90,
                height: 35,
                child: CustomPaint(painter: SmoothLinePainter()),
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['T12', 'T1', 'T2', 'T3', 'T4', 'T5'].map((month) {
              final isCurrent = month == 'T5';
              return Text(
                month,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

class SmoothLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(size.width * 0.25, size.height * 0.6, size.width * 0.4, size.height * 0.3, size.width * 0.6, size.height * 0.35)
      ..cubicTo(size.width * 0.75, size.height * 0.4, size.width * 0.85, size.height * 0.1, size.width, 0);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF2563EB).withOpacity(0.25), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}