import 'package:flutter/material.dart';
import './doctor_detail_screen.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen> {
  String _selectedSpecialty = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _specialties = [
    'Tất cả',
    'Tim mạch',
    'Nhi khoa',
    'Da liễu',
    'Thần kinh',
    'Nội tổng quát',
    'Răng hàm mặt',
  ];

  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'BS. Nguyễn Văn An',
      'specialty': 'Tim mạch',
      'hospital': 'BV Đại học Y Dược TP.HCM',
      'rating': 4.8,
      'experience': 10,
      'color': Color(0xFF1565C0),
    },
    {
      'name': 'BS. Trần Thị Bình',
      'specialty': 'Nhi khoa',
      'hospital': 'BV Nhi Đồng 1',
      'rating': 4.9,
      'experience': 8,
      'color': Color(0xFF00897B),
    },
    {
      'name': 'BS. Lê Minh Châu',
      'specialty': 'Da liễu',
      'hospital': 'BV Da Liễu TP.HCM',
      'rating': 4.7,
      'experience': 12,
      'color': Color(0xFF8E24AA),
    },
    {
      'name': 'BS. Phạm Thanh Dũng',
      'specialty': 'Thần kinh',
      'hospital': 'BV Chợ Rẫy',
      'rating': 4.6,
      'experience': 15,
      'color': Color(0xFFF57C00),
    },
    {
      'name': 'BS. Hoàng Thị Em',
      'specialty': 'Nội tổng quát',
      'hospital': 'BV 115',
      'rating': 4.5,
      'experience': 7,
      'color': Color(0xFF039BE5),
    },
  ];

  List<Map<String, dynamic>> get _filteredDoctors {
    return _doctors.where((doc) {
      final matchSpecialty =
          _selectedSpecialty == 'Tất cả' ||
          doc['specialty'] == _selectedSpecialty;
      final matchSearch = doc['name'].toLowerCase().contains(
        _searchController.text.toLowerCase(),
      );
      return matchSpecialty && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          'Tìm bác sĩ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bác sĩ...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Filter chuyên khoa
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final spec = _specialties[index];
                final isSelected = spec == _selectedSpecialty;
                return GestureDetector(
                  onTap: () => setState(() => _selectedSpecialty = spec),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1565C0)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      spec,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Danh sách bác sĩ
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredDoctors.length,
              itemBuilder: (context, index) {
                final doc = _filteredDoctors[index];
                return _DoctorCard(doctor: doc);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const _DoctorCard({required this.doctor});

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctor: doctor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar — bấm vào để xem chi tiết
            GestureDetector(
              onTap: () => _goToDetail(context),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (doctor['color'] as Color).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: doctor['color'] as Color,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info — bấm vào tên để xem chi tiết
            Expanded(
              child: GestureDetector(
                onTap: () => _goToDetail(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (doctor['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            doctor['specialty'],
                            style: TextStyle(
                              fontSize: 11,
                              color: doctor['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['hospital'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(
                          ' ${doctor['rating']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.work_outline,
                          color: Colors.grey,
                          size: 14,
                        ),
                        Text(
                          ' ${doctor['experience']} năm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Nút đặt khám
            ElevatedButton(
              onPressed: () => _goToDetail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(0, 0),
              ),
              child: const Text('Đặt khám', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
