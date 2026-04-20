import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/admission_entity.dart';
import '../riverpod/admission_provider.dart';

class AdmissionHistoryScreen extends ConsumerWidget {
  final String patientId;
  const AdmissionHistoryScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(admissionStreamProvider(patientId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admission History'),
        elevation: 0,
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admission/registration/$patientId'),
        label: const Text('New Request'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
      ),
      body: stream.when(
        data: (admissions) {
          if (admissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_hospital_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No admission records', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Your admission history will appear here',
                      style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: admissions.length,
            itemBuilder: (context, i) => _AdmissionCard(
              admission: admissions[i],
              patientId: patientId,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AdmissionCard extends ConsumerWidget {
  final AdmissionEntity admission;
  final String patientId;

  const _AdmissionCard({required this.admission, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(admission.reason,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                _StatusTimeline(status: admission.status),
                if (admission.wardInfo != null) ...[
                  const SizedBox(height: 12),
                  _WardInfoRow(wardInfo: admission.wardInfo!),
                ],
                if (admission.admissionDate != null || admission.estimatedDischargeDate != null) ...[
                  const SizedBox(height: 12),
                  _DatesRow(admission: admission),
                ],
                if (admission.notes != null && admission.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note_outlined, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(admission.notes!,
                              style: TextStyle(fontSize: 13, color: Colors.amber[900])),
                        ),
                      ],
                    ),
                  ),
                ],
                if (admission.documentUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _DocumentsSection(urls: admission.documentUrls),
                ],
                if (admission.status == 'pending') ...[
                  const SizedBox(height: 16),
                  _UploadButton(admission: admission, patientId: patientId),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final (color, icon, label) = _statusStyle(admission.status);
    final priorityColor = admission.priority == 'emergency'
        ? Colors.red
        : admission.priority == 'urgent'
            ? Colors.orange
            : Colors.green;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy – HH:mm').format(admission.createdAt),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ref: ${admission.id.length > 8 ? admission.id.substring(0, 8) : admission.id}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          _Chip(
            label: (admission.priority ?? 'normal').toUpperCase(),
            color: priorityColor,
          ),
          const SizedBox(width: 6),
          _Chip(
            label: label,
            color: color,
            icon: icon,
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _statusStyle(String status) {
    return switch (status) {
      'approved' => (Colors.blue, Icons.check_circle_outline, 'Approved'),
      'admitted' => (Colors.green, Icons.local_hospital, 'Admitted'),
      'discharged' => (Colors.purple, Icons.logout, 'Discharged'),
      'rejected' => (Colors.red, Icons.cancel_outlined, 'Rejected'),
      _ => (Colors.orange, Icons.schedule, 'Pending'),
    };
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({required this.status});

  static const _steps = ['pending', 'approved', 'admitted', 'discharged'];

  int get _currentIndex {
    final i = _steps.indexOf(status);
    return i == -1 ? 0 : i;
  }

  bool get _isRejected => status == 'rejected';

  @override
  Widget build(BuildContext context) {
    if (_isRejected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700], size: 16),
            const SizedBox(width: 8),
            Text('Request rejected by hospital',
                style: TextStyle(color: Colors.red[700], fontSize: 13)),
          ],
        ),
      );
    }

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final isPast = (i ~/ 2) < _currentIndex;
          return Expanded(
            child: Container(height: 2, color: isPast ? Colors.blue[600] : Colors.grey[300]),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex <= _currentIndex;
        final isCurrent = stepIndex == _currentIndex;
        return Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? Colors.blue[600] : Colors.grey[200],
                border: isCurrent ? Border.all(color: Colors.blue[900]!, width: 2) : null,
              ),
              child: isDone ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
            ),
            const SizedBox(height: 3),
            Text(
              _label(_steps[stepIndex]),
              style: TextStyle(
                fontSize: 9,
                color: isDone ? Colors.blue[700] : Colors.grey[400],
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  String _label(String step) => switch (step) {
        'pending' => 'Submitted',
        'approved' => 'Approved',
        'admitted' => 'Admitted',
        'discharged' => 'Discharged',
        _ => step,
      };
}

class _WardInfoRow extends StatelessWidget {
  final Map<String, dynamic> wardInfo;

  const _WardInfoRow({required this.wardInfo});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (wardInfo['name'] != null) parts.add('Ward: ${wardInfo['name']}');
    if (wardInfo['room'] != null) parts.add('Room: ${wardInfo['room']}');
    if (wardInfo['bed'] != null) parts.add('Bed: ${wardInfo['bed']}');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.bed, color: Colors.green[700], size: 16),
          const SizedBox(width: 8),
          Text(parts.join('  •  '), style: TextStyle(color: Colors.green[800], fontSize: 13)),
        ],
      ),
    );
  }
}

class _DatesRow extends StatelessWidget {
  final AdmissionEntity admission;

  const _DatesRow({required this.admission});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM dd, yyyy');
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (admission.admissionDate != null)
          _DateChip(
              label: 'Admission', date: fmt.format(admission.admissionDate!), color: Colors.blue),
        if (admission.estimatedDischargeDate != null)
          _DateChip(
              label: 'Est. Discharge',
              date: fmt.format(admission.estimatedDischargeDate!),
              color: Colors.orange),
        if (admission.actualDischargeDate != null)
          _DateChip(
              label: 'Discharged',
              date: fmt.format(admission.actualDischargeDate!),
              color: Colors.purple),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String date;
  final Color color;

  const _DateChip({required this.label, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 11, color: color),
          const SizedBox(width: 4),
          Text('$label: $date', style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  final List<String> urls;

  const _DocumentsSection({required this.urls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documents (${urls.length})',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: urls.map((url) {
            final raw = Uri.parse(url).pathSegments.last.split('?').first;
            final name = raw.length > 20 ? '${raw.substring(0, 20)}…' : raw;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_file, size: 13, color: Colors.blue[700]),
                  const SizedBox(width: 4),
                  Text(name, style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _UploadButton extends ConsumerStatefulWidget {
  final AdmissionEntity admission;
  final String patientId;

  const _UploadButton({required this.admission, required this.patientId});

  @override
  ConsumerState<_UploadButton> createState() => _UploadButtonState();
}

class _UploadButtonState extends ConsumerState<_UploadButton> {
  bool _uploading = false;

  Future<void> _upload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;

    setState(() => _uploading = true);
    final notifier = ref.read(admissionListProvider(widget.patientId).notifier);
    final ok = await notifier.uploadDocument(
      widget.admission.id,
      File(picked.path!),
      picked.name,
    );
    if (mounted) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Document uploaded' : 'Upload failed'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _uploading ? null : _upload,
      icon: _uploading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.upload_file, size: 18),
      label: Text(_uploading ? 'Uploading…' : 'Upload Supporting Document'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue[700],
        side: BorderSide(color: Colors.blue[300]!),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
