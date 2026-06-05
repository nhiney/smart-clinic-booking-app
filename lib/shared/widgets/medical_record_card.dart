import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/theme/colors/colors.dart';
import '../../features/clinical/domain/entities/medical_record.dart';
import '../../core/widgets/app_card.dart';

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final VoidCallback? onTap;

  const MedicalRecordCard({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medical_information_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: context.textStyles.subtitle,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'BS. ${record.doctorName}',
                            style: context.textStyles.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(record.visitDate),
                      style: context.textStyles.caption.copyWith(
                        color: context.colors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Chẩn đoán',
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.diagnosis,
                  style: context.textStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (record.note != null && record.note!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    record.note!,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
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
