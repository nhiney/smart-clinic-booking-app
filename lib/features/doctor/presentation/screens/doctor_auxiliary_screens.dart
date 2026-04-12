import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extension.dart';

/// Giao diện tương ứng: tư vấn video (placeholder).
class DoctorVideoConsultScreen extends StatelessWidget {
  const DoctorVideoConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Tư vấn video'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Kết nối cuộc gọi video với bệnh nhân sẽ được tích hợp tại đây.',
            textAlign: TextAlign.center,
            style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Giao diện tương ứng: đánh giá từ bệnh nhân (placeholder).
class DoctorPatientRatingsScreen extends StatelessWidget {
  const DoctorPatientRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Đánh giá bệnh nhân'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _RatingTile(name: 'Nguyễn V. A.', stars: 5, comment: 'Bác sĩ tận tình, giải thích rõ.'),
          _RatingTile(name: 'Trần T. B.', stars: 4, comment: 'Lịch khám đúng giờ.'),
          _RatingTile(name: 'Lê C. D.', stars: 5, comment: 'Rất hài lòng.'),
        ],
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({required this.name, required this.stars, required this.comment});

  final String name;
  final int stars;
  final String comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: context.textStyles.bodyBold)),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment, style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
