// lib/features/admin/presentation/widgets/hospital_management_view.dart
import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import '../screens/department_management_screen.dart';
import 'hospital_list_item.dart';
import 'hospital_filter_badge.dart';

class HospitalManagementView extends StatefulWidget {
  final AdminController controller;

  const HospitalManagementView({super.key, required this.controller});

  @override
  State<HospitalManagementView> createState() => _HospitalManagementViewState();
}

class _HospitalManagementViewState extends State<HospitalManagementView> {
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final hospitals = widget.controller.hospitals;

    int totalCount = hospitals.length;
    int activeCount = 0;
    int maintenanceCount = 0;

    for (var h in hospitals) {
      Map<String, dynamic> hMap = {};
      try { hMap = (h as dynamic).toMap(); } catch (_) {}
      final status = hMap['status'] ?? 'active';
      if (status == 'active') activeCount++;
      if (status == 'maintenance') maintenanceCount++;
    }

    final filteredHospitals = hospitals.where((h) {
      Map<String, dynamic> hMap = {};
      try { hMap = (h as dynamic).toMap(); } catch (_) {}
      final status = hMap['status'] ?? 'active';

      if (_selectedFilter == 'Đang HĐ') return status == 'active';
      if (_selectedFilter == 'Bảo trì') return status == 'maintenance';
      if (_selectedFilter == 'Tạm dừng') return status == 'paused';
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              _buildStatCard('Tổng số', totalCount, const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              _buildStatCard('Đang HĐ', activeCount, const Color(0xFF16A34A)),
              const SizedBox(width: 12),
              _buildStatCard('Bảo trì', maintenanceCount, const Color(0xFFD97706)),
            ],
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20, bottom: 16),
          child: Row(
            children: ['Tất cả', 'Đang HĐ', 'Bảo trì', 'Tạm dừng'].map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: HospitalFilterBadge(
                  label: filter,
                  isSelected: _selectedFilter == filter,
                  onTap: () => setState(() => _selectedFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),

        Expanded(
          child: filteredHospitals.isEmpty
              ? const Center(child: Text('Không có bệnh viện nào phù hợp', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredHospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = filteredHospitals[index];
                    return HospitalListItem(
                      hospital: hospital,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DepartmentManagementScreen(hospital: hospital),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color, height: 1.1),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}