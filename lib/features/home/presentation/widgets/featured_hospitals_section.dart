import 'package:flutter/material.dart';
import '../../../../core/theme/colors/app_colors.dart';

class HospitalInfo {
  final String name;
  final String address;
  final String imageUrl;
  final double rating;

  const HospitalInfo({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
  });
}

class FeaturedHospitalsSection extends StatelessWidget {
  const FeaturedHospitalsSection({super.key});

  static const List<HospitalInfo> _hospitals = [
    HospitalInfo(
      name: 'Bệnh viện Đại học Y Dược TP.HCM',
      address: '215 Hồng Bàng, Quận 5, TP.HCM',
      imageUrl: 'https://cdn.tuoitre.vn/thumb_w/730/2021/4/21/anh-duoc-giao-16190101894982054625292.jpg',
      rating: 4.8,
    ),
    HospitalInfo(
      name: 'Bệnh viện Chợ Rẫy',
      address: '201B Nguyễn Chí Thanh, Quận 5, TP.HCM',
      imageUrl: 'https://bvchoray.org.vn/uploads/images/2023/12/12/bvcr.jpg',
      rating: 4.7,
    ),
    HospitalInfo(
      name: 'Phòng khám Đa khoa Tâm Anh',
      address: 'Phổ Quang, Quận Tân Bình, TP.HCM',
      imageUrl: 'https://tamanhhospital.vn/wp-content/uploads/2020/12/benh-vien-tam-anh-tphcm.jpg',
      rating: 4.9,
    ),
    HospitalInfo(
      name: 'Bệnh viện Đa khoa Hoàn Mỹ Sài Gòn',
      address: 'Phan Xích Long, Quận Phú Nhuận',
      imageUrl: 'https://hoanmysaigon.com/wp-content/uploads/2023/05/hmsg-1.jpg',
      rating: 4.6,
    ),
  ];

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
              Expanded(
                child: const Text(
                  'Cơ sở y tế nổi bật tại TP.HCM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250, // Increased height slightly to prevent vertical overflow
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _hospitals.length,
            itemBuilder: (context, index) {
              final hospital = _hospitals[index];
              return _HospitalCard(hospital: hospital);
            },
          ),
        ),
      ],
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalInfo hospital;

  const _HospitalCard({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top half: Hospital image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                hospital.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primarySurface,
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // Bottom half: Hospital details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            hospital.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Đặt khám',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
