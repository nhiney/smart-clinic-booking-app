import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('Thêm nhắc uống thuốc', style: context.textStyles.heading2),
                const SizedBox(height: 20),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên thuốc', prefixIcon: Icon(Icons.medication))),
                const SizedBox(height: 14),
                TextField(controller: dosageController, decoration: const InputDecoration(labelText: 'Liều lượng (VD: 1 viên)', prefixIcon: Icon(Icons.format_list_numbered))),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(labelText: 'Tần suất', prefixIcon: Icon(Icons.repeat)),
                  items: ['Mỗi ngày', '2 lần/ngày', '3 lần/ngày', 'Mỗi tuần'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (val) => setModalState(() => selectedFrequency = val!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedTime,
                  decoration: const InputDecoration(labelText: 'Giờ uống', prefixIcon: Icon(Icons.access_time)),
                  items: ['06:00', '07:00', '08:00', '12:00', '18:00', '20:00', '22:00'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setModalState(() => selectedTime = val!),
                ),
                const SizedBox(height: 14),
                TextField(controller: notesController, maxLines: 2, decoration: const InputDecoration(labelText: 'Ghi chú', prefixIcon: Icon(Icons.note))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (nameController.text.trim().isEmpty) return;
                      final auth = context.read<AuthController>();
                      final medController = context.read<MedicationController>();
                      final medication = MedicationModel(
                        id: '',
                        patientId: auth.currentUser?.id ?? '',
                        name: nameController.text.trim(),
                        dosage: dosageController.text.trim(),
                        frequency: selectedFrequency,
                        time: selectedTime,
                        startDate: DateTime.now(),
                        notes: notesController.text.trim(),
                      );
                      await medController.addMedication(medication);
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm thuốc'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const BrandedAppBar(title: 'Theo dõi thuốc'),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedication,
        backgroundColor: context.colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<MedicationController>(
        builder: (_, controller, __) {
          if (controller.isLoading) return const LoadingWidget(itemCount: 3);
          if (controller.medications.isEmpty) {
            return const EmptyStateWidget(icon: Icons.medication_outlined, title: 'Chưa có thuốc nào', subtitle: 'Nhấn + để thêm thuốc mới');
          }
          return RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthController>();
              if (auth.currentUser != null) controller.loadMedications(auth.currentUser!.id);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildAdherenceSummary(controller),
                const SizedBox(height: 20),
                ...controller.medications.map((med) => _MedicationCard(medication: med, controller: controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdherenceSummary(MedicationController controller) {
    if (controller.adherenceRates.isEmpty) return const SizedBox.shrink();
    final avg = controller.adherenceRates.values.fold(0.0, (a, b) => a + b) / controller.adherenceRates.length;
    final pct = (avg * 100).toInt();
    final color = pct >= 80 ? Colors.green : pct >= 50 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text('$pct%', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tuân thủ 30 ngày', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: avg, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6),
                const SizedBox(height: 4),
                Text(
                  pct >= 80 ? 'Rất tốt! Hãy tiếp tục.' : pct >= 50 ? 'Cần cải thiện thêm.' : 'Cần chú ý hơn.',
                  style: TextStyle(fontSize: 12, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final MedicationEntity medication;
  final MedicationController controller;
  const _MedicationCard({required this.medication, required this.controller});

  @override
  Widget build(BuildContext context) {
    final adherence = controller.adherenceFor(medication.id);
    final auth = context.read<AuthController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: medication.isActive ? Colors.green.withValues(alpha: 0.12) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication, color: medication.isActive ? Colors.green : Colors.grey),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('${medication.dosage} • ${medication.frequency}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    Text('⏰ ${medication.time}', style: TextStyle(fontSize: 13, color: context.colors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(medication.isActive ? Icons.check_circle : Icons.circle_outlined, color: medication.isActive ? Colors.green : Colors.grey),
                onPressed: () => controller.toggleMedication(medication.id, !medication.isActive),
              ),
            ],
          ),
          if (adherence > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: adherence, backgroundColor: Colors.grey[200], minHeight: 5, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Text('${(adherence * 100).toInt()}% tuân thủ', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await controller.recordIntake(medicationId: medication.id, patientId: auth.currentUser?.id ?? '', wasTaken: true);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Đã ghi nhận!' : 'Ghi nhận thất bại'),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ));
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Đã uống', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await controller.recordIntake(medicationId: medication.id, patientId: auth.currentUser?.id ?? '', wasTaken: false);
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Bỏ qua', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => controller.deleteMedication(medication.id),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
