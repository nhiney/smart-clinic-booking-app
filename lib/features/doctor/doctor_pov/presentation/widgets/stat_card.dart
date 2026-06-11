import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String changeText;
  final bool isPositive;
  final String subtitle;
  final List<num> sparklineData;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.changeText,
    required this.isPositive,
    required this.subtitle,
    required this.sparklineData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final accentBg = isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 6),
              Text(value,
                  style: context.textStyles.heading2.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 12,
                          color: accentColor,
                        ),
                        const SizedBox(width: 2),
                        Text(changeText,
                            style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary, fontSize: 11)),
              const SizedBox(height: 8),
              if (sparklineData.isNotEmpty)
                SizedBox(height: 30, child: _Sparkline(data: sparklineData, positive: isPositive)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<num> data;
  final bool positive;
  const _Sparkline({required this.data, required this.positive});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(
        data: data,
        color: positive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<num> data;
  final Color color;
  const _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minV = data.reduce((a, b) => a < b ? a : b).toDouble();
    final maxV = data.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (maxV - minV).abs();
    final normalise = range == 0 ? (v) => 0.5 : (num v) => (v.toDouble() - minV) / range;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - normalise(data[i]) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.data != data;
}
