import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/clinic_model.dart';
import '../../../doctor/data/datasources/doctor_remote_datasource.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

class MapsRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get clinics from Firestore
  Future<List<ClinicModel>> getClinics() async {
    final snapshot = await _firestore.collection('clinics').get();
    return snapshot.docs
        .map((doc) => ClinicModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Get clinics derived from doctors data (using doctor locations as clinic locations)
  Future<List<ClinicModel>> getClinicsFromDoctors() async {
    final snapshot = await _firestore.collection('doctors').get();
    final Map<String, ClinicModel> clinicMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final hospital = data['hospital'] ?? '';
      if (hospital.isNotEmpty && !clinicMap.containsKey(hospital)) {
        clinicMap[hospital] = ClinicModel(
          id: doc.id,
          name: hospital,
          address: hospital,
          latitude: (data['latitude'] ?? 10.7769).toDouble(),
          longitude: (data['longitude'] ?? 106.7009).toDouble(),
          phone: data['phone'] ?? '',
          specialties: [data['specialty'] ?? ''],
        );
      }
    }

    return clinicMap.values.toList();
  }
}
