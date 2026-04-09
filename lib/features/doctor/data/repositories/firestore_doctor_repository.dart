import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/repositories/doctor_repository.dart';

class FirestoreDoctorRepository implements DoctorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DoctorEntity>> getDoctors() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return DoctorEntity(
        id: doc.id,
        name: data['name'] ?? 'Bác sĩ',
        specialty: data['specialty'] ?? 'Đang cập nhật',
        hospital: data['tenant_id'] ?? data['hospital_id'] ?? '',
        phone: data['phone'] ?? '',
        experience: data['experience_years'] ?? 0,
        about: data['bio'] ?? data['description'] ?? '',
      );
    }).toList();
  }

  @override
  Future<List<DoctorEntity>> getUnassignedDoctors() async {
    final allDoctors = await getDoctors();
    return allDoctors.where((d) => d.hospital.isEmpty).toList();
  }

  @override
  Future<void> assignDoctorToDepartment({
    required String doctorId,
    required String hospitalId,
    required String departmentId,
  }) async {
    await _firestore.collection('doctors').doc(doctorId).set({
      'doctorId': doctorId,
      'hospitalId': hospitalId,
      'departmentId': departmentId,
      // Keep existing fields if necessary (could use update with merge)
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateDoctorProfile(DoctorEntity doctor) async {
    // For now, only updating 'doctors' collection metadata
    await _firestore.collection('doctors').doc(doctor.id).set({
      'specialty': doctor.specialty,
      'experienceYears': doctor.experience,
      'bio': doctor.about,
    }, SetOptions(merge: true));
  }

  @override
  Future<DoctorEntity?> getDoctorProfile(String doctorId) async {
    final doc = await _firestore.collection('users').doc(doctorId).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return DoctorEntity(
      id: doctorId,
      name: data['name'] ?? 'Bác sĩ',
      specialty: data['specialty'] ?? 'Đang cập nhật',
      hospital: data['tenant_id'] ?? data['hospital_id'] ?? '',
      phone: data['phone'] ?? '',
      experience: data['experience_years'] ?? 0,
      about: data['bio'] ?? data['description'] ?? '',
    );
  }
}
