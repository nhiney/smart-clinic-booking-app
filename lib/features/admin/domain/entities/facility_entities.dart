import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Hospital extends Equatable {
  final String id;
  final String name;
  final String address;
  final String logoUrl;
  final String imageUrl;
  final String description;
  final String phone;
  final String workingHours;
  final List<String> specialties;
  final double rating;
  final bool isOpen;
  final bool featured;

  const Hospital({
    required this.id,
    required this.name,
    this.address = '',
    this.logoUrl = '',
    this.imageUrl = '',
    this.description = '',
    this.phone = '',
    this.workingHours = '',
    this.specialties = const [],
    this.rating = 0.0,
    this.isOpen = true,
    this.featured = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'logoUrl': logoUrl,
      'imageUrl': imageUrl,
      'description': description,
      'phone': phone,
      'workingHours': workingHours,
      'specialties': specialties,
      'rating': rating,
      'isOpen': isOpen,
      'featured': featured,
    };
  }

  factory Hospital.fromMap(Map<String, dynamic> map, String id) {
    return Hospital(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      workingHours: map['workingHours'] ?? '',
      specialties: (map['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      isOpen: map['isOpen'] ?? true,
      featured: map['featured'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, address, logoUrl, imageUrl, description, phone, workingHours, specialties, rating, isOpen, featured];
}

class Department extends Equatable {
  final String id;
  final String hospitalId;
  final String name;
  final String description;

  const Department({
    required this.id,
    required this.hospitalId,
    required this.name,
    this.description = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hospitalId': hospitalId,
      'name': name,
      'description': description,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map, String id) {
    return Department(
      id: id,
      hospitalId: map['hospitalId'] ?? map['tenant_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, hospitalId, name, description];
}

class Room extends Equatable {
  final String id;
  final String departmentId;
  final String name;
  final String type;
  final String? floor;
  final String? status;
  final String? workingHours;

  const Room({
    required this.id,
    required this.departmentId,
    required this.name,
    required this.type,
    this.floor,
    this.status,
    this.workingHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departmentId': departmentId,
      'name': name,
      'type': type,
      'floor': floor,
      'status': status,
      'workingHours': workingHours,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map, String id) {
    return Room(
      id: id,
      departmentId: map['departmentId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'Examination',
      floor: map['floor'] ?? 'Chưa rõ tầng',
      status: map['status'] ?? 'unknown',
      workingHours: map['workingHours'] ?? 'Chưa cấu hình giờ',
    );
  }

  @override
  List<Object?> get props => [id, departmentId, name, type, floor, status, workingHours];
}

class Device extends Equatable {
  final String id;
  final String roomId;
  final String name;
  final String status;

  const Device({
    required this.id,
    required this.roomId,
    required this.name,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'name': name,
      'status': status,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map, String id) {
    return Device(
      id: id,
      roomId: map['roomId'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? 'active',
    );
  }

  @override
  List<Object?> get props => [id, roomId, name, status];
}

class StatItemEntity extends Equatable {
  final double value;
  final double percentageChange;
  final int absoluteChange;
  final List<double> chartData;

  const StatItemEntity({
    required this.value,
    required this.percentageChange,
    required this.absoluteChange,
    required this.chartData,
  });

  @override
  List<Object?> get props => [value, percentageChange, absoluteChange, chartData];
}

class AdminDashboardEntity extends Equatable {
  final String adminName;
  final String facilityName;
  final double systemUptime;
  final String lastUpdated;
  final StatItemEntity appointments;
  final StatItemEntity hospitals;
  final StatItemEntity doctors;
  final StatItemEntity patients;
  final StatItemEntity revenue;

  const AdminDashboardEntity({
    required this.adminName,
    required this.facilityName,
    required this.systemUptime,
    required this.lastUpdated,
    required this.appointments,
    required this.hospitals,
    required this.doctors,
    required this.patients,
    required this.revenue,
  });

  AdminDashboardEntity copyWith({
    String? adminName,
    String? facilityName,
    double? systemUptime,
    String? lastUpdated,
    StatItemEntity? appointments,
    StatItemEntity? hospitals,
    StatItemEntity? doctors,
    StatItemEntity? patients,
    StatItemEntity? revenue,
  }) {
    return AdminDashboardEntity(
      adminName: adminName ?? this.adminName,
      facilityName: facilityName ?? this.facilityName,
      systemUptime: systemUptime ?? this.systemUptime,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      appointments: appointments ?? this.appointments,
      hospitals: hospitals ?? this.hospitals,
      doctors: doctors ?? this.doctors,
      patients: patients ?? this.patients,
      revenue: revenue ?? this.revenue,
    );
  }

  @override
  List<Object?> get props => [adminName, facilityName, systemUptime, lastUpdated, appointments, hospitals, doctors, patients, revenue];
}

class Patient extends Equatable {
  final String id;
  final String hospitalId;
  final String departmentId;
  final String name;
  final String phone;
  final String address;
  final String assignedDoctor;
  final String bloodType;
  final String diagnosis;
  final List<String> diagnoses;
  final String medicalHistory;
  final String insuranceId;
  final List<String> allergies;
  final DateTime? dateOfBirth;
  final String lastVisit;
  final bool isVip; 
  final int totalVisits; 
  final String status;

  const Patient({
    required this.id,
    this.hospitalId = '',
    required this.departmentId,
    required this.name,
    required this.phone,
    this.address = '',
    this.assignedDoctor = 'Chưa chỉ định',
    this.bloodType = 'Unk',
    this.diagnosis = 'Chưa có chẩn đoán',
    this.diagnoses = const [],
    this.medicalHistory = 'Không có',
    this.insuranceId = '',
    this.allergies = const [],
    this.dateOfBirth,
    this.lastVisit = 'Chưa rõ',
    this.isVip = false,
    this.totalVisits = 0,
    this.status = 'active',
  });

  int get age {
    if (dateOfBirth == null) return 0;
    return 2026 - dateOfBirth!.year;
  }

  String get code {
    if (insuranceId.isNotEmpty && insuranceId.length >= 6) {
      return insuranceId.substring(0, 6);
    }
    return id.length > 5 ? id.substring(0, 5) : id;
  }

  factory Patient.fromMap(Map<String, dynamic> map, String id) {
    List<String> parsedDiagnoses = [];
    String singleDiag = map['diagnosis'] ?? 'Khám tổng quát';
    if (map['diagnoses'] is List) {
      parsedDiagnoses = (map['diagnoses'] as List).map((e) => e.toString()).toList();
    } else if (map['diagnosis'] != null && map['diagnosis'].toString().isNotEmpty) {
      parsedDiagnoses = [map['diagnosis'].toString()];
    } else {
      parsedDiagnoses = ['Khám tổng quát'];
    }

    String cleanLastVisitStr = 'Chưa rõ';
    int calculatedVisits = 0;
    if (map['last_visit'] != null) {
      try {
        calculatedVisits = 1;
        final DateTime dt = (map['last_visit'] as Timestamp).toDate();
        cleanLastVisitStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      } catch (_) {
        cleanLastVisitStr = map['last_visit'].toString().split(' ')[0];
      }
    }

    return Patient(
      id: id,
      hospitalId: map['tenant_id'] ?? map['hospitalId'] ?? '',
      departmentId: map['department_id'] ?? map['departmentId'] ?? '',
      name: map['name'] ?? 'Vô danh',
      phone: map['phone'] ?? 'Chưa có SĐT',
      address: map['address'] ?? 'Chưa cập nhật địa chỉ',
      assignedDoctor: map['assigned_doctor'] ?? 'Chưa chỉ định',
      bloodType: map['blood_type'] ?? 'Unk',
      diagnosis: singleDiag,
      diagnoses: parsedDiagnoses,
      medicalHistory: map['medical_history'] ?? 'Không có',
      insuranceId: map['insurance_id'] ?? '',
      allergies: (map['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dateOfBirth: (map['date_of_birth'] as Timestamp?)?.toDate(),
      lastVisit: cleanLastVisitStr,
      isVip: map['is_verified'] ?? map['seed'] ?? map['isVip'] ?? false,
      totalVisits: map['totalVisits'] ?? calculatedVisits,
      status: map['status'] ?? 'active', 
    );
  }

  @override
  List<Object?> get props => [id, hospitalId, departmentId, name, phone, address, assignedDoctor, bloodType, diagnosis, diagnoses, medicalHistory, insuranceId, allergies, dateOfBirth, lastVisit, isVip, totalVisits, status]; // 🌟 Thêm status vào props so sánh
}