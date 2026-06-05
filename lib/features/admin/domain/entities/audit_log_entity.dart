import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogEntity {
  final String id;
  final String action;
  final String detail; 
  final String admin; 
  final String location; 
  final String ip; 
  final String time; 
  final String type; 

  AuditLogEntity({required this.id, required this.action, required this.detail, 
    required this.admin, required this.location, required this.ip, required this.time, required this.type});

  factory AuditLogEntity.fromMap(Map<String, dynamic> map, String id) {
    dynamic timeData = map['time'];
    String formattedTime = '';
    
    if (timeData is Timestamp) {
      formattedTime = timeData.toDate().toString();
    } else {
      formattedTime = timeData?.toString() ?? '';
    }

    return AuditLogEntity(
      id: id,
      action: map['action'] ?? '',
      detail: map['detail'] ?? '',
      admin: map['admin'] ?? '',
      location: map['location'] ?? '',
      ip: map['ip'] ?? '',
      time: formattedTime,
      type: map['type'] ?? 'info',
    );
  }
}