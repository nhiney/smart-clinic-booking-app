import 'package:flutter/material.dart';

class RevenueChartCard extends StatelessWidget {
  final List<double> chartData;

  const RevenueChartCard({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    // Tự động tính toán điểm trung bình động thực tế từ mảng số liệu thô Firebase
    double sum = 0;
    for (var val in chartData) {
      sum += val;
    }
    final double avgValue = chartData.isNotEmpty ? (sum / chartData.length) : 0.0;

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
          const Text('XU HƯỚNG THEO KỲ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
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
                  Text('${avgValue.toStringAsFixed(0)}M', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text(' / mốc', style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              // Nạp mảng dữ liệu mạng vào CustomPainter vẽ vector hình học phẳng
              SizedBox(
                width: 90,
                height: 35,
                child: CustomPaint(painter: SmoothLinePainter(chartData: chartData)),
              )
            ],
          ),
          const SizedBox(height: 24),
          
          // Trục hoành hiển thị số lượng mốc tương thích theo biến động phần tử của database
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(chartData.isNotEmpty ? chartData.length : 6, (index) {
              final isLast = index == (chartData.isNotEmpty ? chartData.length - 1 : 5);
              return Text(
                'Mốc ${index + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                  color: isLast ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

class SmoothLinePainter extends CustomPainter {
  final List<double> chartData;

  SmoothLinePainter({required this.chartData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (chartData.length < 2) {
      // Trạng thái phòng vệ nếu mảng trống: Vẽ một đường ngang phẳng mờ
      path.moveTo(0, size.height * 0.7);
      path.lineTo(size.width, size.height * 0.7);
    } else {
      // 🌟 OOP VECTOR ĐỘNG: Định hình biên độ co giãn đồ thị theo mốc lớn nhất
      double maxVal = chartData.reduce((a, b) => a > b ? a : b);
      if (maxVal == 0) maxVal = 1.0;
      
      final double stepX = size.width / (chartData.length - 1);
      
      // Điểm neo khởi hành (Mốc số 1)
      path.moveTo(0, size.height - (chartData[0] / maxVal * size.height * 0.8));
      
      // Tính toán uốn lượn đường cong liên tục dựa theo thuật toán Cubic Bézier
      for (int i = 0; i < chartData.length - 1; i++) {
        final double x1 = i * stepX;
        final double y1 = size.height - (chartData[i] / maxVal * size.height * 0.8);
        final double x2 = (i + 1) * stepX;
        final double y2 = size.height - (chartData[i + 1] / maxVal * size.height * 0.8);
        
        path.cubicTo((x1 + x2) / 2, y1, (x1 + x2) / 2, y2, x2, y2);
      }
    }

    // Phủ vùng màu Gradient trong suốt phía dưới đường cong đồ thị mẫu
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
  bool shouldRepaint(covariant SmoothLinePainter oldDelegate) {
    return oldDelegate.chartData != chartData;
  }
}