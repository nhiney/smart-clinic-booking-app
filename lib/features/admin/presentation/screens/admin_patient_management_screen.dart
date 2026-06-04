import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/patient_entity.dart'; 

class AdminPatientManagementScreen extends StatefulWidget {
  const AdminPatientManagementScreen({super.key});

  @override
  State<AdminPatientManagementScreen> createState() => _AdminPatientManagementScreenState();
}

class _AdminPatientManagementScreenState extends State<AdminPatientManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ nạp dữ liệu động từ Firebase nếu chưa có bộ lọc bệnh viện cụ thể
      if (context.read<AdminController>().selectedHospitalNameForPatients == null) {
        context.read<AdminController>().fetchPatients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    
    // TÍCH HỢP ĐÚNG VỊ TRÍ: Phân tách danh sách động theo Bệnh viện hoặc Toàn hệ thống
    final filteredPatients = controller.selectedHospitalNameForPatients != null 
        ? controller.filteredPatientsByHospital 
        : controller.filteredPatients;
        
    final totalPatientsCount = controller.selectedHospitalNameForPatients != null
        ? controller.filteredPatientsByHospital.length
        : controller.patients.length;
        
    final newPatientsThisMonth = controller.getNewPatientsThisMonthCount();
    final activePatientsCount = controller.getActivePatientsCount();
    final vipPatientsCount = controller.getVipPatientsCount();

    // Xác định tiêu đề hiển thị linh hoạt theo ngữ cảnh điều hướng
    final String screenTitle = controller.selectedHospitalNameForPatients != null
        ? "Bệnh nhân - ${controller.selectedHospitalNameForPatients}"
        : "Bệnh nhân";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: controller.selectedHospitalNameForPatients != null 
          ? AppBar(
              backgroundColor: const Color(0xFFF8F9FA),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF0A192F)),
                onPressed: () {
                  Navigator.pop(context);
                  Future.microtask(() {
                    if (context.mounted) {
                      context.read<AdminController>().clearHospitalDoctorFilter();
                    }
                  });
                },
              ),
              title: Text(
                screenTitle, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề Dashboard Bệnh nhân (Ẩn đi nếu đã có AppBar ở trên)
            if (controller.selectedHospitalNameForPatients == null)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          screenTitle,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$totalPatientsCount bệnh nhân · +$newPatientsThisMonth tháng này",
                          style: const TextStyle(fontSize: 14, color: Colors.black45, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: Color(0xFF0A192F), size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

            // 2. Các thẻ đếm chỉ số thống kê hàng đầu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  _buildTopStatCard(_formatCount(activePatientsCount), "Hoạt động", const Color(0xFF2E7D32)),
                  const SizedBox(width: 12),
                  _buildTopStatCard(newPatientsThisMonth.toString(), "Tháng này", const Color(0xFF1E88E5)),
                  const SizedBox(width: 12),
                  _buildTopStatCard(vipPatientsCount.toString(), "VIP", const Color(0xFFFFB300)),
                ],
              ),
            ),

            const SizedBox(height: 8),
            _buildPatientFilterBar(context, controller),

            // 3. Trạng thái hiển thị số lượng & Sắp xếp bộ lọc
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hiển thị ${filteredPatients.length} / $totalPatientsCount",
                    style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: const [
                        Text(
                          "Sắp xếp: ",
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                        Text(
                          "Mới nhất",
                          style: TextStyle(fontSize: 14, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E88E5), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Khối Render danh sách thẻ Card
            Expanded(
              child: filteredPatients.isEmpty
                  ? const Center(child: Text("Không tìm thấy bệnh nhân nào", style: TextStyle(color: Colors.black38)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        return PatientCardItem(patient: filteredPatients[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatCard(String value, String title, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 8,
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
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientFilterBar(BuildContext context, AdminController controller) {
    final filters = ["Tất cả", "Hoạt động", "VIP", "BHYT"];
    final selectedFilter = controller.selectedPatientFilter;

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
            onTap: () => controller.changePatientFilter(label),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E88E5) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFEFEFEF),
                  width: 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
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

  String _formatCount(int count) {
    if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }
}

class PatientCardItem extends StatelessWidget {
  final Patient patient;
  const PatientCardItem({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final String name = patient.name;
    final String code = patient.code;
    final int age = patient.age;
    final String disease = patient.disease;
    final bool isVip = patient.role == 'vip' || patient.isVerified; 
    final int visitCount = patient.visitCount;
    final String lastVisitText = patient.lastVisitText;

    final String shortName = name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0] : '').join('').toUpperCase();

    final List<List<Color>> gradientPalette = [
      [const Color(0xFF4DB6AC), const Color(0xFF00796B)],
      [const Color(0xFFE57373), const Color(0xFFD32F2F)],
      [const Color(0xFF64B5F6), const Color(0xFF1E88E5)],
      [const Color(0xFFBA68C8), const Color(0xFF7B1FA2)],
    ];
    final int colorIndex = name.hashCode.abs() % gradientPalette.length;
    final List<Color> avatarGradients = gradientPalette[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: avatarGradients,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              shortName,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (isVip)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 14),
                            ),
                          ),
                      ],
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
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                                ),
                              ),
                              if (isVip)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 12),
                                      SizedBox(width: 2),
                                      Text(
                                        "VIP",
                                        style: TextStyle(color: Color(0xFFFFB300), fontSize: 10, fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$code · $age tuổi",
                            style: const TextStyle(fontSize: 13, color: Colors.black38, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.healing_outlined, size: 12, color: Color(0xFF5F6368)),
                                const SizedBox(width: 6),
                                Text(
                                  disease,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF3C4043), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFEFEFEF)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: Colors.black38),
                        const SizedBox(width: 6),
                        Text(
                          "$visitCount lượt khám",
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Text("·", style: TextStyle(color: Colors.black26)),
                        const SizedBox(width: 4),
                        Text(
                          "Gần nhất: $lastVisitText",
                          style: const TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 18),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}