import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor_entity.dart';
import '../controllers/admin_controller.dart';

class AdminDoctorManagementScreen extends StatefulWidget {
  const AdminDoctorManagementScreen({super.key});

  @override
  State<AdminDoctorManagementScreen> createState() => _AdminDoctorManagementScreenState();
}

class _AdminDoctorManagementScreenState extends State<AdminDoctorManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().listenToSystemStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final rawDocs = controller.filteredDoctors;
    
    final List<Doctor> doctors = rawDocs.map((doc) {
      return Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Quản lý bác sĩ",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.black87, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Tìm theo tên, chuyên khoa...",
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.black38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTabBar(controller),
            const SizedBox(height: 8),
            Expanded(
              child: doctors.isEmpty
                  ? const Center(child: Text("Không có dữ liệu hiển thị", style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return _buildDoctorCard(controller, doctors[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(AdminController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabItem(controller, "Chờ duyệt"),
          _buildTabItem(controller, "Đã duyệt"),
          _buildTabItem(controller, "Từ chối"),
        ],
      ),
    );
  }

  Widget _buildTabItem(AdminController controller, String label) {
    final bool isSelected = controller.selectedDoctorTab == label;
    final int count = controller.getDoctorCountByStatus(label);

    return GestureDetector(
      onTap: () => controller.changeDoctorTab(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: isSelected 
              ? const Border(bottom: BorderSide(color: Color(0xFF1E88E5), width: 3.0)) 
              : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF1E88E5) : Colors.black45,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(AdminController controller, Doctor doctor) {
    final String name = doctor.name.isNotEmpty ? doctor.name : "Bác sĩ";
    final String specialty = doctor.specialty.isNotEmpty ? doctor.specialty : "Chưa cập nhật";
    final String hospital = doctor.hospitalName.isNotEmpty ? doctor.hospitalName : "Bệnh viện tự do";
    
    String timeAgo = "Vừa xong";
    final createdAtRaw = doctor.approvedAt ?? doctor.createdAt;
    if (createdAtRaw != null) {
      final DateTime dateTime = (createdAtRaw is Timestamp) ? createdAtRaw.toDate() : DateTime.parse(createdAtRaw.toString());
      final Duration diff = DateTime.now().difference(dateTime);
      if (diff.inDays > 0) {
        timeAgo = "${diff.inDays} ngày trước";
      } else if (diff.inHours > 0) {
        timeAgo = "${diff.inHours} giờ trước";
      } else if (diff.inMinutes > 0) {
        timeAgo = "${diff.inMinutes} phút trước";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.split(' ').last.substring(0, indexWhereOrLast(name)).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                          ),
                        ),
                        _buildStatusBadge(doctor.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      specialty,
                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.black38),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "$hospital • ${doctor.experienceYears} năm KN",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F1F1), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.insert_drive_file_outlined, size: 14, color: Colors.black38),
              const SizedBox(width: 4),
              const Text(
                "3 tài liệu",
                style: TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              const Text("•", style: TextStyle(color: Colors.black26)),
              const SizedBox(width: 6),
              Text(
                timeAgo,
                style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              if (doctor.status == "pending") ...[
                ElevatedButton(
                  onPressed: () => controller.rejectDoctor(doctor.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    foregroundColor: const Color(0xFFE53935),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Từ chối", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.approveDoctor(doctor.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Duyệt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  int indexWhereOrLast(String text) {
    return text.split(' ').last.length >= 2 ? 2 : text.split(' ').last.length;
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    if (status == "approved") {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF43A047);
      text = "Đã duyệt";
    } else if (status == "rejected") {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFE53935);
      text = "Từ chối";
    } else {
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFFFB300);
      text = "Chờ duyệt";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}