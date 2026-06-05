import 'package:cloud_firestore/cloud_firestore.dart';

/// Người liên hệ khẩn cấp của bệnh nhân.
class EmergencyContact {
  final String name;
  final String phone;
  final String relation;

  const EmergencyContact({this.name = '', this.phone = '', this.relation = ''});

  bool get isEmpty => name.isEmpty && phone.isEmpty;

  factory EmergencyContact.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const EmergencyContact();
    return EmergencyContact(
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      relation: (map['relation'] ?? '') as String,
    );
  }
}

/// Bệnh nhân thuộc một khoa của bệnh viện.
///
/// Đọc trực tiếp từ document `users` (role == 'patient') kèm các trường
/// hồ sơ y tế mở rộng (chẩn đoán, tiền sử, dị ứng...). Tách riêng khỏi
/// `UserEntity` để màn hình chi tiết bệnh nhân có đủ dữ liệu hiển thị.
class DepartmentPatient {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String gender;
  final String bloodType;
  final String avatarUrl;
  final DateTime? dateOfBirth;
  final String diagnosis;
  final String medicalHistory;
  final List<String> allergies;
  final DateTime? lastVisit;
  final String assignedDoctor;
  final String insuranceId;
  final EmergencyContact emergencyContact;
  final String tenantId;
  final String departmentId;
  final String status;

  const DepartmentPatient({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.gender = '',
    this.bloodType = '',
    this.avatarUrl = '',
    this.dateOfBirth,
    this.diagnosis = '',
    this.medicalHistory = '',
    this.allergies = const [],
    this.lastVisit,
    this.assignedDoctor = '',
    this.insuranceId = '',
    this.emergencyContact = const EmergencyContact(),
    this.tenantId = '',
    this.departmentId = '',
    this.status = 'active',
  });

  /// Tuổi tính từ [dateOfBirth]; `null` nếu chưa có ngày sinh.
  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  static DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  factory DepartmentPatient.fromJson(Map<String, dynamic> json, String docId) {
    return DepartmentPatient(
      id: docId,
      name: (json['name'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      bloodType: (json['blood_type'] ?? json['bloodType'] ?? '') as String,
      avatarUrl: (json['avatarUrl'] ?? '') as String,
      dateOfBirth: _ts(json['date_of_birth'] ?? json['dateOfBirth']),
      diagnosis: (json['diagnosis'] ?? '') as String,
      medicalHistory: (json['medical_history'] ?? '') as String,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      lastVisit: _ts(json['last_visit']),
      assignedDoctor: (json['assigned_doctor'] ?? '') as String,
      insuranceId: (json['insurance_id'] ?? '') as String,
      emergencyContact: EmergencyContact.fromMap(
          (json['emergency_contact'] as Map<String, dynamic>?)),
      tenantId: (json['tenant_id'] ?? json['hospitalId'] ?? '') as String,
      departmentId: (json['department_id'] ?? json['departmentId'] ?? '') as String,
      status: (json['status'] ?? 'active') as String,
    );
  }
}
