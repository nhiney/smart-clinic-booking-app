import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../riverpod/medical_history_provider.dart';
import '../../domain/entities/encounter_fhir.dart';

class MedicalHistoryScreen extends ConsumerWidget {
  final String patientId;

  const MedicalHistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(medicalHistoryProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử khám bệnh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(medicalHistoryProvider(patientId).notifier).refresh(),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (encounters) => encounters.isEmpty
            ? const Center(child: Text('Chưa có lịch sử khám nào.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: encounters.length,
                itemBuilder: (context, index) {
                  return _EncounterTimelineTile(
                    encounter: encounters[index],
                    isFirst: index == 0,
                    isLast: index == encounters.length - 1,
                  );
                },
              ),
        error: (err, stack) => Center(child: Text('Đã có lỗi xảy ra: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EncounterTimelineTile extends StatelessWidget {
  final EncounterFhir encounter;
  final bool isFirst;
  final bool isLast;

  const _EncounterTimelineTile({
    required this.encounter,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final startDate = encounter.period['start'];
    final dateStr = startDate != null ? DateFormat('dd/MM/yyyy').format(startDate) : 'N/A';
    final timeStr = startDate != null ? DateFormat('HH:mm').format(startDate) : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 2,
              height: 20,
              color: isFirst ? Colors.transparent : Colors.grey[300],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.medical_services, size: 16, color: Colors.white),
            ),
            Container(
              width: 2,
              height: 100,
              color: isLast ? Colors.transparent : Colors.grey[300],
            ),
          ],
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, top: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    Text(
                      timeStr,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  encounter.reasonCode.isNotEmpty 
                      ? encounter.reasonCode.first['text'] ?? 'Khám định kỳ'
                      : 'Khám định kỳ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bác sĩ: ${encounter.participant.isNotEmpty ? encounter.participant.first['individual']['display'] ?? 'N/A' : 'N/A'}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to details
                    },
                    child: const Text('Xem chi tiết'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
