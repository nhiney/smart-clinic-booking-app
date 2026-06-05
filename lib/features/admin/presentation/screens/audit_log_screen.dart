import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký truy cập')),
      body: controller.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : controller.auditLogs.isEmpty 
          ? const Center(child: Text("Chưa có nhật ký nào"))
          : ListView.builder(
              itemCount: controller.auditLogs.length,
              itemBuilder: (context, index) {
              final log = controller.auditLogs[index];
              
              Color statusColor = log.action.toUpperCase() == 'LOGIN' ? Colors.green : Colors.orange;
              IconData iconData = log.action.toUpperCase() == 'LOGIN' ? Icons.login : Icons.logout;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(iconData, color: statusColor, size: 18),
                ),
                title: Text(
                  log.action.toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                ),
                subtitle: Text(
                  "${log.admin} • ${log.time}", 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)
                ),
              );
            },
          ),
    );
  }
}