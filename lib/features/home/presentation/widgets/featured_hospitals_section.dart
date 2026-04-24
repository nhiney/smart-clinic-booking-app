import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HospitalInfo {
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final int reviews;

  const HospitalInfo({
    required this.name,
    required this.address,
    required this.imageUrl,
    this.rating = 4.8,
    this.reviews = 1025,
  });
}

class FeaturedHospitalsSection extends StatelessWidget {
  const FeaturedHospitalsSection({super.key});

  static const List<HospitalInfo> _hospitals = [
    HospitalInfo(
      name: 'Bệnh viện đa khoa quốc tế Nam Sài Gòn',
      address: 'Số 88, Đường số 8, KDC Trung Sơn, Bình Hưng, Bình Chánh, HCM',
      imageUrl: 'https://cdn.tuoitre.vn/thumb_w/730/2021/4/21/anh-duoc-giao-16190101894982054625292.jpg', // Placeholder
    ),
    HospitalInfo(
      name: 'Bệnh viện Chợ Rẫy',
      address: '201B Nguyễn Chí Thanh, Phường 12, Quận 5, HCM',
      imageUrl: 'https://bvchoray.org.vn/uploads/images/2023/12/12/bvcr.jpg', // Placeholder
      rating: 4.9,
      reviews: 3200,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'CƠ SỞ Y TẾ\n',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D62A2),
                      ),
                    ),
                    TextSpan(
                      text: 'nổi bật trong tháng',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF455A64),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/under-development?title=${Uri.encodeComponent('Bệnh viện nổi bật')}'),
                child: const Text(
                  'Xem thêm >',
                  style: TextStyle(
                    color: Color(0xFF0288D1),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 290,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _hospitals.length,
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
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Half (Blue Background + Logo)
          SizedBox(
            height: 90,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D62A2),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          hospital.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 16,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.network(
                        hospital.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.local_hospital_rounded,
                          color: Color(0xFF0D62A2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Half (Details)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_rounded, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hospital.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(color: Color(0xFFEEEEEE), height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${hospital.reviews} đánh giá',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF607D8B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => context.push('/under-development?title=${Uri.encodeComponent('Đặt khám tại bệnh viện')}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D62A2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Đặt khám ngay',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
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
