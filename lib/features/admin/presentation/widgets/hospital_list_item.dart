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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
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
                              size: 32,
                            ),
                          )
                        : Icon(
                            Icons.business_rounded,
                            color: context.colors.primary,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: context.textStyles.bodyBold.copyWith(fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, 
                               size: 14, 
                               color: context.colors.textHint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hospital.address,
                              style: context.textStyles.bodySmall.copyWith(
                                color: context.colors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Optional: Show some stats like "X Departments" if available
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.colors.textHint),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
