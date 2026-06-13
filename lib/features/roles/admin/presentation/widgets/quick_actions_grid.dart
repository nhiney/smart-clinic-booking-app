import 'package:flutter/material.dart';
import './admin_quick_action_button.dart';
import '../controllers/admin_controller.dart';
import '../screens/add_doctor_screen.dart';

class QuickActionsGrid extends StatelessWidget {
  final AdminController controller;
  final VoidCallback onAddHospitalTap;

  const QuickActionsGrid({
    super.key,
    required this.controller,
    required this.onAddHospitalTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 8,
      childAspectRatio: 0.75,
      children: [
        AdminQuickActionButton(
          label: 'Thêm BV',
          icon: Icons.add_business_rounded,
          onTap: onAddHospitalTap,
        ),
        AdminQuickActionButton(
          label: 'Thêm Bác sĩ',
          icon: Icons.person_add_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDoctorScreen())),
        ),
        AdminQuickActionButton(
          label: 'Khởi tạo Khoa & BS',
          icon: Icons.account_tree_rounded,
          onTap: () async {
            final result = await controller.seedDepartmentsAndDoctors();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(result), 
                backgroundColor: result.startsWith('Lỗi') ? Colors.red : Colors.green
              ));
            }
          },
        ),
        AdminQuickActionButton(
          label: 'Thêm BN mẫu',
          icon: Icons.group_add_rounded,
          onTap: () async {
            await controller.seedPatients();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Đã tạo 5 bệnh nhân mẫu thành công!'), 
                backgroundColor: Colors.green
              ));
            }
          },
        ),
      ],
    );
  }
}