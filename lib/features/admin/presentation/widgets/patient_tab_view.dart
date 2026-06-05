import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';
import 'patient_list_item.dart';

class PatientTabView extends StatefulWidget {
  final List<Patient> patients;

  const PatientTabView({super.key, required this.patients});

  @override
  State<PatientTabView> createState() => _PatientTabViewState();
}

class _PatientTabViewState extends State<PatientTabView> {
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final totalPatients = widget.patients.length;
    
    final vipPatients = widget.patients.where((p) => p.isVip).length;

    final activePatients = widget.patients.where((p) => p.status == 'active').length;

    List<Patient> filteredList = widget.patients;
    
    if (_selectedFilter == 'VIP') {
      filteredList = widget.patients.where((p) => p.isVip).toList();
    } 
    else if (_selectedFilter == 'Hoạt động') {
      filteredList = widget.patients.where((p) => p.status == 'active').toList();
    } 
    else if (_selectedFilter == 'BHYT') {
      filteredList = widget.patients.where((p) => p.insuranceId.isNotEmpty).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              _buildStatCard('Hoạt động', activePatients, const Color(0xFF16A34A)),
              const SizedBox(width: 10),
              _buildStatCard('Tháng này', totalPatients, const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              _buildStatCard('VIP', vipPatients, const Color(0xFFD97706)),
            ],
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: ['Tất cả', 'Hoạt động', 'VIP', 'BHYT'].map((filterName) {
              final isSelected = _selectedFilter == filterName;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filterName),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0066FF),
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  side: BorderSide(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                  showCheckmark: false,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filterName;
                      });
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hiển thị ${filteredList.length} / $totalPatients',
                style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Row(
                children: [
                  Text('Sắp xếp: ', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  Text('Mới nhất ▾', style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              )
            ],
          ),
        ),

        Expanded(
          child: filteredList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) => PatientListItem(patient: filteredList[index]),
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
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.12), width: 1),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          const Text('Không có dữ liệu bệnh nhân phù hợp.', style: TextStyle(color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }
}