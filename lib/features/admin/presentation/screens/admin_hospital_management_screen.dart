import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/facility_entities.dart';
import 'department_management_screen.dart';

class AdminHospitalManagementScreen extends StatefulWidget {
  const AdminHospitalManagementScreen({super.key});

  @override
  State<AdminHospitalManagementScreen> createState() => _AdminHospitalManagementScreenState();
}

class _AdminHospitalManagementScreenState extends State<AdminHospitalManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchHospitals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AdminController>();
    final filteredList = context.select<AdminController, List<Hospital>>((ctrl) => ctrl.filteredHospitals);

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
                    "Bệnh viện",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  _buildStatCard(
                    context.select<AdminController, String>((ctrl) => ctrl.hospitals.length.toString()), 
                    "Tổng số", 
                    const Color(0xFF1E88E5),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context.select<AdminController, String>((ctrl) => ctrl.hospitals.where((h) => h.isOpen == true).length.toString()), 
                    "Đang HĐ", 
                    const Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context.select<AdminController, String>((ctrl) => ctrl.hospitals.where((h) => h.isOpen == false).length.toString()), 
                    "Tạm dừng", 
                    const Color(0xFFFFB300),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterBar(context, controller),
            const SizedBox(height: 12),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text("Không có bệnh viện nào", style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return HospitalCardItem(hospital: filteredList[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String title, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, AdminController controller) {
    final filters = ["Tất cả", "Đang HĐ", "Bảo trì", "Tạm dừng"];
    final selectedFilter = context.select<AdminController, String>((ctrl) => ctrl.selectedHospitalFilter);

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final label = filters[index];
          final isSelected = selectedFilter == label;
          return GestureDetector(
            onTap: () => controller.changeHospitalFilter(label),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2F66D4) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFEFEFEF),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HospitalCardItem extends StatelessWidget {
  final Hospital hospital;
  const HospitalCardItem({super.key, required this.hospital});

  @override
  Widget build(BuildContext context) {
    String statusText = hospital.isOpen ? "Mở cửa" : "Tạm dừng";
    Color statusColor = hospital.isOpen ? const Color(0xFF43A047) : const Color(0xFFE53935);
    Color statusBg = hospital.isOpen ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);

    final List<List<Color>> gradientPalette = [
      [const Color(0xFF64B5F6), const Color(0xFF1E88E5)],
      [const Color(0xFF81C784), const Color(0xFF388E3C)],
      [const Color(0xFFBA68C8), const Color(0xFF7B1FA2)],
      [const Color(0xFFFFB74D), const Color(0xFFF57C00)],
    ];
    final int colorIndex = hospital.name.hashCode.abs() % gradientPalette.length;
    final List<Color> avatarGradients = gradientPalette[colorIndex];

    final int doctorCount = context.select<AdminController, int>(
      (ctrl) => ctrl.getDoctorCountByHospitalName(hospital.name),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DepartmentManagementScreen(hospital: hospital)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: const Color(0xFFE3F2FD),
                    child: hospital.logoUrl.isNotEmpty
                        ? Image.network(
                            hospital.logoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: avatarGradients)),
                                child: const Icon(Icons.gite_rounded, color: Colors.white, size: 28),
                              );
                            },
                          )
                        : Container(
                            decoration: BoxDecoration(gradient: LinearGradient(colors: avatarGradients)),
                            child: const Icon(Icons.gite_rounded, color: Colors.white, size: 28),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              hospital.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hospital.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Colors.black38, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.medical_services_outlined, size: 14, color: Colors.black87),
                          const SizedBox(width: 4),
                          Text(
                            "$doctorCount bác sĩ",
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(
                            hospital.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}