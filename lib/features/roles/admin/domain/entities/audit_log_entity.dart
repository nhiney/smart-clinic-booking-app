import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogEntity {
  final String id;
  final String action;
  final String detail;
  final String userId; // user_id ghi khi tạo log
  final String location;
  final String ip;
  final DateTime? dateTime;
  final String type;

  AuditLogEntity({
    required this.id,
    required this.action,
    required this.detail,
    required this.userId,
    required this.location,
    required this.ip,
    required this.dateTime,
    required this.type,
  });

  factory AuditLogEntity.fromMap(Map<String, dynamic> map, String id) {
    // Hỗ trợ cả tên field mới (khi tạo log) lẫn tên cũ.
    final rawTime = map['timestamp'] ?? map['time'];
    DateTime? dt;
    if (rawTime is Timestamp) {
      dt = rawTime.toDate();
    } else if (rawTime is String && rawTime.isNotEmpty) {
      dt = DateTime.tryParse(rawTime);
    }

    return AuditLogEntity(
      id: id,
      action: (map['action'] ?? '').toString(),
      detail: (map['details'] ?? map['detail'] ?? '').toString(),
      userId: (map['user_id'] ?? map['userId'] ?? map['admin'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      ip: (map['ip'] ?? '').toString(),
      dateTime: dt,
      type: (map['type'] ?? 'info').toString(),
    );
  }

  /// Nhãn hành động tiếng Việt.
  String get actionLabel {
    switch (action.toUpperCase()) {
      case 'LOGIN':
        return 'Đăng nhập';
      case 'LOGOUT':
        return 'Đăng xuất';
      case 'CREATE':
        return 'Tạo mới';
      case 'UPDATE':
        return 'Cập nhật';
      case 'DELETE':
        return 'Xoá';
      default:
        return action.isEmpty ? 'Hoạt động' : action;
    }
  }

  /// Mô tả hiển thị, có fallback theo hành động khi `detail` rỗng.
  String get displayDetail {
    if (detail.trim().isNotEmpty) return detail;
    switch (action.toUpperCase()) {
      case 'LOGIN':
        return 'Đăng nhập vào hệ thống';
      case 'LOGOUT':
        return 'Đăng xuất khỏi hệ thống';
      default:
        return 'Không có mô tả';
    }
  }

  /// Người thực hiện (rút gọn UID nếu quá dài).
  String get actorLabel {
    if (userId.isEmpty) return 'Hệ thống';
    if (userId.length > 10) return 'ID ${userId.substring(0, 8)}…';
    return userId;
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// Thời gian đầy đủ: "23/05/2026 · 15:28".
  String get timeLabel {
    final dt = dateTime;
    if (dt == null) return 'Không rõ thời gian';
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year} · ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  /// Thời gian giờ:phút (dùng cho cột bên phải).
  String get hourLabel {
    final dt = dateTime;
    if (dt == null) return '--:--';
    return '${_two(dt.hour)}:${_two(dt.minute)}';
  }

  /// Nhãn tương đối: "Vừa xong", "5 phút trước", "3 giờ trước", "Hôm qua"...
  String relativeLabel(DateTime now) {
    final dt = dateTime;
    if (dt == null) return '';
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return timeLabel;
  }

  /// Khoá gom nhóm theo ngày.
  String get dayKey {
    final dt = dateTime;
    if (dt == null) return 'Không rõ';
    return '${_two(dt.day)}/${_two(dt.month)}/${dt.year}';
  }

  bool get isLogin => action.toUpperCase() == 'LOGIN';
  bool get isLogout => action.toUpperCase() == 'LOGOUT';
}
