import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AppointmentModel>> getAppointmentsByPatient(
      String patientId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .get();

    final appointments = snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data(), doc.id))
        .toList();

    appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return appointments;
  }

  Future<List<AppointmentModel>> getAppointmentsByDoctor(String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    final appointments = snapshot.docs
        .map((doc) => AppointmentModel.fromJson(doc.data(), doc.id))
        .toList();

    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appointments;
  }

  Future<AppointmentModel> createAppointment(
      AppointmentModel appointment) async {
    final isLocked = await lockSlot(
      appointment.doctorId,
      appointment.dateTime,
      appointment.patientId,
    );

    if (!isLocked) {
      throw StateError('Khung gio da duoc dat hoac trung lich voi benh nhan.');
    }

    final docRef =
        await _firestore.collection('appointments').add(appointment.toJson());
    return AppointmentModel(
      id: docRef.id,
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      specialty: appointment.specialty,
      dateTime: appointment.dateTime,
      status: appointment.normalizedStatus,
      notes: appointment.notes,
      createdAt: DateTime.now(),
      queueNumber: appointment.queueNumber,
      estimatedWaitTimeMinutes: appointment.estimatedWaitTimeMinutes,
      checkInToken: appointment.checkInToken,
      paymentStatus: appointment.paymentStatus,
      priorityLevel: appointment.priorityLevel,
      statusUpdatedAt: DateTime.now(),
      checkedInAt: appointment.checkedInAt,
      completedAt: appointment.completedAt,
    );
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore.collection('appointments').doc(id).update({
      'status': AppointmentStatuses.normalize(status),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelAppointment(String id) async {
    await updateAppointmentStatus(id, AppointmentStatuses.cancelled);
  }

  Future<void> rescheduleAppointment(String id, DateTime newDate) async {
    await _firestore.collection('appointments').doc(id).update({
      'dateTime': Timestamp.fromDate(newDate),
      'status': AppointmentStatuses.rescheduled,
      'statusUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> lockSlot(
    String doctorId,
    DateTime dateTime,
    String patientId,
  ) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('dateTime', isEqualTo: Timestamp.fromDate(dateTime))
        .get();

    final hasDoctorConflict = snapshot.docs.any((doc) {
      final status = AppointmentStatuses.normalize(
        (doc.data()['status'] ?? AppointmentStatuses.pendingBooking).toString(),
      );
      return AppointmentStatuses.active.contains(status);
    });

    if (hasDoctorConflict) {
      return false;
    }

    final patientSnapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('dateTime', isEqualTo: Timestamp.fromDate(dateTime))
        .get();

    final hasPatientConflict = patientSnapshot.docs.any((doc) {
      final status = AppointmentStatuses.normalize(
        (doc.data()['status'] ?? AppointmentStatuses.pendingBooking).toString(),
      );
      return AppointmentStatuses.active.contains(status);
    });

    return !hasPatientConflict;
  }
}
