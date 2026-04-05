import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<AppointmentModel>> getAppointmentsByPatient(String patientId) async {
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

  Future<AppointmentModel> createAppointment(AppointmentModel appointment) async {
    final docRef = await _firestore
        .collection('appointments')
        .add(appointment.toJson());
    return AppointmentModel(
      id: docRef.id,
      patientId: appointment.patientId,
      patientName: appointment.patientName,
      doctorId: appointment.doctorId,
      doctorName: appointment.doctorName,
      specialty: appointment.specialty,
      dateTime: appointment.dateTime,
      status: appointment.status,
      notes: appointment.notes,
      createdAt: DateTime.now(),
    );
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await _firestore
        .collection('appointments')
        .doc(id)
        .update({'status': status});
  }

  Future<void> cancelAppointment(String id) async {
    await updateAppointmentStatus(id, 'cancelled');
  }
}
