import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/doctor_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../core/widgets/branded_app_bar.dart';
import '../controllers/doctor_controller.dart';
import 'doctor_detail_screen.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorController>().loadDoctors();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(
        title: "Tìm bác sĩ",
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: TextField(
              controller: searchController,
              onChanged: (val) {
                context.read<DoctorController>().searchDoctorsLocal(val);
              },
              decoration: InputDecoration(
                hintText: "Tìm theo tên, chuyên khoa...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Specialty filter
          Consumer<DoctorController>(
            builder: (_, controller, __) {
              return Container(
                height: 46,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = controller.specialties[index];
                    final isSelected =
                        (specialty == 'Tất cả' && controller.selectedSpecialty.isEmpty) ||
                            specialty == controller.selectedSpecialty;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          specialty,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        onSelected: (_) {
                          controller.filterBySpecialty(specialty);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // Doctor list
          Expanded(
            child: Consumer<DoctorController>(
              builder: (_, controller, __) {
                if (controller.isLoading) {
                  return const LoadingWidget(itemCount: 4);
                }

                if (controller.errorMessage != null) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: controller.errorMessage!,
                    buttonText: "Thử lại",
                    onButtonPressed: () => controller.loadDoctors(),
                  );
                }

                if (controller.filteredDoctors.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    title: "Không tìm thấy bác sĩ",
                    subtitle: "Thử tìm kiếm với từ khóa khác",
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: controller.filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = controller.filteredDoctors[index];
                    return DoctorCard(
                      name: doctor.name,
                      specialty: doctor.specialty,
                      imageUrl: doctor.imageUrl,
                      rating: doctor.rating,
                      hospital: doctor.hospital,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorDetailScreen(doctor: doctor),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
