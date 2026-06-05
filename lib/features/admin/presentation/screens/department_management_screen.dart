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
        actions: [
          IconButton(
            tooltip: 'Thêm khoa',
            icon: const Icon(Icons.add_business_outlined),
            onPressed: () => _showAddNameDialog(
              title: 'Thêm khoa mới',
              hint: 'Tên khoa (VD: Khoa Nội)',
              onSubmit: (name) => context.read<AdminController>().addDepartment(
                    hospitalId: widget.hospital.id,
                    name: name,
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: (context.watch<AdminController>().selectedDepartment != null)
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              icon: const Icon(Icons.meeting_room_outlined, color: Colors.white),
              label: const Text('Thêm phòng', style: TextStyle(color: Colors.white)),
              onPressed: () {
                final dept = context.read<AdminController>().selectedDepartment!;
                _showAddNameDialog(
                  title: 'Thêm phòng cho ${dept.name}',
                  hint: 'Tên phòng (VD: Phòng 101)',
                  onSubmit: (name) =>
                      context.read<AdminController>().addRoom(departmentId: dept.id, name: name),
                );
              },
            )
          : null,
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
                                child: GestureDetector(
                                  onLongPress: () => _confirmDeleteDepartment(dept.id, dept.name),
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

  /// Generic single-field "add" dialog used for departments and rooms.
  void _showAddNameDialog({
    required String title,
    required String hint,
    required Future<void> Function(String name) onSubmit,
  }) {
    final ctrl = TextEditingController();
    bool isSaving = false;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: InputDecoration(labelText: hint, border: const OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final name = ctrl.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => isSaving = true);
                      try {
                        await onSubmit(name);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDepartment(String id, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa khoa'),
        content: Text('Bạn có chắc muốn xóa khoa "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await context.read<AdminController>().deleteDepartment(id);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}