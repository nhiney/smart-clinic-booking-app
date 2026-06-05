// lib/features/admin/presentation/widgets/doctor_approval_card.dart
import 'package:flutter/material.dart';
import '../../../doctor/patient_pov/domain/entities/doctor_entity.dart';

class DoctorApprovalCard extends StatelessWidget {
  final DoctorEntity doctor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const DoctorApprovalCard({
    super.key,
    required this.doctor,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 GIẢI PHÁP SỬA LỖI: Đọc dữ liệu thô dạng Map Key-Value để tránh kích hoạt NoSuchMethodError
    Map<String, dynamic> doctorMap = {};
    try {
      doctorMap = (doctor as dynamic).toMap();
    } catch (_) {}

    final String currentStatus = doctorMap['status'] ?? 'pending';
    final int yearsOfExp = doctorMap['experienceYears'] ?? 0;
    
    final String initialText = doctor.name.isNotEmpty 
        ? doctor.name.trim().split(' ').last.substring(0, 2).toUpperCase() 
        : 'BS';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF38BDF8).withOpacity(0.15),
                backgroundImage: doctor.imageUrl.isNotEmpty ? NetworkImage(doctor.imageUrl) : null,
                child: doctor.imageUrl.isEmpty
                    ? Text(
                        initialText,
                        style: const TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold, fontSize: 16),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              
              // 💡 ĐÃ CẬP NHẬT: Bọc toàn bộ khối text vào Expanded để khống chế chiều ngang, chống tràn viền
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start, // Căn đỉnh để badge không bị lệch khi tên xuống dòng
                      children: [
                        // 💡 ĐÃ CẬP NHẬT: Tiếp tục bọc tên vào Expanded nội bộ để ép chữ tự động xuống hàng mượt mà
                        Expanded(
                          child: Text(
                            // Tự động kiểm tra chuỗi động từ DB, nếu có sẵn tiền tố thì giữ nguyên để tránh lặp 'BS. BS.'
                            doctor.name.trim().toLowerCase().startsWith('bs') || 
                            doctor.name.trim().toLowerCase().startsWith('bác sĩ')
                                ? doctor.name
                                : 'BS. ${doctor.name}',
                            style: const TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8), // Khoảng cách an toàn giữa tên và badge trạng thái
                        _buildStatusBadge(currentStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chuyên khoa ${doctor.specialty ?? "Tổng quát"}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4), 
                        Expanded(
                          child: Text(
                            doctor.hospital ?? 'Bệnh viện Trung ương',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$yearsOfExp năm KN',
                          style: const TextStyle(
                            fontSize: 12, 
                            color: Color(0xFF64748B), 
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.description_outlined, size: 16, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    '${(doctorMap['documents'] as List?)?.length ?? 0} tài liệu · ${_getFormattedTime(doctorMap['createdAt'])}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              if (currentStatus == 'pending')
                Row(
                  children: [
                    _buildActionButton(
                      label: 'Từ chối',
                      color: const Color(0xFFFEE2E2),
                      textColor: const Color(0xFFEF4444),
                      onTap: onReject,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      label: 'Duyệt',
                      color: const Color(0xFF2563EB),
                      textColor: Colors.white,
                      onTap: onApprove,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFormattedTime(dynamic firestoreTimestamp) {
    if (firestoreTimestamp == null) return 'Vừa xong';
    try {
      final DateTime dateTime = firestoreTimestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} phút trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} giờ trước';
      } else {
        return '${difference.inDays} ngày trước';
      }
    } catch (_) {
      return 'Gần đây';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = const Color(0xFFFEF3C7);
    Color textColor = const Color(0xFFD97706);
    String label = 'Chờ duyệt';

    if (status == 'approved') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A);
      label = 'Đã duyệt';
    } else if (status == 'rejected') {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFEF4444);
      label = 'Từ chối';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}