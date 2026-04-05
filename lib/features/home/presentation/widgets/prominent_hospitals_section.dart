import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class HospitalInfo {
  final String name;
  final String address;
  final String imageUrl;
  final String type;

  const HospitalInfo({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.type,
  });
}

class ProminentHospitalsSection extends StatelessWidget {
  final VoidCallback? onViewAll;

  const ProminentHospitalsSection({super.key, this.onViewAll});

  static const List<HospitalInfo> _hospitals = [
    HospitalInfo(
      name: 'BV Đại học Y Dược TP.HCM',
      address: '215 Hồng Bàng, Quận 5',
      type: 'Bệnh viện Công',
      imageUrl: 'https://cdn.tuoitre.vn/thumb_w/730/2021/4/21/anh-duoc-giao-16190101894982054625292.jpg',
    ),
    HospitalInfo(
      name: 'Bệnh viện Chợ Rẫy',
      address: '201B Nguyễn Chí Thanh, Quận 5',
      type: 'Bệnh viện Đa khoa',
      imageUrl: 'https://bvchoray.org.vn/uploads/images/2023/12/12/bvcr.jpg',
    ),
    HospitalInfo(
      name: 'Bệnh viện Từ Dũ',
      address: '284 Cống Quỳnh, Quận 1',
      type: 'Sản phụ khoa',
      imageUrl: 'https://images.vov.gov.vn/w480/uploaded/truonggiangvov/2020_08_07/tudu_vnyr.jpg',
    ),
    HospitalInfo(
      name: 'Bệnh viện FV',
      address: '6 Nguyễn Lương Bằng, Quận 7',
      type: 'Bệnh viện Quốc tế',
      imageUrl: 'https://www.fvhospital.com/wp-content/uploads/2018/02/fv-hospital-facade.jpg',
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
              const Text(
                'Cơ sở y tế nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
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
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _hospitals.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _HospitalCard(hospital: _hospitals[index]);
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
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: hospital.imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: AppColors.primarySurface),
              errorWidget: (context, url, error) => Container(
                color: AppColors.primarySurface,
                child: const Icon(Icons.apartment_rounded, color: AppColors.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hospital.type,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hospital.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textHint),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
