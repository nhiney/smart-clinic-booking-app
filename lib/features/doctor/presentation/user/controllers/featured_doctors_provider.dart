import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/doctor_model.dart';
import '../../../domain/entities/doctor_entity.dart';

/// Top-rated doctors from the `doctors` Firestore collection.
/// Returns up to 8 doctors ordered by rating descending.
final featuredDoctorsProvider = FutureProvider<List<DoctorEntity>>((ref) async {
  final snap = await FirebaseFirestore.instance
      .collection('doctors')
      .orderBy('rating', descending: true)
      .limit(8)
      .get();

  return snap.docs
      .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
      .where((d) => d.name.isNotEmpty)
      .toList();
});
