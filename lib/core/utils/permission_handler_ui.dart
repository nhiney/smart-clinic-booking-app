import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerUI {
  /// Request a list of permissions and handle the UI for permanently denied cases.
  static Future<bool> requestPermissions({
    required BuildContext context,
    required List<Permission> permissions,
    required String rationaleTitle,
    required String rationaleMessage,
  }) async {
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = true;
    bool permanentlyDenied = false;

    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
        if (status.isPermanentlyDenied) {
          permanentlyDenied = true;
        }
      }
    });

    if (allGranted) return true;

    if (permanentlyDenied && context.mounted) {
      _showPermanentlyDeniedDialog(
        context, 
        rationaleTitle, 
        rationaleMessage,
      );
    }

    return false;
  }

  static void _showPermanentlyDeniedDialog(
    BuildContext context, 
    String title, 
    String message,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "$message\n\nVui lòng vào 'Cài đặt thiết bị' -> 'Ứng dụng' -> 'Smart Clinic' để cấp quyền thủ công.",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng", style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Mở Cài đặt"),
          ),
        ],
      ),
    );
  }
}
