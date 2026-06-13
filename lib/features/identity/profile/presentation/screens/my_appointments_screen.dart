import 'package:flutter/material.dart';
import './appointment_detail_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  int _tabIndex = 0;

  final List<Map<String, dynamic>> _appointments = [
    {
      'doctor': 'BS. Nguyễn Văn An',
      'specialty': 'Tim mạch',
      'hospital': 'BV Đại học Y Dược TP.HCM',
      'date': '20/05/2026',
      'time': '09:30',
      'status': 'confirmed',
      'color': Color(0xFF1565C0),
      'rating': 4.8,
      'experience': 10,
    },
    {
      'doctor': 'BS. Trần Thị Bình',
      'specialty': 'Nhi khoa',
      'hospital': 'BV Nhi Đồng 1',
      'date': '22/05/2026',
      'time': '14:00',
      'status': 'pending',
      'color': Color(0xFF00897B),
      'rating': 4.9,
      'experience': 8,
    },
    {
      'doctor': 'BS. Lê Minh Châu',
      'specialty': 'Da liễu',
      'hospital': 'BV Da Liễu TP.HCM',
      'date': '10/04/2026',
      'time': '10:00',
      'status': 'completed',
      'color': Color(0xFF8E24AA),
      'rating': 4.7,
      'experience': 12,
    },
    {
      'doctor': 'BS. Phạm Thanh Dũng',
      'specialty': 'Thần kinh',
      'hospital': 'BV Chợ Rẫy',
      'date': '01/04/2026',
      'time': '08:30',
      'status': 'cancelled',
      'color': Color(0xFFF57C00),
      'rating': 4.6,
      'experience': 15,
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments {
    if (_tabIndex == 0) return _appointments;
    if (_tabIndex == 1) {
      return _appointments
          .where((a) => a['status'] == 'confirmed' || a['status'] == 'pending')
          .toList();
    }
    return _appointments
        .where((a) => a['status'] == 'completed' || a['status'] == 'cancelled')
        .toList();
  }

  void _cancelAppointment(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hủy lịch khám',
          style: TextStyle(
            color: Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Bạn có chắc muốn hủy lịch khám này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _appointments[index]['status'] = 'cancelled');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã hủy lịch khám'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hủy lịch',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _viewDetail(BuildContext context, Map<String, dynamic> apt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointment: apt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          'Lịch khám của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _TabButton(
                  label: 'Tất cả',
                  isSelected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: 'Sắp tới',
                  isSelected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: 'Đã qua',
                  isSelected: _tabIndex == 2,
                  onTap: () => setState(() => _tabIndex = 2),
                ),
              ],
            ),
          ),

          // Danh sách lịch
          Expanded(
            child: _filteredAppointments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có lịch khám',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final apt = _filteredAppointments[index];
                      final realIndex = _appointments.indexOf(apt);
                      return _AppointmentCard(
                        appointment: apt,
                        onTap: () => _viewDetail(context, apt),
                        onCancel:
                            apt['status'] == 'confirmed' ||
                                apt['status'] == 'pending'
                            ? () => _cancelAppointment(realIndex)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1565C0)
                : const Color(0xFFF0F6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const _AppointmentCard({
    required this.appointment,
    this.onCancel,
    this.onTap,
  });

  String get _statusText {
    switch (appointment['status']) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'pending':
        return 'Chờ xác nhận';
      case 'completed':
        return 'Đã khám';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return '';
    }
  }

  Color get _statusColor {
    switch (appointment['status']) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: (appointment['color'] as Color).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: appointment['color'] as Color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment['doctor'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        Text(
                          appointment['specialty'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Thông tin lịch
              Row(
                children: [
                  const Icon(
                    Icons.local_hospital_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment['hospital'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appointment['date'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    appointment['time'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Nút hủy
              if (onCancel != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Hủy lịch khám'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
