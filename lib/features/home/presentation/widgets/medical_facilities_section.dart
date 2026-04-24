import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors/app_colors.dart';

class MedicalFacilitiesSection extends StatelessWidget {
  const MedicalFacilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CƠ SỞ Y TẾ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF003C5C),
                    ),
                  ),
                  Text(
                    'nổi bật trong tháng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF546E7A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/maps'),
                child: const Row(
                  children: [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.keyboard_double_arrow_right_rounded, size: 16, color: Colors.lightBlue),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return const _HospitalVerticalCard();
            },
          ),
        ),
      ],
    );
  }
}

class _HospitalVerticalCard extends StatelessWidget {
  const _HospitalVerticalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Area
          Container(
            height: 120,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withAlpha(100),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(Icons.local_hospital_rounded, size: 60, color: Colors.blue),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF003C5C),
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: 'Bệnh viện Đại học Y Dược TP.HCM'),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.verified, color: Colors.lightBlue, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF546E7A)),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Hồng Bàng, Q.5, TP.HCM',
                        style: TextStyle(fontSize: 12, color: Color(0xFF546E7A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Text('(4.7) ', style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/under-development?title=${Uri.encodeComponent('Đặt khám tại cơ sở y tế')}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Đặt khám ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
