import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../domain/repositories/maps_repository.dart';
import '../models/hospital_model.dart';
import '../../domain/entities/hospital_entity.dart';

class MapsRepositoryImpl implements MapsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SQLiteHelper _sqliteHelper = SQLiteHelper.instance;

  @override
  Future<List<HospitalEntity>> getHospitals() async {
    try {
      // 1. Try to fetch from Firestore
      final snapshot = await _firestore.collection('hospitals').get();
      final hospitals = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return HospitalModel.fromJson(data);
      }).toList();

      // 2. Cache the data to SQLite
      await _cacheHospitals(hospitals);

      return hospitals;
    } catch (e) {
      // 3. Fallback to SQLite if network fails
      return _getCachedHospitals();
    }
  }

  Future<void> _cacheHospitals(List<HospitalModel> hospitals) async {
    final db = await _sqliteHelper.database;
    final batch = db.batch();

    // Clear old cache
    batch.delete('hospitals_cache');

    for (var hospital in hospitals) {
      batch.insert('hospitals_cache', {
        'id': hospital.id,
        'data': jsonEncode(hospital.toJson()),
      });
    }

    await batch.commit(noResult: true);
  }

  Future<List<HospitalEntity>> _getCachedHospitals() async {
    final db = await _sqliteHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('hospitals_cache');

    return maps.map((map) {
      return HospitalModel.fromJson(jsonDecode(map['data'] as String));
    }).toList();
  }
}
