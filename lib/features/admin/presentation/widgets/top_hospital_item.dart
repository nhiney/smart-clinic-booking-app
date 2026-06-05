import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';

class TopHospitalItem extends StatelessWidget {
  final HospitalRevenueItem hospital;

  const TopHospitalItem({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    Color rankBgColor = const Color(0xFFE2E8F0);
    Color rankTextColor = const Color(0xFF64748B);
    Color iconColor = const Color(0xFF475569);
    Color avatarBg = const Color(0xFFF1F5F9);

    if (hospital.rank == 1) {
      rankBgColor = const Color(0xFFD97706);
      rankTextColor = Colors.white;
      iconColor = const Color(0xFF2563EB);
      avatarBg = const Color(0xFFEFF6FF);
    } else if (hospital.rank == 2) {
      rankBgColor = const Color(0xFFCBD5E1);
      rankTextColor = const Color(0xFF475569);
      iconColor = const Color(0xFFBE185D);
      avatarBg = const Color(0xFFFDF2F8);
    } else if (hospital.rank == 3) {
      rankBgColor = const Color(0xFFD97706).withOpacity(0.15);
      rankTextColor = const Color(0xFFD97706);
      iconColor = const Color(0xFF0D9488);
      avatarBg = const Color(0xFFF0FDFA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: rankBgColor,
            child: Text('${hospital.rank}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: rankTextColor)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: avatarBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.local_hospital_rounded, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospital.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                FractionallySizedBox(
                  widthFactor: hospital.percentageOfMax.clamp(0.0, 1.0),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('đ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('${hospital.revenueValue.toInt()}M', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            ],
          )
        ],
      ),
    );
  }
}