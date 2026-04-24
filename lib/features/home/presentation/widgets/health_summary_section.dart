import 'package:flutter/material.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../domain/entities/health_summary.dart';

/// Section 5: Health Summary — 4 metric cards in a 2x2 grid.
class HealthSummarySection extends StatelessWidget {
  final HealthSummary summary;

  const HealthSummarySection({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: Text('Sức khỏe của bạn', style: AppTextStyles.heading3)),
              Text(
                'Cập nhật ${_formatDate(summary.lastUpdated)}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _MetricCard(
                metric: summary.heartRate,
                color: const Color(0xFFFF6B6B),
                icon: Icons.favorite_rounded,
              ),
              _MetricCard(
                metric: summary.bloodPressure,
                color: const Color(0xFF7B61FF),
                icon: Icons.monitor_heart_rounded,
              ),
              _MetricCard(
                metric: summary.bloodSugar,
                color: const Color(0xFFFFA41B),
                icon: Icons.water_drop_rounded,
              ),
              _MetricCard(
                metric: summary.bmi,
                color: const Color(0xFF00B8A9),
                icon: Icons.scale_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}p trước';
    if (diff.inHours < 24) return '${diff.inHours}h trước';
    return '${diff.inDays}d trước';
  }
}

class _MetricCard extends StatelessWidget {
  final HealthMetric metric;
  final Color color;
  final IconData icon;

  const _MetricCard({required this.metric, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              _StatusDot(status: metric.status),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: metric.value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    TextSpan(
                      text: ' ${metric.unit}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(metric.label, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final HealthStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    switch (status) {
      case HealthStatus.normal:
        dotColor = AppColors.success;
      case HealthStatus.warning:
        dotColor = AppColors.warning;
      case HealthStatus.critical:
        dotColor = AppColors.error;
      case HealthStatus.unknown:
        dotColor = AppColors.textHint;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }
}
