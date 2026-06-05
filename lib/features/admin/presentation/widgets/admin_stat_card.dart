// lib/features/admin/presentation/widgets/admin_stat_card.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final dynamic item; // Nhận StatItemEntity từ tầng Domain
  final IconData icon;
  final Color color;
  final bool isCompact;
  final bool isCurrency;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.item,
    required this.icon,
    required this.color,
    this.isCompact = false,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logic định dạng hiển thị số liệu động giống hệt thiết kế mẫu
    String displayValue = "";
    if (isCurrency) {
      // Định dạng doanh thu: ví dụ 648000000 -> đ648M
      double millions = item.value / 1000000;
      displayValue = "đ${millions.toInt()}M";
    } else if (isCompact && item.value >= 1000) {
      // Định dạng rút gọn nghìn: ví dụ 4200 -> 4.2K
      double thousands = item.value / 1000;
      displayValue = "${thousands.toStringAsFixed(1)}K";
    } else {
      displayValue = item.value.toInt().toString();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Bo tròn góc mềm mại tinh tế
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng đầu tiên: Tiêu đề chữ mờ bên trái - Icon màu bên phải tách biệt rõ ràng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: color.withOpacity(0.8), size: 18),
            ],
          ),
          const SizedBox(height: 8),
          // Hàng thứ hai: Số liệu hiển thị to rõ rệt, đậm nét phong cách tối giản
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(), // Đẩy phần biểu đồ và phần trăm xuống nửa dưới đồng đều
          // Hàng cuối cùng: Tag phần trăm và biểu đồ Sparkline mini uốn lượn
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Tag tăng trưởng nền mờ nhạt
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_drop_up, color: color, size: 14),
                    Text(
                      '+${item.absoluteChange.toInt()}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Vùng vẽ biểu đồ mini gợn sóng vuốt nhọn ở đuôi
              Expanded(
                child: SizedBox(
                  height: 25, // Chiều cao vừa vặn cho sóng nhỏ mượt mà
                  child: LineChart(_getSparklineConfig(item.chartData)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Cấu hình toán học giúp đường cong fl_chart uốn lượn mượt mà tuyệt đối
  LineChartData _getSparklineConfig(List<double> data) {
    List<double> chartValues = List.from(data);
    // Nếu mảng trống hoặc toàn số 0, tạo một đường thẳng nhẹ ở giữa để giữ thẩm mỹ
    if (chartValues.isEmpty || chartValues.every((v) => v == 0)) {
      chartValues = [1, 1, 1, 1, 1, 1, 1];
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (chartValues.length - 1).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: chartValues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
          isCurved: true, // Bật chế độ vẽ cong mềm mại thay vì gấp khúc bẻ gãy
          curveSmoothness: 0.4,
          color: color, // Màu sắc đồng bộ theo từng loại Card
          barWidth: 2.0,
          dotData: const FlDotData(show: false), // Khóa các chấm vuông thô
          belowBarData: BarAreaData(show: false), // Không đổ màu nền phía dưới để giữ sự thanh mảnh
        ),
      ],
    );
  }
}