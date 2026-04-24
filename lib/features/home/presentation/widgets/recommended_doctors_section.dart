import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

class RecommendedDoctorsSection extends StatelessWidget {
  final List<DoctorEntity> doctors;

  const RecommendedDoctorsSection({super.key, required this.doctors});

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Bác sĩ chuyên gia nổi bật',
                  style: context.textStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/doctor/search'),
                child: Text(
                  'Xem tất cả',
                  style: context.textStyles.bodyBold.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return _DoctorCard(doctor: doctor);
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorEntity doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/doctor/detail/${doctor.id}',
        extra: doctor,
      ),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.mRadius,
          boxShadow: [
            BoxShadow(
              color: context.colors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left: Circular Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.primary.withOpacity(0.1),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: doctor.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: doctor.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => _buildAvatarError(context),
                        )
                      : _buildAvatarError(context),
                ),
              ),
              const SizedBox(width: 16),
              // Right: Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      doctor.name.isNotEmpty ? doctor.name : 'Bác sĩ',
                      style: context.textStyles.bodyBold.copyWith(
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty.isNotEmpty ? doctor.specialty : '—',
                      style: context.textStyles.caption.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating > 0
                              ? doctor.rating.toStringAsFixed(1)
                              : '—',
                          style: context.textStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        if (doctor.totalReviews > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${doctor.totalReviews})',
                            style: context.textStyles.caption.copyWith(
                              fontSize: 10,
                              color: context.colors.textHint,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: context.radius.sRadius,
                          boxShadow: [
                            BoxShadow(
                              color: context.colors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Đặt khám',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarError(BuildContext context) {
    return Container(
      color: context.colors.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        color: context.colors.primary,
        size: 32,
      ),
    );
  }
}
