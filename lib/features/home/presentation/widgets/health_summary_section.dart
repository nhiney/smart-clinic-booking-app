import 'package:flutter/material.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/extensions/context_extension.dart';
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
              Expanded(
                child: Text(
                  'Sức khỏe của bạn',
                  style: context.textStyles.bodyBold.copyWith(fontSize: 18, color: context.colors.primaryDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Cập nhật ${_formatDate(summary.lastUpdated)}',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _MetricCard(
                metric: summary.heartRate,
                color: const Color(0xFFFF6B6B),
                icon: Icons.favorite_rounded,
                bgColor: const Color(0xFFFFF5F5),
              ),
              _MetricCard(
                metric: summary.bloodPressure,
                color: const Color(0xFF7B61FF),
                icon: Icons.monitor_heart_rounded,
                bgColor: const Color(0xFFF7F5FF),
              ),
              _MetricCard(
                metric: summary.bloodSugar,
                color: const Color(0xFFFFA41B),
                icon: Icons.water_drop_rounded,
                bgColor: const Color(0xFFFFFBF0),
              ),
              _MetricCard(
                metric: summary.bmi,
                color: const Color(0xFF00B8A9),
                icon: Icons.scale_rounded,
                bgColor: const Color(0xFFF0FBFA),
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
  final Color bgColor;
  final IconData icon;

  const _MetricCard({
    required this.metric,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.mRadius,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.05), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              _StatusIndicator(status: metric.status),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    metric.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: context.colors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    metric.unit,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                metric.label,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final HealthStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status) {
      case HealthStatus.normal:
        label = 'Ổn định';
        color = const Color(0xFF4CAF50);
      case HealthStatus.warning:
        label = 'Cảnh báo';
        color = const Color(0xFFFF9800);
      case HealthStatus.critical:
        label = 'Nguy hiểm';
        color = const Color(0xFFF44336);
      case HealthStatus.unknown:
        label = '--';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

