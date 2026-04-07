import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../riverpod/admission_provider.dart';
import '../../domain/entities/admission_entity.dart';
import 'package:intl/intl.dart';

class AdmissionHistoryScreen extends ConsumerWidget {
  final String patientId;
  const AdmissionHistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final admissionListAsync = ref.watch(admissionListProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission History'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: admissionListAsync.when(
        data: (admissions) {
          if (admissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No admission history found.', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/admission/registration/$patientId'),
                    icon: const Icon(Icons.add),
                    label: const Text('Request Admission'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: admissions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final admission = admissions[index];
              return _AdmissionCard(admission: admission);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admission/registration/$patientId'),
        label: const Text('New Request'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
    );
  }
}

class _AdmissionCard extends StatelessWidget {
  final AdmissionEntity admission;
  const _AdmissionCard({required this.admission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusBadge(status: admission.status),
              Text(
                DateFormat('MMM dd, yyyy').format(admission.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            admission.reason,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (admission.wardInfo != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.blue[800]),
                const SizedBox(width: 8),
                Text(
                  'Ward ${admission.wardInfo!['building']}${admission.wardInfo!['floor']} - Room ${admission.wardInfo!['room']}',
                  style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'approved': color = Colors.blue; break;
      case 'admitted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      case 'discharged': color = Colors.grey; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
