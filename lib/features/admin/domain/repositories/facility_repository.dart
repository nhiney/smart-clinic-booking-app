import '../entities/facility_entities.dart';

abstract class FacilityRepository {
  // Hospital
  Future<List<Hospital>> getAllHospitals();
  Future<void> addHospital(Hospital hospital);
  Future<void> updateHospital(Hospital hospital);
  Future<void> deleteHospital(String id);

  // Department
  Future<List<Department>> getDepartmentsByHospital(String hospitalId);
  Future<void> addDepartment(Department department);
  Future<void> deleteDepartment(String id);

  // Room
  Future<List<Room>> getRoomsByDepartment(String departmentId);
  Future<void> addRoom(Room room);
  Future<void> deleteRoom(String id);

  // Device
  Future<List<Device>> getDevicesByRoom(String roomId);
  Future<void> addDevice(Device device);
  Future<void> deleteDevice(String id);
}
