import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/di/injection.dart';
import '../controllers/admin_assignment_controller.dart';
import '../../domain/entities/facility_entities.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

class DoctorAssignmentScreen extends StatelessWidget {
  final Hospital? hospital;
  final Department? department;

  const DoctorAssignmentScreen({
    super.key, 
    this.hospital, 
    this.department,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminAssignmentController>(
      create: (_) => getIt<AdminAssignmentController>()..init(),
      child: Scaffold(
        backgroundColor: const Color(0xfff8f9fa),
        appBar: AppBar(
          title: const Text('Phân Công Lịch Trực / Phòng Khám', 
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: Consumer<AdminAssignmentController>(
          builder: (context, controller, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Thông Tin Phân Công", 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          const SizedBox(height: 20),
                          
                          _buildLabel("1. Chọn Bác Sĩ"),
                          DropdownButtonFormField<DoctorEntity>(
                            value: controller.selectedDoctor,
                            hint: const Text("Chọn bác sĩ cần phân công"),
                            items: controller.doctors.map((DoctorEntity doc) {
                              return DropdownMenuItem<DoctorEntity>(
                                value: doc,
                                child: Text(doc.name),
                              );
                            }).toList(),
                            onChanged: controller.selectDoctor,
                            decoration: _inputDecoration(),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel("2. Chọn Cơ Sở / Bệnh Viện"),
                          DropdownButtonFormField<Hospital>(
                            value: controller.selectedHospital,
                            hint: const Text("Chọn hospital"),
                            items: controller.hospitals.map((Hospital h) {
                              return DropdownMenuItem<Hospital>(
                                value: h,
                                child: Text(h.name),
                              );
                            }).toList(),
                            onChanged: controller.selectHospital,
                            decoration: _inputDecoration(),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel("3. Chọn Chuyên Khoa"),
                          DropdownButtonFormField<Department>(
                            value: controller.selectedDepartment,
                            hint: const Text("Chọn khoa (Hãy chọn bệnh viện trước)"),
                            items: controller.departments.map((Department d) {
                              return DropdownMenuItem<Department>(
                                value: d,
                                child: Text(d.name),
                              );
                            }).toList(),
                            onChanged: controller.selectDepartment,
                            decoration: _inputDecoration(),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildLabel("4. Chọn Phòng Khám / Phòng Bệnh"),
                          DropdownButtonFormField<Room>(
                            value: controller.selectedRoom,
                            hint: const Text("Chọn phòng trực"),
                            items: controller.rooms.map((Room r) {
                              return DropdownMenuItem<Room>(
                                value: r,
                                child: Text("${r.name} (${r.type})"),
                              );
                            }).toList(),
                            onChanged: controller.selectRoom,
                            decoration: _inputDecoration(),
                          ),
                          const SizedBox(height: 30),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final success = await controller.submitAssignment();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success 
                                        ? 'Phân công bác sĩ thành công và đồng bộ dữ liệu!' 
                                        : 'Vui lòng điền đầy đủ thông tin!'),
                                      backgroundColor: success ? Colors.green : Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text("XÁC NHẬN PHÂN CÔNG", 
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.isLoading)
                  Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: const Color(0xfff1f3f5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}