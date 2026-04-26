import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/hospital_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/clinic_room_entity.dart';
import '../../data/models/hospital_model.dart';
import '../../data/models/department_model.dart';
import '../../data/models/clinic_room_model.dart';
import '../../../doctor/patient_pov/domain/entities/doctor_entity.dart';
import '../../../doctor/patient_pov/data/models/doctor_model.dart';

final hospitalByIdProvider = FutureProvider.family<HospitalEntity?, String>((ref, hospitalId) async {
  debugPrint('[HospitalDetail] Fetching hospital $hospitalId');
  try {
    final doc = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .get();
    if (!doc.exists) {
      debugPrint('[HospitalDetail] Hospital $hospitalId not found');
      return null;
    }
    final data = doc.data()!;
    data['id'] = doc.id;
    return HospitalModel.fromJson(data);
  } catch (e) {
    debugPrint('[HospitalDetail] Error fetching hospital $hospitalId: $e');
    rethrow;
  }
});

final hospitalDepartmentsProvider = FutureProvider.family<List<DepartmentEntity>, String>((ref, hospitalId) async {
  debugPrint('[HospitalDetail] Fetching departments for $hospitalId');
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('departments')
        .orderBy('order')
        .get();
    debugPrint('[HospitalDetail] Found ${snapshot.docs.length} departments');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DepartmentModel.fromJson(data, doc.id);
    }).toList();
  } catch (e) {
    debugPrint('[HospitalDetail] Error fetching departments for $hospitalId: $e');
    rethrow;
  }
});

// Key is "{hospitalId}_{deptId}" to stay compatible with Dart 2 / older analysis
final departmentRoomsProvider = FutureProvider.family<List<ClinicRoomEntity>, String>((ref, key) async {
  final parts = key.split('_dept_');
  if (parts.length != 2) {
    debugPrint('[HospitalDetail] Invalid departmentRoomsProvider key: $key');
    return [];
  }
  final hospitalId = parts[0];
  final deptId = 'dept_${parts[1]}';
  debugPrint('[HospitalDetail] Fetching rooms for $hospitalId / $deptId');
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(hospitalId)
        .collection('departments')
        .doc(deptId)
        .collection('rooms')
        .get();
    debugPrint('[HospitalDetail] Found ${snapshot.docs.length} rooms');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ClinicRoomModel.fromJson(data, doc.id);
    }).toList();
  } catch (e) {
    debugPrint('[HospitalDetail] Error fetching rooms for $hospitalId/$deptId: $e');
    rethrow;
  }
});

String roomsProviderKey(String hospitalId, String deptId) {
  // deptId always starts with "dept_" so we split on "_dept_"
  // hospitalId never contains "_dept_"
  return '${hospitalId}_$deptId';
}

final departmentDoctorsProvider = FutureProvider.family<List<DoctorEntity>, String>((ref, departmentId) async {
  debugPrint('[HospitalDetail] Fetching doctors for department $departmentId');
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('departmentId', isEqualTo: departmentId)
        .get();
    debugPrint('[HospitalDetail] Found ${snapshot.docs.length} doctors for dept $departmentId');
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DoctorModel.fromJson(data, doc.id);
    }).toList();
  } catch (e) {
    debugPrint('[HospitalDetail] Error fetching doctors for dept $departmentId: $e');
    rethrow;
  }
});
