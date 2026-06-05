import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/examination_result.dart';

class ExaminationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveExamination(ExaminationResult exam) async {
    // Sử dụng cơ chế WriteBatch đảm bảo giao dịch nguyên tử (Atomic Transaction)
    final batch = _firestore.batch();

    // 1) Tạo document kết quả khám mới trong collection 'medical_records'
    final recordRef = _firestore.collection('medical_records').doc();
    batch.set(recordRef, {
      'appointmentId': exam.appointmentId,
      'patientId': exam.patientId,
      'patientName': exam.patientName,
      'doctorId': exam.doctorId,
      'doctorName': exam.doctorName,
      'diagnosis': exam.diagnosis,
      'prescription': exam.prescription,
      'notes': exam.notes,
      'examinedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    final aptRef = _firestore.collection('appointments').doc(exam.appointmentId);
    batch.update(aptRef, {
      'status': 'completed',
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return recordRef.id;
  }
}