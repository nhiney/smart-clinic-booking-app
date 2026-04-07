import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../riverpod/admission_provider.dart';

class AdmissionRegistrationScreen extends ConsumerStatefulWidget {
  final String patientId;
  const AdmissionRegistrationScreen({super.key, required this.patientId});

  @override
  ConsumerState<AdmissionRegistrationScreen> createState() => _AdmissionRegistrationScreenState();
}

class _AdmissionRegistrationScreenState extends ConsumerState<AdmissionRegistrationScreen> {
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitRequest() async {
    if (_reasonController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    
    final notifier = ref.read(admissionListProvider(widget.patientId).notifier);
    await notifier.requestAdmission(
      patientId: widget.patientId,
      reason: _reasonController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admission request submitted successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inpatient Admission'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Request Admission',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the reason for inpatient admission. Our clinical team will review your request.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _reasonController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Enter reason for admission (e.g., Surgery scheduled, Post-op recovery...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
