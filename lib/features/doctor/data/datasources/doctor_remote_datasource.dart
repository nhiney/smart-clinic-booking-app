import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DoctorRemoteDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DoctorModel>> getDoctors() async {
    final snapshot = await _firestore.collection('doctors').get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    final doc = await _firestore.collection('doctors').doc(id).get();
    if (!doc.exists) return null;
    return DoctorModel.fromJson(doc.data()!, doc.id);
  }

  Future<List<DoctorModel>> searchDoctors(String query) async {
    final snapshot = await _firestore.collection('doctors').get();
    final lowerQuery = query.toLowerCase();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .where((doctor) =>
            doctor.name.toLowerCase().contains(lowerQuery) ||
            doctor.specialty.toLowerCase().contains(lowerQuery) ||
            doctor.hospital.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    final snapshot = await _firestore
        .collection('doctors')
        .where('specialty', isEqualTo: specialty)
        .get();
    return snapshot.docs
        .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Seed sample doctors for development
  Future<void> seedDoctors() async {
    final collection = _firestore.collection('doctors');
    final snapshot = await collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return; // Already seeded

    final sampleDoctors = [
      {
        'name': 'BS. Nguyễn Văn An',
        'specialty': 'Tim mạch',
        'hospital': 'Bệnh viện Chợ Rẫy',
        'imageUrl': '',
        'rating': 4.8,
        'experience': 15,
        'about': 'Chuyên gia tim mạch hàng đầu với 15 năm kinh nghiệm. Tốt nghiệp Đại học Y Dược TP.HCM.',
        'latitude': 10.7552,
        'longitude': 106.6602,
        'phone': '0901234567',
        'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6'],
        'availableTimeSlots': ['08:00', '09:00', '10:00', '14:00', '15:00'],
      },
      {
        'name': 'BS. Trần Thị Bình',
        'specialty': 'Da liễu',
        'hospital': 'Bệnh viện Da Liễu',
        'imageUrl': '',
        'rating': 4.6,
        'experience': 10,
        'about': 'Bác sĩ chuyên khoa Da liễu, giàu kinh nghiệm điều trị các bệnh về da.',
        'latitude': 10.7769,
        'longitude': 106.6951,
        'phone': '0901234568',
        'availableDays': ['Thứ 3', 'Thứ 5', 'Thứ 7'],
        'availableTimeSlots': ['08:30', '09:30', '10:30', '14:30', '15:30'],
      },
      {
        'name': 'BS. Lê Hoàng Cường',
        'specialty': 'Thần kinh',
        'hospital': 'Bệnh viện 115',
        'imageUrl': '',
        'rating': 4.9,
        'experience': 20,
        'about': 'Phó giáo sư, Tiến sĩ Thần kinh học. Chuyên gia đầu ngành về thần kinh.',
        'latitude': 10.7879,
        'longitude': 106.6659,
        'phone': '0901234569',
        'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 5'],
        'availableTimeSlots': ['07:30', '08:30', '09:30', '13:30', '14:30'],
      },
      {
        'name': 'BS. Phạm Minh Đức',
        'specialty': 'Nhi khoa',
        'hospital': 'Bệnh viện Nhi Đồng 1',
        'imageUrl': '',
        'rating': 4.7,
        'experience': 12,
        'about': 'Bác sĩ Nhi khoa tận tâm, chuyên điều trị các bệnh ở trẻ em.',
        'latitude': 10.7690,
        'longitude': 106.6802,
        'phone': '0901234570',
        'availableDays': ['Thứ 2', 'Thứ 4', 'Thứ 6', 'Thứ 7'],
        'availableTimeSlots': ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00'],
      },
      {
        'name': 'BS. Vũ Thị Em',
        'specialty': 'Mắt',
        'hospital': 'Bệnh viện Mắt TP.HCM',
        'imageUrl': '',
        'rating': 4.5,
        'experience': 8,
        'about': 'Bác sĩ nhãn khoa, chuyên phẫu thuật và điều trị các bệnh về mắt.',
        'latitude': 10.7861,
        'longitude': 106.6835,
        'phone': '0901234571',
        'availableDays': ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5'],
        'availableTimeSlots': ['08:00', '09:00', '10:00', '14:00'],
      },
    ];

    for (final doctor in sampleDoctors) {
      await collection.add(doctor);
    }
  }
}
