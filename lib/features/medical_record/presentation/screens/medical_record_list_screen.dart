import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/medical_history_provider.dart';
import 'medical_history_screen.dart';

class MedicalRecordListScreen extends ConsumerWidget {
  final String patientId;

  const MedicalRecordListScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This screen is now a wrapper for the History Timeline
    return MedicalHistoryScreen(patientId: patientId);
  }
}
