import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../domain/entities/facility_entities.dart';

class HospitalListItem extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onTap;

  const HospitalListItem({
    super.key,
    required this.hospital,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: context.radius.lRadius,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.1),
                        borderRadius: context.radius.mRadius,
                      ),
                      child: ClipRRect(
                        borderRadius: context.radius.mRadius,
                        child: hospital.logoUrl.isNotEmpty
                            ? Image.network(
                                hospital.logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.business_rounded,
                                  color: context.colors.primary,
                                  size: 28,
                                ),
                              )
                            : Icon(
                                Icons.business_rounded,
                                color: context.colors.primary,
                                size: 28,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hospital.name,
                            style: context.textStyles.bodyBold.copyWith(fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, 
                                   size: 12, 
                                   color: context.colors.textHint),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  hospital.address,
                                  style: context.textStyles.bodySmall.copyWith(
                                    color: context.colors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: context.colors.textHint),
                  ],
                ),
                if (hospital.specialties.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text('Chuyên khoa:', style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: hospital.specialties.take(5).map((s) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.primary.withOpacity(0.1)),
                      ),
                      child: Text(
                        s,
                        style: context.textStyles.bodySmall.copyWith(
                          color: context.colors.primaryDark,
                          fontSize: 11,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
