import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String status;
  final String authProvider;
  final String avatarUrl;
  final String email;
  final bool isVerified;
  final String hospital;
  final dynamic createdAt;
  final dynamic updatedAt;

  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    this.role = 'patient',
    this.status = 'active',
    this.authProvider = 'phone',
    this.avatarUrl = '',
    this.email = '',
    this.isVerified = false,
    this.hospital = '',
    this.createdAt,
    this.updatedAt,
  });

  String get code => '#BN-${id.substring(0, 4).toUpperCase()}';
  int get age => (id.hashCode.abs() % 40) + 20;
  int get visitCount => (phone.hashCode.abs() % 15) + 1;
  String get disease => age > 50 ? "THA + Tim mạch" : (age > 40 ? "Tiểu đường type 2" : "Khám tổng quát");
  String get lastVisitText => visitCount > 8 ? "Hôm nay" : "3 ngày trước";

  factory Patient.fromFirebaseMap(Map<String, dynamic> map, String id) {
    return Patient(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      status: map['status'] ?? 'active',
      authProvider: map['auth_provider'] ?? 'phone',
      avatarUrl: map['avatarUrl'] ?? '',
      email: map['email'] ?? '',
      isVerified: map['is_verified'] ?? false,
      hospital: map['hospitalId'] ?? map['hospital'] ?? '',
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toFirebaseMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'status': status,
      'auth_provider': authProvider,
      'avatarUrl': avatarUrl,
      'email': email,
      'is_verified': isVerified,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Patient.fromSqfliteMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      status: map['status'] ?? 'active',
      authProvider: map['auth_provider'] ?? 'phone',
      avatarUrl: map['avatarUrl'] ?? '',
      email: map['email'] ?? '',
      isVerified: (map['is_verified'] ?? 0) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toSqfliteMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'status': status,
      'auth_provider': authProvider,
      'avatarUrl': avatarUrl,
      'email': email,
      'is_verified': isVerified ? 1 : 0,
      'created_at': createdAt is Timestamp 
          ? (createdAt as Timestamp).toDate().toIso8601String() 
          : createdAt?.toString(),
      'updated_at': updatedAt is Timestamp 
          ? (updatedAt as Timestamp).toDate().toIso8601String() 
          : updatedAt?.toString(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        role,
        status,
        authProvider,
        avatarUrl,
        email,
        isVerified,
        createdAt,
        updatedAt,
      ];
}