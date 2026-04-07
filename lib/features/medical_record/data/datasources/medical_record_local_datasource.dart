import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../domain/entities/encounter_fhir.dart';

abstract class MedicalRecordLocalDataSource {
  Future<void> cacheEncounters(List<EncounterFhir> encounters);
  Future<List<EncounterFhir>> getEncounters(String patientId);
}

class MedicalRecordLocalDataSourceImpl implements MedicalRecordLocalDataSource {
  final SQLiteHelper dbHelper;

  MedicalRecordLocalDataSourceImpl(this.dbHelper);

  @override
  Future<void> cacheEncounters(List<EncounterFhir> encounters) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    for (var encounter in encounters) {
      batch.insert(
        'encounters',
        {
          'id': encounter.id,
          'patientId': encounter.subject['reference']?.replaceAll('Patient/', '') ?? '',
          'lastUpdated': DateTime.now().toIso8601String(),
          'data': jsonEncode(encounter.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<EncounterFhir>> getEncounters(String patientId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'encounters',
      where: 'patientId = ?',
      whereArgs: [patientId],
    );

    return List.generate(maps.length, (i) {
      return EncounterFhir.fromJson(
        jsonDecode(maps[i]['data'] as String) as Map<String, dynamic>,
      );
    });
  }
}
