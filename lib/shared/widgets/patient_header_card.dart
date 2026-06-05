import 'package:flutter/material.dart';

import '../../core/extensions/context_extension.dart';
import '../../core/theme/colors/colors.dart';
import '../../core/widgets/app_card.dart';

class PatientHeaderCard extends StatelessWidget {
  final String fullName;
  final String subtitle;
  final String code;
  final String bloodGroup;
  final String weightLabel;
  final String alertLabel;
  final String? avatarUrl;

  const PatientHeaderCard({
    super.key,
    required this.fullName,
    required this.subtitle,
    required this.code,
    required this.bloodGroup,
    required this.weightLabel,
    required this.alertLabel,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              context.colors.primary,
              context.colors.primaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(avatarUrl: avatarUrl, fullName: fullName),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: context.textStyles.heading2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.textStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(label: code, icon: Icons.confirmation_number_outlined),
                        _InfoChip(label: bloodGroup, icon: Icons.bloodtype_outlined),
                        _InfoChip(label: weightLabel, icon: Icons.monitor_weight_outlined),
                        _InfoChip(
                          label: alertLabel,
                          icon: Icons.warning_amber_rounded,
                          isDanger: true,
                        ),
                      ],
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
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String fullName;

  const _Avatar({this.avatarUrl, required this.fullName});

  @override
  Widget build(BuildContext context) {
    final names = fullName.trim().split(' ').where((part) => part.isNotEmpty).toList();
    final initials = names.isEmpty
        ? 'P'
        : names.take(2).map((part) => part.substring(0, 1).toUpperCase()).join();

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: ClipOval(
        child: avatarUrl == null
            ? Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDanger;

  const _InfoChip({
    required this.label,
    required this.icon,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDanger ? AppColors.red100 : Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: isDanger ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
