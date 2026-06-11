import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/doctor_model.dart';
import '../../domain/entities/doctor_entity.dart';

/// Top-rated doctors — cached for the app session (keepAlive prevents re-fetch on navigation).
final featuredDoctorsProvider = FutureProvider.autoDispose<List<DoctorEntity>>((ref) async {
  ref.keepAlive();

  final snap = await FirebaseFirestore.instance
      .collection('doctors')
      .orderBy('rating', descending: true)
      .limit(8)
      .get(const GetOptions(source: Source.serverAndCache));

  return snap.docs
      .map((doc) => DoctorModel.fromJson(doc.data(), doc.id))
      .where((d) => d.name.isNotEmpty)
      .toList();
});
