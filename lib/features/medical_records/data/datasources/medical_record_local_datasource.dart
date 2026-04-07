import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/medical_record_model.dart';

abstract class IMedicalRecordLocalDataSource {
  Future<void> cacheRecords(List<MedicalRecordModel> recordsToCache, String patientId);
  Future<List<MedicalRecordModel>> getCachedRecords(String patientId);
}

class MedicalRecordLocalDataSourceImpl implements IMedicalRecordLocalDataSource {
  final SharedPreferences sharedPreferences;

  MedicalRecordLocalDataSourceImpl({required this.sharedPreferences});

  static const _cacheKeyPrefix = 'CACHED_MEDICAL_RECORDS_';

  @override
  Future<void> cacheRecords(
    List<MedicalRecordModel> recordsToCache,
    String patientId,
  ) async {
    final List<Map<String, dynamic>> recordsJsonList =
        recordsToCache.map((record) => record.toLocalJson()).toList();

    await sharedPreferences.setString(
      '$_cacheKeyPrefix$patientId',
      json.encode(recordsJsonList),
    );
  }

  @override
  Future<List<MedicalRecordModel>> getCachedRecords(String patientId) async {
    final jsonString = sharedPreferences.getString('$_cacheKeyPrefix$patientId');

    if (jsonString != null) {
      final List<dynamic> decodedJson = json.decode(jsonString);
      return decodedJson
          .map((json) => MedicalRecordModel.fromLocalJson(json))
          .toList();
    } else {
      throw CacheException(message: 'No cached medical records found.');
    }
  }
}
