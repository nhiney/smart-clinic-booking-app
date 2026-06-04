import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/examination_result.dart';
// Import đúng enum trạng thái từ feature appointment của bạn
import '../../../../appointment/domain/entities/appointment_entity.dart';

class ExaminationRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveExamination(ExaminationResult exam) async {
    final batch = _firestore.batch();

    // 1) Tạo mới một Document ID ngẫu nhiên trong bảng kết quả khám
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

    // 2) Đổi trạng thái lịch hẹn tương ứng thành 'completed'
    final aptRef = _firestore.collection('appointments').doc(exam.appointmentId);
    batch.update(aptRef, {
      'status': AppointmentStatuses.completed, // Trỏ tới enum trạng thái hoàn tất lịch hẹn của bạn
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Thực thi đồng thời cả 2 lệnh trên lên Firebase
    await batch.commit();
    return recordRef.id;
  }
}