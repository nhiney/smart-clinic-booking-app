import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/facility_entities.dart';

class DoctorAssignmentScreen extends StatefulWidget {
  final Hospital hospital;
  final Department department;
  
  const DoctorAssignmentScreen({
    super.key,
    required this.hospital,
    required this.department,
  });

  @override
  State<DoctorAssignmentScreen> createState() => _DoctorAssignmentScreenState();
}

class _DoctorAssignmentScreenState extends State<DoctorAssignmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchUnassignedDoctors();
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
            const Text('Phân bổ Bác sĩ'),
            Text('${widget.hospital.name} > ${widget.department.name}', style: context.textStyles.bodySmall),
          ],
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.unassignedDoctors.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.unassignedDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = controller.unassignedDoctors[index];
                    return _buildDoctorTile(context, doctor, controller);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: context.colors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Không có bác sĩ nào chưa được phân bổ'),
        ],
      ),
    );
  }

  Widget _buildDoctorTile(BuildContext context, dynamic doctor, AdminController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colors.primary.withOpacity(0.1),
          child: Icon(Icons.person_rounded, color: context.colors.primary),
        ),
        title: Text(doctor.name, style: context.textStyles.bodyBold),
        subtitle: Text('Chuyên môn: ${doctor.specialty}', style: context.textStyles.bodySmall),
        trailing: ElevatedButton(
          onPressed: () => _confirmAssignment(context, doctor, controller),
          child: const Text('Gán'),
        ),
      ),
    );
  }

  void _confirmAssignment(BuildContext context, dynamic doctor, AdminController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận phân bổ'),
        content: Text('Bạn có chắc chắn muốn gán ${doctor.name} vào khoa ${widget.department.name} của ${widget.hospital.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.assignDoctor(
                doctorId: doctor.id,
                hospitalId: widget.hospital.id,
                departmentId: widget.department.id,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã phân bổ bác sĩ thành công')),
                );
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
