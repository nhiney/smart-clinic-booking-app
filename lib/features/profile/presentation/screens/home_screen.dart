import 'package:flutter/material.dart';
import 'doctor_search_screen.dart';
import 'my_appointments_screen.dart';
import 'hospital_screen.dart';
import 'payment_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Bệnh viện Đại học Y Dược TP. HCM',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ICare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Ứng dụng dành cho Người bệnh',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Chức năng chính
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chức năng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      Icon(Icons.tune, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.75,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DoctorSearchScreen(),
                          ),
                        ),
                        child: const FeatureItem(
                          icon: Icons.calendar_month,
                          label: 'Đặt khám',
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyAppointmentsScreen(),
                          ),
                        ),
                        child: const FeatureItem(
                          icon: Icons.history,
                          label: 'Lịch sử đặt khám',
                          color: Color(0xFF00897B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaymentScreen(),
                          ),
                        ),
                        child: const FeatureItem(
                          icon: Icons.payment,
                          label: 'Thanh toán viện phí',
                          color: Color(0xFFF57C00),
                        ),
                      ),
                      const FeatureItem(
                        icon: Icons.receipt_long,
                        label: 'Hoá đơn',
                        color: Color(0xFFE53935),
                      ),
                      const FeatureItem(
                        icon: Icons.folder_shared,
                        label: 'Hồ sơ sức khoẻ',
                        color: Color(0xFF8E24AA),
                      ),
                      const FeatureItem(
                        icon: Icons.biotech,
                        label: 'Kết quả cận lâm sàng',
                        color: Color(0xFF039BE5),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HospitalScreen(),
                          ),
                        ),
                        child: const FeatureItem(
                          icon: Icons.local_hospital,
                          label: 'Đăng ký nhập viện',
                          color: Color(0xFF43A047),
                        ),
                      ),
                      const FeatureItem(
                        icon: Icons.headset_mic,
                        label: 'Lắng nghe khách hàng',
                        color: Color(0xFFE91E63),
                      ),
                      const FeatureItem(
                        icon: Icons.support_agent,
                        label: 'Hỗ trợ',
                        color: Color(0xFF546E7A),
                      ),
                      const FeatureItem(
                        icon: Icons.monitor_heart,
                        label: 'Theo dõi sức khoẻ',
                        color: Color(0xFF00ACC1),
                      ),
                      const FeatureItem(
                        icon: Icons.vaccines,
                        label: 'Tiêm chủng',
                        color: Color(0xFF7CB342),
                      ),
                      const FeatureItem(
                        icon: Icons.smart_toy,
                        label: 'Hỏi - đáp (Chatbot)',
                        color: Color(0xFF5E35B1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tin tức
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tin tức nổi bật',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Xem thêm',
                          style: TextStyle(color: Color(0xFF1565C0)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const NewsCard(
                    title:
                        'Xác nhận bảo hiểm y tế ngay khi đặt khám trên ICare – Giảm thời gian chờ đợi',
                    imageColor: Color(0xFF42A5F5),
                  ),
                  const SizedBox(height: 8),
                  const NewsCard(
                    title:
                        'Chương trình chăm sóc sức khoẻ toàn diện cho bệnh nhân mãn tính',
                    imageColor: Color(0xFF26C6DA),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF333333),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final Color imageColor;

  const NewsCard({super.key, required this.title, required this.imageColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 70,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Container(
            width: 70,
            height: 70,
            color: imageColor.withOpacity(0.2),
            child: Icon(Icons.article, color: imageColor, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                  height: 1.4,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.chevron_right, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }
}
