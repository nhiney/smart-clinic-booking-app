import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/extensions/context_extension.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final String hospital;
  /// Optional review count (e.g. from Firestore `totalReviews`).
  final int? totalReviews;
  /// e.g. "2.1 km" when user location is known.
  final String? distanceLabel;
  final int? experienceYears;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    this.imageUrl = '',
    this.rating = 0.0,
    this.hospital = '',
    this.totalReviews,
    this.distanceLabel,
    this.experienceYears,
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
          color: context.colors.card,
          borderRadius: context.radius.mRadius,
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: context.radius.sRadius,
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: context.radius.sRadius,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.person,
                          size: 36,
                          color: context.colors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 36,
                      color: context.colors.primary,
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
                    style: context.textStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hospital.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 14,
                          color: context.colors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hospital,
                            style: context.textStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (distanceLabel != null && distanceLabel!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: context.colors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distanceLabel!,
                          style: context.textStyles.caption,
                        ),
                      ],
                    ),
                  ],
                  if (experienceYears != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.work_history_outlined,
                          size: 14,
                          color: context.colors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$experienceYears năm kinh nghiệm',
                          style: context.textStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Rating
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: context.textStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (totalReviews != null && totalReviews! > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '($totalReviews)',
                    style: context.textStyles.caption.copyWith(fontSize: 10),
                  ),
                ],
                const SizedBox(height: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: context.colors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
