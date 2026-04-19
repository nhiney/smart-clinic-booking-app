import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

class ConsultingDoctorsSection extends StatefulWidget {
  final List<DoctorEntity> doctors;

  const ConsultingDoctorsSection({super.key, required this.doctors});

  @override
  State<ConsultingDoctorsSection> createState() => _ConsultingDoctorsSectionState();
}

class _ConsultingDoctorsSectionState extends State<ConsultingDoctorsSection> {
  int _selectedIndex = 0;
  final List<String> _filters = ['Sức khoẻ chung', 'Dinh dưỡng', 'Nhi Khoa', 'Mẹ bầu'];

  @override
  Widget build(BuildContext context) {
    if (widget.doctors.isEmpty) return const SizedBox.shrink();

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
                      text: 'CHUYÊN GIA, BÁC SĨ\n',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D62A2),
                      ),
                    ),
                    TextSpan(
                      text: 'tư vấn, chăm sóc sức khoẻ từ xa',
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
                onPressed: () => context.push('/doctor/search'),
                child: const Text(
                  'Xem thêm >',
                  style: TextStyle(
                    color: Color(0xFF0288D1),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Filter Chips
        SizedBox(
          height: 36,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0D62A2) : const Color(0xFFF9FBFD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF0D62A2) : const Color(0xFFE1F5FE),
                    ),
                  ),
                  child: Text(
                    _filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF0D62A2),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        // Doctors List
        SizedBox(
          height: 120, 
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: widget.doctors.length,
            itemBuilder: (context, index) {
              final doctor = widget.doctors[index];
              return _DoctorAvatarTile(doctor: doctor);
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorAvatarTile extends StatelessWidget {
  final DoctorEntity doctor;

  const _DoctorAvatarTile({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: doctor.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF455A64),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
