import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/medical_record.dart';
import '../bloc/medical_record_bloc.dart';
import '../bloc/medical_record_event.dart';
import '../bloc/medical_record_state.dart';
import 'record_detail_screen.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final String patientId;

  const MedicalRecordsScreen({super.key, required this.patientId});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  void _fetchRecords() {
    context.read<MedicalRecordBloc>().add(FetchRecordsEvent(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Hồ sơ bệnh án',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocBuilder<MedicalRecordBloc, MedicalRecordState>(
        builder: (context, state) {
          if (state is MedicalRecordInitial || state is MedicalRecordLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MedicalRecordError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchRecords,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MedicalRecordsLoaded) {
            return Column(
              children: [
                if (state.isOffline)
                  Container(
                    width: double.infinity,
                    color: AppColors.warning.withOpacity(0.9),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Đang hiển thị dữ liệu ngoại tuyến',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _fetchRecords(),
                    child: state.records.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                              const Center(
                                child: Text(
                                  'Chưa có hồ sơ bệnh án nào.',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: state.records.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _RecordCard(record: state.records[index]);
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;

  const _RecordCard({required this.record});

  String _getTypeLabel(MedicalRecordType type) {
    switch (type) {
      case MedicalRecordType.prescription:
        return 'Đơn thuốc';
      case MedicalRecordType.labResult:
        return 'Kết quả xét nghiệm';
      case MedicalRecordType.imaging:
        return 'Chẩn đoán hình ảnh';
      case MedicalRecordType.vitals:
        return 'Chỉ số sinh tồn';
      case MedicalRecordType.other:
        return 'Khác';
    }
  }

  Color _getTypeColor(MedicalRecordType type) {
    switch (type) {
      case MedicalRecordType.prescription:
        return Colors.blue;
      case MedicalRecordType.labResult:
        return Colors.green;
      case MedicalRecordType.imaging:
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordDetailScreen(record: record),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(record.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getTypeLabel(record.type),
                    style: TextStyle(
                      color: _getTypeColor(record.type),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(record.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              record.diagnosis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              'Xem chi tiết',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
