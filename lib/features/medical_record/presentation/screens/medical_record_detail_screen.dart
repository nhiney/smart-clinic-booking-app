import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/encounter_fhir.dart';
import '../riverpod/medical_history_provider.dart';

class MedicalRecordDetailScreen extends ConsumerWidget {
  final String encounterId;

  const MedicalRecordDetailScreen({super.key, required this.encounterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, this would be a separate provider for a single encounter detail
    // For this exercise, I'll mock the detail view.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đợt khám'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showShareDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEncounterHeader(),
            const Divider(height: 32),
            _buildSectionHeader('Chẩn đoán', Icons.description),
            const Text(
              'Viêm họng cấp tính, có dấu hiệu sốt nhẹ. Cần theo dõi thêm và uống nhiều nước.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Kết quả xét nghiệm & Chỉ số', Icons.science),
            _buildObservationTile('Nhiệt độ cơ thể', '38.5 °C', Colors.orange),
            _buildObservationTile('Nhịp tim', '85 bpm', Colors.blue),
            _buildObservationTile('Huyết áp', '120/80 mmHg', Colors.green),
            const SizedBox(height: 24),
            _buildSectionHeader('Đơn thuốc (FHIR Medications)', Icons.medication),
            _buildMedicationTile('Paracetamol 500mg', 'Uống 1 viên khi sốt trên 38.5 độ.'),
            _buildMedicationTile('Amoxicillin 500mg', 'Uống 1 viên/lần, 2 lần/ngày sau ăn.'),
            const SizedBox(height: 24),
            _buildSectionHeader('Lịch sử phiên bản (Immutability)', Icons.history),
            _buildVersionTile('Phiên bản 2 (Hiện tại)', '2024-04-06 10:00', 'Bác sĩ Lê Văn B'),
            _buildVersionTile('Phiên bản 1 (Snapshot)', '2024-04-01 08:30', 'Bác sĩ Lê Văn B'),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.medical_information, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khám chuyên khoa Nội',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Phòng khám Đa khoa ICare - Quận 1'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildObservationTile(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }

  Widget _buildMedicationTile(String name, String dosage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.blue),
        title: Text(name),
        subtitle: Text(dosage),
      ),
    );
  }

  Widget _buildVersionTile(String version, String date, String author) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline, color: Colors.green),
      title: Text(version),
      subtitle: Text('$date - Bởi $author'),
      onTap: () {
        // Switch to this version View
      },
    );
  }

  void _showShareDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chia sẻ hồ sơ an toàn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tạo mã QR có hiệu lực trong 30 phút để bác sĩ khác quét và xem hồ sơ này.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Placeholder for QR Code
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      },
    );
  }
}
