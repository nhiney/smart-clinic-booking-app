import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/facility_entities.dart';
import 'room_management_screen.dart';
import 'doctor_assignment_screen.dart';

class DepartmentManagementScreen extends StatefulWidget {
  final Hospital hospital;
  const DepartmentManagementScreen({super.key, required this.hospital});

  @override
  State<DepartmentManagementScreen> createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends State<DepartmentManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchDepartments(widget.hospital.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.hospital.name, style: context.textStyles.heading3),
            Text('Danh sách chuyên khoa', style: context.textStyles.bodySmall),
          ],
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.selectedDepartments.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: controller.selectedDepartments.length,
                  itemBuilder: (context, index) {
                    final dept = controller.selectedDepartments[index];
                    return _buildDepartmentCard(context, dept);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_rounded, size: 80, color: context.colors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Chưa có khoa nào', style: context.textStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildDepartmentCard(BuildContext context, Department dept) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomManagementScreen(department: dept),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_hospital_rounded, color: context.colors.primary, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                dept.name,
                style: context.textStyles.bodyBold,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorAssignmentScreen(
                        hospital: widget.hospital,
                        department: dept,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Gán Bác sĩ', style: context.textStyles.bodySmall.copyWith(color: context.colors.primary, fontSize: 10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
