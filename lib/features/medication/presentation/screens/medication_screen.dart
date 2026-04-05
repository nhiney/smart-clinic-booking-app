import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/medication_entity.dart';
import '../../data/models/medication_model.dart';
import '../controllers/medication_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<MedicationController>().loadMedications(auth.currentUser!.id);
      }
    });
  }

  void _showAddMedication() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final notesController = TextEditingController();
    String selectedFrequency = 'Mỗi ngày';
    String selectedTime = '08:00';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text("Thêm nhắc uống thuốc", style: AppTextStyles.heading2),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Tên thuốc",
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: "Liều lượng (ví dụ: 1 viên)",
                  prefixIcon: Icon(Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 14),
              StatefulBuilder(
                builder: (context, setModalState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedFrequency,
                        decoration: const InputDecoration(
                          labelText: "Tần suất",
                          prefixIcon: Icon(Icons.repeat),
                        ),
                        items: ['Mỗi ngày', '2 lần/ngày', '3 lần/ngày', 'Mỗi tuần']
                            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedFrequency = val!),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedTime,
                        decoration: const InputDecoration(
                          labelText: "Giờ uống",
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        items: ['06:00', '07:00', '08:00', '12:00', '18:00', '20:00', '22:00']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setModalState(() => selectedTime = val!),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Ghi chú",
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    final auth = context.read<AuthController>();
                    final medController = context.read<MedicationController>();
                    final medication = MedicationModel(
                      id: '',
                      patientId: auth.currentUser?.id ?? '',
                      name: nameController.text,
                      dosage: dosageController.text,
                      frequency: selectedFrequency,
                      time: selectedTime,
                      startDate: DateTime.now(),
                      notes: notesController.text,
                    );
                    await medController.addMedication(medication);
                    if (mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Thêm thuốc"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(title: "Nhắc uống thuốc"),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedication,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<MedicationController>(
        builder: (_, controller, __) {
          if (controller.isLoading) {
            return const LoadingWidget(itemCount: 3);
          }
          if (controller.medications.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.medication_outlined,
              title: "Chưa có nhắc uống thuốc",
              subtitle: "Nhấn + để thêm thuốc mới",
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.medications.length,
            itemBuilder: (context, index) {
              final med = controller.medications[index];
              return _buildMedicationCard(med);
            },
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(MedicationEntity med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: med.isActive
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: med.isActive ? AppColors.success : AppColors.textHint,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: AppTextStyles.subtitle),
                const SizedBox(height: 2),
                Text(
                  "${med.dosage} • ${med.frequency}",
                  style: AppTextStyles.bodySmall,
                ),
                Text(
                  "⏰ ${med.time}",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              med.isActive ? Icons.check_circle : Icons.circle_outlined,
              color: med.isActive ? AppColors.success : AppColors.textHint,
            ),
            onPressed: () {
              context.read<MedicationController>().toggleMedication(med.id, !med.isActive);
            },
          ),
        ],
      ),
    );
  }
}
