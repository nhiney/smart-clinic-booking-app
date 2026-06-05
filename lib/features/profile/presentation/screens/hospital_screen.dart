import 'package:flutter/material.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';

  final List<String> _filters = [
    'Tất cả',
    'Gần nhất',
    'Đánh giá cao',
    'Công lập',
    'Tư nhân',
  ];

  final List<Map<String, dynamic>> _hospitals = [
    {
      'name': 'BV Đại học Y Dược TP.HCM',
      'address': '215 Hồng Bàng, Quận 5, TP.HCM',
      'rating': 4.8,
      'distance': '1.2 km',
      'type': 'Công lập',
      'specialties': ['Tim mạch', 'Nhi khoa', 'Thần kinh'],
      'color': Color(0xFF1565C0),
      'icon': Icons.local_hospital,
    },
    {
      'name': 'BV Chợ Rẫy',
      'address': '201B Nguyễn Chí Thanh, Quận 5, TP.HCM',
      'rating': 4.7,
      'distance': '2.1 km',
      'type': 'Công lập',
      'specialties': ['Ngoại khoa', 'Ung bướu', 'Cấp cứu'],
      'color': Color(0xFF00897B),
      'icon': Icons.medical_services,
    },
    {
      'name': 'BV Nhi Đồng 1',
      'address': '341 Sư Vạn Hạnh, Quận 10, TP.HCM',
      'rating': 4.9,
      'distance': '3.5 km',
      'type': 'Công lập',
      'specialties': ['Nhi khoa', 'Nhi ngoại', 'Nhi thần kinh'],
      'color': Color(0xFF039BE5),
      'icon': Icons.child_care,
    },
    {
      'name': 'BV FV',
      'address': '6 Nguyễn Lương Bằng, Quận 7, TP.HCM',
      'rating': 4.6,
      'distance': '5.8 km',
      'type': 'Tư nhân',
      'specialties': ['Da liễu', 'Sản phụ khoa', 'Tim mạch'],
      'color': Color(0xFF8E24AA),
      'icon': Icons.healing,
    },
    {
      'name': 'BV Vinmec Central Park',
      'address': '208 Nguyễn Hữu Cảnh, Bình Thạnh, TP.HCM',
      'rating': 4.7,
      'distance': '4.2 km',
      'type': 'Tư nhân',
      'specialties': ['Ung bướu', 'Tim mạch', 'Nhi khoa'],
      'color': Color(0xFFF57C00),
      'icon': Icons.health_and_safety,
    },
  ];

  List<Map<String, dynamic>> get _filteredHospitals {
    return _hospitals.where((h) {
      final matchSearch =
          h['name'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          h['address'].toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchFilter =
          _selectedFilter == 'Tất cả' ||
          (_selectedFilter == 'Công lập' && h['type'] == 'Công lập') ||
          (_selectedFilter == 'Tư nhân' && h['type'] == 'Tư nhân') ||
          (_selectedFilter == 'Gần nhất') ||
          (_selectedFilter == 'Đánh giá cao');
      return matchSearch && matchFilter;
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
          'Chọn bệnh viện',
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
                hintText: 'Tìm kiếm bệnh viện...',
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

          // Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
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
                      filter,
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

          // Danh sách bệnh viện
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredHospitals.length,
              itemBuilder: (context, index) {
                final hospital = _filteredHospitals[index];
                return _HospitalCard(hospital: hospital);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Map<String, dynamic> hospital;
  const _HospitalCard({required this.hospital});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (hospital['color'] as Color).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    hospital['icon'] as IconData,
                    color: hospital['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),

                // Tên và loại
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: hospital['type'] == 'Công lập'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hospital['type'],
                          style: TextStyle(
                            fontSize: 11,
                            color: hospital['type'] == 'Công lập'
                                ? Colors.blue
                                : Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Rating
                Column(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(
                      '${hospital['rating']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Địa chỉ
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    hospital['address'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hospital['distance'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Chuyên khoa
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (hospital['specialties'] as List<String>)
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (hospital['color'] as Color).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (hospital['color'] as Color).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          color: hospital['color'] as Color,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Nút chọn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chọn ${hospital['name']}'),
                      backgroundColor: const Color(0xFF1565C0),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Chọn bệnh viện này'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
