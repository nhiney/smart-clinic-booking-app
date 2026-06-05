import 'package:flutter/material.dart';

class HospitalListItem extends StatelessWidget {
  final dynamic hospital;
  final VoidCallback onTap;

  const HospitalListItem({
    super.key,
    required this.hospital,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> hMap = {};
    try { hMap = (hospital as dynamic).toMap(); } catch (_) {}

    final String name = hospital.name ?? 'Bệnh viện';
    final String address = hMap['address'] ?? 'Chưa cập nhật địa chỉ';
    final int doctorCount = hMap['doctorCount'] ?? 0;
    final double rating = (hMap['rating'] as num?)?.toDouble() ?? 4.5;
    final String status = hMap['status'] ?? 'active'; // active, maintenance, paused

    final List<Color> bgColors = [const Color(0xFF38BDF8), const Color(0xFF34D399), const Color(0xFFC084FC), const Color(0xFFFBBF24)];
    final Color itemColor = bgColors[name.length % bgColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.local_hospital_rounded, color: itemColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '$doctorCount bác sĩ',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), fontWeight: FontWeight.w600),
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
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = const Color(0xFFDCFCE7);
    Color textColor = const Color(0xFF16A34A);
    String label = 'HĐ';

    if (status == 'maintenance') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
      label = 'Bảo trì';
    } else if (status == 'paused') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFEF4444);
      label = 'Tạm dừng';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }
}