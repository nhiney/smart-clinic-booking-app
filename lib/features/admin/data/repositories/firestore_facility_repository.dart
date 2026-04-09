import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/facility_entities.dart';
import '../../domain/repositories/facility_repository.dart';

@LazySingleton(as: FacilityRepository)
class FirestoreFacilityRepository implements FacilityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final snapshot = await _firestore
        .collection('departments')
        .where('hospitalId', isEqualTo: hospitalId)
        .get();
    return snapshot.docs.map((doc) => Department.fromMap(doc.data(), doc.id)).toList();
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
    final snapshot = await _firestore
        .collection('rooms')
        .where('departmentId', isEqualTo: departmentId)
        .get();
    return snapshot.docs.map((doc) => Room.fromMap(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addRoom(Room room) async {
    await _firestore.collection('rooms').doc(room.id).set(room.toMap());
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
}
