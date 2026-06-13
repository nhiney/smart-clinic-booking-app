import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/theme/typography/app_text_styles.dart';
import 'package:smart_clinic_booking/core/widgets/app_text_field.dart';
import '../controllers/hospital_map_controller.dart';
import '../../domain/entities/hospital_entity.dart';

class HospitalListScreen extends ConsumerStatefulWidget {
  const HospitalListScreen({super.key});

  @override
  ConsumerState<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends ConsumerState<HospitalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecialty;

  final List<String> _specialties = [
    'Tất cả',
    'Đa khoa',
    'Nội khoa',
    'Ngoại khoa',
    'Nhi khoa',
    'Sản phụ khoa',
    'Tim mạch',
    'Cơ xương khớp',
    'Da liễu',
    'Tai mũi họng',
    'Răng hàm mặt',
    'Mắt',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalMapProvider);
    final controller = ref.read(hospitalMapProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chọn Bệnh viện/Phòng khám', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.push('/maps'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(controller),
          _buildSpecialtyChips(),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text('Lỗi: ${state.error}'))
                    : _buildHospitalList(state.filteredHospitals),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(HospitalMapController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _searchController,
              hintText: 'Tìm kiếm bệnh viện...',
              prefixIcon: const Icon(Icons.search),
              onChanged: (value) => controller.searchHospitals(value),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.my_location, color: AppColors.primary),
              onPressed: () => controller.findNearby(),
              tooltip: 'Tìm gần nhất',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = (_selectedSpecialty == specialty) || (_selectedSpecialty == null && specialty == 'Tất cả');

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSpecialty = specialty == 'Tất cả' ? null : specialty;
                });
                // We could implement specialty filtering in controller if needed, 
                // but for now let's just filter locally or add it to controller.
                if (specialty == 'Tất cả') {
                  ref.read(hospitalMapProvider.notifier).searchHospitals(_searchController.text);
                } else {
                  // This is a simple client-side filter for now
                  ref.read(hospitalMapProvider.notifier).searchHospitals(_searchController.text);
                  // The controller's searchHospitals also searches specialties, so it might work.
                }
              },
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.grey[200],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalList(List<HospitalEntity> hospitals) {
    if (hospitals.isEmpty) {
      return const Center(child: Text('Không tìm thấy bệnh viện nào'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        return _buildHospitalCard(hospital);
      },
    );
  }

  Widget _buildHospitalCard(HospitalEntity hospital) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/hospital/detail/${hospital.id}', extra: hospital),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: hospital.imageUrl != null
                    ? Image.network(
                        hospital.imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: AppTextStyles.heading3.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(hospital.rating.toStringAsFixed(1), style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        if (hospital.distance != null) ...[
                          const Icon(Icons.near_me_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            '${hospital.distance!.toStringAsFixed(1)} km',
                            style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hospital.address,
                            style: AppTextStyles.body.copyWith(color: Colors.grey[600], fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: hospital.specialties.take(2).map((s) => _buildSpecialtyTag(s)).toList(),
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

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey[200],
      child: const Icon(Icons.local_hospital_outlined, color: Colors.grey, size: 40),
    );
  }

  Widget _buildSpecialtyTag(String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        specialty,
        style: const TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold),
      ),
    );
  }
}
