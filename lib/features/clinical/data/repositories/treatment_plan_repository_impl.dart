import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/medication_plan_item.dart';
import '../../domain/entities/treatment_plan.dart';
import '../../domain/repositories/treatment_plan_repository.dart';
import '../datasources/clinical_mock_datasource.dart';

class TreatmentPlanRepositoryImpl implements TreatmentPlanRepository {
  final ClinicalMockDataSource dataSource;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TreatmentPlanRepositoryImpl(this.dataSource);

  @override
  Future<TreatmentPlan> getTreatmentPlan(String encounterId) async {
    final docRef = _firestore.collection('treatment_plans').doc(encounterId);
    final doc = await docRef.get();

    if (!doc.exists) {
      // Seed dynamically to Firestore if not exists
      final mock = dataSource.getTreatmentPlan(encounterId);
      await docRef.set(_mapToMap(mock));
      return mock;
    }

    final data = doc.data()!;
    return _mapToPlan(encounterId, data);
  }

  @override
  Future<TreatmentPlan> saveTreatmentPlan(TreatmentPlan plan) async {
    final updated = plan.copyWith(updatedAt: DateTime.now());
    await _firestore.collection('treatment_plans').doc(plan.encounterId).set(_mapToMap(updated));
    return updated;
  }

  @override
  Future<File> exportTreatmentPlanPdf(TreatmentPlan plan) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'treatment_plan_${plan.encounterId}.pdf';
    final file = File('${directory.path}/$fileName');
    final pdfBytes = _buildPdfBytes(plan);
    await file.writeAsBytes(pdfBytes, flush: true);

    final updated = plan.copyWith(
      exportedPdfPath: file.path,
      updatedAt: DateTime.now(),
    );
    await saveTreatmentPlan(updated);
    return file;
  }

  Map<String, dynamic> _mapToMap(TreatmentPlan plan) {
    return {
      'patientId': plan.patientId,
      'patientName': plan.patientName,
      'patientCode': plan.patientCode,
      'patientAge': plan.patientAge,
      'patientGender': plan.patientGender,
      'diagnosisSummary': plan.diagnosisSummary,
      'icdCodes': plan.icdCodes,
      'medications': plan.medications.map((m) => {
        'name': m.name,
        'dosage': m.dosage,
        'timesPerDay': m.timesPerDay,
        'days': m.days,
        'notes': m.notes,
      }).toList(),
      'labTests': plan.labTests,
      'imagingTests': plan.imagingTests,
      'followUpDate': plan.followUpDate != null ? Timestamp.fromDate(plan.followUpDate!) : null,
      'notes': plan.notes,
      'exportedPdfPath': plan.exportedPdfPath,
      'updatedAt': Timestamp.fromDate(plan.updatedAt),
    };
  }

  TreatmentPlan _mapToPlan(String encounterId, Map<String, dynamic> data) {
    final medsRaw = data['medications'] as List<dynamic>? ?? const [];
    final medications = medsRaw.map((m) {
      final map = Map<String, dynamic>.from(m as Map);
      return MedicationPlanItem(
        name: map['name'] ?? '',
        dosage: map['dosage'] ?? '',
        timesPerDay: map['timesPerDay'] ?? 1,
        days: map['days'] ?? 7,
        notes: map['notes'] ?? '',
      );
    }).toList();

    return TreatmentPlan(
      id: 'plan-$encounterId',
      encounterId: encounterId,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientCode: data['patientCode'] ?? '',
      patientAge: data['patientAge'] ?? 54,
      patientGender: data['patientGender'] ?? 'Nam',
      diagnosisSummary: data['diagnosisSummary'] ?? '',
      icdCodes: List<String>.from(data['icdCodes'] ?? const []),
      medications: medications,
      labTests: List<String>.from(data['labTests'] ?? const []),
      imagingTests: List<String>.from(data['imagingTests'] ?? const []),
      followUpDate: data['followUpDate'] != null ? (data['followUpDate'] as Timestamp).toDate() : null,
      notes: data['notes'] ?? '',
      exportedPdfPath: data['exportedPdfPath'],
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  List<int> _buildPdfBytes(TreatmentPlan plan) {
    final lines = <String>[
      'Treatment Plan',
      'Patient Information',
      'Name: ${plan.patientName}',
      'Code: ${plan.patientCode}',
      'Age: ${plan.patientAge}',
      'Gender: ${plan.patientGender}',
      '',
      'Diagnosis',
      'Summary: ${plan.diagnosisSummary}',
      'ICD-10: ${plan.icdCodes.join(', ')}',
      '',
      'Medication',
      ...plan.medications.map(_formatMedicationLine),
      '',
      'Tests',
      'Lab: ${plan.labTests.join(', ')}',
      'Imaging: ${plan.imagingTests.join(', ')}',
      '',
      'Follow-up',
      'Date: ${plan.followUpDate == null ? 'N/A' : _formatDate(plan.followUpDate!)}',
      '',
      'Notes',
      plan.notes.isEmpty ? 'No notes' : plan.notes,
    ].map(_toAscii).toList();

    final content = StringBuffer();
    content.writeln('BT');
    content.writeln('/F1 12 Tf');
    content.writeln('50 780 Td');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].replaceAll('\\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
      if (i == 0) {
        content.writeln('($line) Tj');
      } else {
        content.writeln('0 -16 Td');
        content.writeln('($line) Tj');
      }
    }
    content.writeln('ET');

    final stream = utf8.encode(content.toString());
    final objects = <String>[
      '%PDF-1.4',
      '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj',
      '2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj',
      '3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj',
      '4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj',
      '5 0 obj << /Length ${stream.length} >> stream\n${content.toString()}endstream endobj',
    ];

    final buffer = StringBuffer();
    final offsets = <int>[];
    for (final object in objects) {
      offsets.add(utf8.encode(buffer.toString()).length);
      buffer.writeln(object);
    }
    final xrefOffset = utf8.encode(buffer.toString()).length;
    buffer.writeln('xref');
    buffer.writeln('0 ${objects.length + 1}');
    buffer.writeln('0000000000 65535 f ');
    for (final offset in offsets) {
      buffer.writeln('${offset.toString().padLeft(10, '0')} 00000 n ');
    }
    buffer.writeln('trailer << /Size ${objects.length + 1} /Root 1 0 R >>');
    buffer.writeln('startxref');
    buffer.writeln(xrefOffset);
    buffer.writeln('%%EOF');

    return utf8.encode(buffer.toString());
  }

  String _formatMedicationLine(MedicationPlanItem item) {
    return '${item.name} - ${item.dosage} - ${item.timesPerDay} times/day - ${item.days} days';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}';
  }

  String _toAscii(String input) {
    const mappings = <String, String>{
      'Đ': 'D',
      'đ': 'd',
      'Á': 'A',
      'À': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ắ': 'A',
      'Ằ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ấ': 'A',
      'Ầ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'É': 'E',
      'È': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ế': 'E',
      'Ề': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'Í': 'I',
      'Ì': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'Ó': 'O',
      'Ò': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ố': 'O',
      'Ồ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ớ': 'O',
      'Ờ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'Ú': 'U',
      'Ù': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ứ': 'U',
      'Ừ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'Ý': 'Y',
      'Ỳ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
    };

    var output = input;
    mappings.forEach((key, value) {
      output = output.replaceAll(key, value);
    });
    return output;
  }
}
