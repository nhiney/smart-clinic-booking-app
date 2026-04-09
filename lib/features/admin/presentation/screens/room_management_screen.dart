import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/facility_entities.dart';

class RoomManagementScreen extends StatefulWidget {
  final Department department;
  const RoomManagementScreen({super.key, required this.department});

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchRooms(widget.department.id);
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
            Text(widget.department.name, style: context.textStyles.heading3),
            Text('Danh sách phòng & Thiết bị', style: context.textStyles.bodySmall),
          ],
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.selectedRooms.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.selectedRooms.length,
                  itemBuilder: (context, index) {
                    final room = controller.selectedRooms[index];
                    return _buildRoomTile(context, room, controller);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.meeting_room_rounded, size: 80, color: context.colors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Chưa có phòng nào', style: context.textStyles.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, Room room, AdminController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        key: PageStorageKey(room.id),
        title: Text(room.name, style: context.textStyles.bodyBold),
        subtitle: Text('Loại: ${room.type}', style: context.textStyles.bodySmall),
        leading: Icon(Icons.door_front_door_rounded, color: context.colors.primary),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onExpansionChanged: (expanded) {
          if (expanded) {
            controller.fetchDevices(room.id);
          }
        },
        children: [
          const Divider(),
          _buildDeviceList(context, controller),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Thêm Thiết bị'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, AdminController controller) {
    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: LinearProgressIndicator(),
      );
    }
    
    if (controller.selectedDevices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Chưa có thiết bị', style: context.textStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)),
      );
    }

    return Column(
      children: controller.selectedDevices.map((device) {
        return ListTile(
          dense: true,
          leading: const Icon(Icons.biotech_rounded, size: 20),
          title: Text(device.name, style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: device.status == 'active' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              device.status.toUpperCase(),
              style: context.textStyles.bodySmall.copyWith(
                color: device.status == 'active' ? Colors.green : Colors.orange,
                fontSize: 8,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
