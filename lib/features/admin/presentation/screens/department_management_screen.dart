import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/facility_entities.dart';
import '../controllers/admin_controller.dart';
import '../widgets/patient_tab_view.dart';
import '../widgets/room_list_item.dart';

class DepartmentManagementScreen extends StatefulWidget {
  final Hospital hospital;

  const DepartmentManagementScreen({super.key, required this.hospital});

  @override
  State<DepartmentManagementScreen> createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends State<DepartmentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().selectHospital(widget.hospital);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final bool isDataMatching = controller.selectedHospital?.id == widget.hospital.id;
    final bool showLoading = controller.isLoading && (!isDataMatching || controller.selectedDepartments.isEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          widget.hospital.name,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: showLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: !isDataMatching || controller.selectedDepartments.isEmpty
                      ? const Center(
                          child: Text(
                            'Cơ sở này chưa cấu hình phân khoa',
                            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                        )
                      : SizedBox(
                          height: 38,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: controller.selectedDepartments.length,
                            itemBuilder: (context, index) {
                              final dept = controller.selectedDepartments[index];
                              final isSelected = controller.selectedDepartment?.id == dept.id;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(dept.name),
                                  selected: isSelected,
                                  selectedColor: const Color(0xFF2563EB),
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                                  ),
                                  onSelected: (bool selected) {
                                    if (selected) {
                                      controller.selectDepartment(dept);
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
                
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF2563EB),
                    unselectedLabelColor: const Color(0xFF64748B),
                    indicatorColor: const Color(0xFF2563EB),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Phòng khám'),
                      Tab(text: 'Bệnh nhân'),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRoomListView(controller, isDataMatching),
                      _buildPatientTabContent(controller, isDataMatching),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRoomListView(AdminController controller, bool isDataMatching) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    final rooms = isDataMatching ? controller.selectedRooms : [];

    if (rooms.isEmpty) {
      return _buildEmptyState('Chưa có cấu hình phòng chức năng cho phân khoa này.');
    }

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: () async {
        if (controller.selectedDepartment != null) {
          await controller.selectDepartment(controller.selectedDepartment!);
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return RoomListItem(room: rooms[index]);
        },
      ),
    );
  }

  Widget _buildPatientTabContent(AdminController controller, bool isDataMatching) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
    }

    final patients = isDataMatching ? controller.patients : <Patient>[];

    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: () async {
        if (controller.selectedDepartment != null) {
          await controller.selectDepartment(controller.selectedDepartment!);
        }
      },
      child: PatientTabView(patients: patients),
    );
  }

  // Widget hiển thị trạng thái trống dữ liệu mặc định
  Widget _buildEmptyState(String message) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_open_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}