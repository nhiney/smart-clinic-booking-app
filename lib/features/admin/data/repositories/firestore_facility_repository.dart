// lib/features/admin/data/repositories/firestore_facility_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/facility_entities.dart';
import '../../domain/repositories/facility_repository.dart';

@LazySingleton(as: FacilityRepository)
class FirestoreFacilityRepository implements FacilityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================================================================
  // 1. DASHBOARD OVERVIEW - GIẢI PHÁP TỐI ƯU HÓA KHÔNG CẦN COMPOSITE INDEX
  // =========================================================================
  @override
  Future<AdminDashboardEntity> getAdminDashboardData(String period) async {
    try {
      final now = DateTime.now();
      late DateTime startOfCurrentPeriod;
      late DateTime startOfPreviousPeriod;
      int days = 7;

      if (period == '30 ngày') {
        days = 30;
      } else if (period == 'Quý') {
        days = 90;
      } else if (period == 'Năm') {
        days = 365;
      }

      startOfCurrentPeriod = now.subtract(Duration(days: days));
      startOfPreviousPeriod = now.subtract(Duration(days: days * 2));

      String adminName = "Admin";
      String facilityName = "Hệ thống";
      final systemConfig = await _firestore.collection('system_settings').doc('overview').get();
      if (systemConfig.exists && systemConfig.data() != null) {
        adminName = systemConfig.data()?['currentAdminName'] ?? adminName;
        facilityName = systemConfig.data()?['facilityName'] ?? facilityName;
      }

      final appointmentStat = await _calculateDynamicStats('appointments', 'createdAt', startOfCurrentPeriod, startOfPreviousPeriod, now, isRevenue: false, days: days);
      final hospitalStat = await _calculateDynamicStats('hospitals', 'createdAt', startOfCurrentPeriod, startOfPreviousPeriod, now, isRevenue: false, days: days);
      final doctorStat = await _calculateDynamicStats('doctors', 'createdAt', startOfCurrentPeriod, startOfPreviousPeriod, now, isRevenue: false, days: days);
      final patientStat = await _calculateDynamicStats('users', 'createdAt', startOfCurrentPeriod, startOfPreviousPeriod, now, isRevenue: false, days: days, extraFilterField: 'role', extraFilterValue: 'patient');
      final revenueStat = await _calculateDynamicStats('appointments', 'createdAt', startOfCurrentPeriod, startOfPreviousPeriod, now, isRevenue: true, days: days);

      double systemUptime = systemConfig.data()?['uptime']?.toDouble() ?? 99.98;

      return AdminDashboardEntity(
        adminName: adminName,
        facilityName: facilityName,
        systemUptime: systemUptime,
        lastUpdated: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        appointments: appointmentStat,
        hospitals: hospitalStat,
        doctors: doctorStat,
        patients: patientStat,
        revenue: revenueStat,
      );
    } catch (e) {
      throw Exception('Lỗi khi xử lý dữ liệu động tổng quan: $e');
    }
  }

  Future<StatItemEntity> _calculateDynamicStats(
    String collectionPath,
    String timestampField,
    DateTime currentStart,
    DateTime previousStart,
    DateTime now, {
    required bool isRevenue,
    required int days,
    String? extraFilterField,
    String? extraFilterValue,
  }) async {
    Query baseQuery = _firestore.collection(collectionPath);
    if (extraFilterField != null && extraFilterValue != null) {
      baseQuery = baseQuery.where(extraFilterField, isEqualTo: extraFilterValue);
    }

    final querySnapshot = await baseQuery.get();
    final allDocs = querySnapshot.docs;

    double currentValue = 0;
    double previousValue = 0;

    int intervalDays = (days / 6).floor();
    if (intervalDays < 1) intervalDays = 1;

    List<DateTime> checkpoints = List.generate(7, (i) => now.subtract(Duration(days: (6 - i) * intervalDays)));
    List<double> chartData = List.filled(7, 0.0);

    for (var doc in allDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = (data[timestampField] as Timestamp?)?.toDate();
      if (timestamp == null) continue;

      final price = data['price']?.toDouble() ?? 0.0;

      if (isRevenue) {
        if (timestamp.isAfter(currentStart) && timestamp.isBefore(now)) {
          currentValue += price;
        }
        if (timestamp.isAfter(previousStart) && timestamp.isBefore(currentStart)) {
          previousValue += price;
        }
      } else {
        if (timestamp.isBefore(now)) currentValue++;
        if (timestamp.isBefore(currentStart)) previousValue++;
      }

      for (int i = 0; i < 7; i++) {
        if (isRevenue) {
          DateTime stepStart = checkpoints[i].subtract(Duration(days: intervalDays));
          if (timestamp.isAfter(stepStart) && timestamp.isBefore(checkpoints[i])) {
            chartData[i] += price;
          }
        } else {
          if (timestamp.isBefore(checkpoints[i])) {
            chartData[i]++;
          }
        }
      }
    }

    int absoluteChange = (currentValue - previousValue).toInt();
    double percentageChange = 0.0;
    if (previousValue > 0) {
      percentageChange = double.parse(((absoluteChange / previousValue) * 100).toStringAsFixed(1));
    }

    return StatItemEntity(
      value: currentValue,
      percentageChange: percentageChange,
      absoluteChange: absoluteChange,
      chartData: chartData,
    );
  }

  @override
  Future<List<Hospital>> getAllHospitals() async {
    final snapshot = await _firestore.collection('hospitals').get();
    return snapshot.docs.map((doc) => Hospital.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addHospital(Hospital hospital) async {
    await _firestore.collection('hospitals').doc(hospital.id).set(hospital.toMap());
  }

  @override
  Future<void> updateHospital(Hospital hospital) async {
    await _firestore.collection('hospitals').doc(hospital.id).update(hospital.toMap());
  }

  @override
  Future<void> deleteHospital(String id) async {
    await _firestore.collection('hospitals').doc(id).delete();
  }

  @override
  Future<List<Department>> getDepartmentsByHospital(String hospitalId) async {
    try {
      final snapshot = await _firestore
          .collection('hospitals')
          .doc(hospitalId)
          .collection('departments')
          .get();
          
      return snapshot.docs.map((doc) => Department.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách khoa từ subcollection: $e');
    }
  }

  @override
  Future<void> addDepartment(Department department) async {
    await _firestore.collection('departments').doc(department.id).set(department.toMap());
  }

  @override
  Future<void> deleteDepartment(String id) async {
    await _firestore.collection('departments').doc(id).delete();
  }

  @override
  Future<List<Room>> getRoomsByDepartment(String departmentId) async {
    try {
      final deptsSnapshot = await _firestore.collectionGroup('departments').get();
      DocumentReference? deptRef;
      
      for (var doc in deptsSnapshot.docs) {
        if (doc.id == departmentId) {
          deptRef = doc.reference;
          break;
        }
      }

      if (deptRef != null) {
        final snapshot = await deptRef.collection('rooms').get();
            
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['departmentId'] = departmentId;
          return Room.fromMap(data, doc.id);
        }).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách phòng: $e');
    }
  }

  @override
  Future<void> addRoom(Room room) async {
    try {
      final deptsSnapshot = await _firestore.collectionGroup('departments').get();
      DocumentReference? deptRef;
      
      for (var doc in deptsSnapshot.docs) {
        if (doc.id == room.departmentId) {
          deptRef = doc.reference;
          break;
        }
      }

      if (deptRef != null) {
        await deptRef.collection('rooms').doc(room.id).set(room.toMap());
      } else {
        throw Exception('Không tìm thấy khoa cha trên hệ thống để thiết lập phòng khám');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm phòng: $e');
    }
  }

  @override
  Future<void> deleteRoom(String id) async {
    await _firestore.collection('rooms').doc(id).delete();
  }

  @override
  Future<List<Device>> getDevicesByRoom(String roomId) async {
    final snapshot = await _firestore
        .collection('devices')
        .where('roomId', isEqualTo: roomId)
        .get();
    return snapshot.docs.map((doc) => Device.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addDevice(Device device) async {
    await _firestore.collection('devices').doc(device.id).set(device.toMap());
  }

  @override
  Future<void> deleteDevice(String id) async {
    await _firestore.collection('devices').doc(id).delete();
  }

  @override
  Future<List<Patient>> getPatientsByDepartment(String departmentId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();
          
      final List<Patient> patientList = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dbDeptId = data['department_id'] ?? data['departmentId'] ?? '';
        
        if (dbDeptId == departmentId) {
          patientList.add(Patient.fromMap(data, doc.id));
        }
      }
      return patientList;
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách bệnh nhân từ collection users: $e');
    }
  }
}