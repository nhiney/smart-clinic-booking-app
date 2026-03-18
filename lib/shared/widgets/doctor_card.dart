import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final String hospital;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    this.imageUrl = '',
    this.rating = 0.0,
    this.hospital = '',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hospital.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          size: 14,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hospital,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Rating
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
