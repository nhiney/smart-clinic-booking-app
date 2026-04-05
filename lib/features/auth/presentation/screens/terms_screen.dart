import 'package:flutter/material.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BrandedAppBar(
        title: 'Điều khoản sử dụng',
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildIntro(),
                const SizedBox(height: 32),
                _buildSection("1. Dữ liệu chúng tôi thu thập", [
                  _buildSubSection("1.1 Thông tin cá nhân", [
                    "Họ tên, số điện thoại, email.",
                    "Số CCCD/CMND (nếu có yêu cầu xác minh đặc biệt).",
                    "Ngày sinh, giới tính để hỗ trợ tư vấn chuyên môn.",
                  ]),
                  _buildSubSection("1.2 Thông tin y tế", [
                    "Hồ sơ bệnh án điện tử, lịch sử khám bệnh.",
                    "Triệu chứng, ghi chú sức khỏe cá nhân được cung cấp.",
                  ]),
                  _buildSubSection("1.3 Dữ liệu hệ thống", [
                    "Địa chỉ IP, thông tin thiết bị, hệ điều hành.",
                    "Nhật ký hoạt động (logs) để giám sát và cải thiện dịch vụ.",
                  ]),
                ]),
                _buildSection("2. Mục đích sử dụng dữ liệu", [
                  _buildBulletPoint("Cung cấp và duy trì dịch vụ đặt lịch khám y tế trực tuyến."),
                  _buildBulletPoint("Quản lý và đồng bộ hồ sơ sức khỏe cá nhân hiệu quả."),
                  _buildBulletPoint("Gửi thông báo nhắc nhở lịch khám, tin nhắn chăm sóc khách hàng."),
                  _buildBulletPoint("Nghiên cứu, phân tích để cải thiện trải nghiệm người dùng."),
                  _buildBulletPoint("Đảm bảo an toàn thông tin, phòng chống gian lận và tuân thủ pháp luật."),
                ]),
                _buildSection("3. Cơ sở pháp lý về xử lý dữ liệu", [
                  _buildParagraph("Theo tiêu chuẩn GDPR và pháp luật hiện hành, chúng tôi xử lý dữ liệu dựa trên:"),
                  _buildBulletPoint("Sự đồng ý rõ ràng của bạn (Consent)."),
                  _buildBulletPoint("Thực hiện hợp đồng dịch vụ y tế (Contract)."),
                  _buildBulletPoint("Tuân thủ nghĩa vụ pháp lý (Legal obligation)."),
                  _buildBulletPoint("Lợi ích hợp pháp của hệ thống (Legitimate interest)."),
                ]),
                _buildSection("4. Chia sẻ và cung cấp dữ liệu", [
                  _buildParagraph("Chúng tôi CAM KẾT KHÔNG BÁN dữ liệu cá nhân của bạn. Dữ liệu có thể được chia sẻ một cách bảo mật với:"),
                  _buildBulletPoint("Bác sĩ và cơ sở y tế đối tác để trực tiếp phục vụ việc khám chữa bệnh."),
                  _buildBulletPoint("Các nhà cung cấp dịch vụ hạ tầng (Firebase, AWS, Email Provider) với cam kết bảo mật chặt chẽ."),
                  _buildBulletPoint("Cơ quan nhà nước có thẩm quyền khi có yêu cầu bằng văn bản theo đúng quy định pháp luật."),
                ]),
                _buildSection("5. Lưu trữ và Bảo mật thông tin", [
                  _buildParagraph("Chúng tôi áp dụng các tiêu chuẩn bảo mật cao cấp nhất để bảo vệ thông tin cá nhân:"),
                  _buildBulletPoint("Mã hóa dữ liệu tại chỗ và trong quá trình truyền tải (Encryption)."),
                  _buildBulletPoint("Xác thực người dùng đa lớp (Authentication & Authorization)."),
                  _buildBulletPoint("Kiểm soát truy cập nội bộ cực kỳ nghiêm ngặt (Strict Access Control)."),
                  _buildParagraph("Dữ liệu được lưu trữ trên hệ thống điện toán đám mây đạt chuẩn y tế toàn cầu."),
                ]),
                _buildSection("6. Quyền của người dùng", [
                  _buildParagraph("Là chủ thể dữ liệu, bạn có các quyền hợp pháp sau:"),
                  _buildBulletPoint("Quyền truy cập và yêu cầu trích xuất dữ liệu cá nhân."),
                  _buildBulletPoint("Quyền chỉnh sửa, bổ sung thông tin chưa chính xác."),
                  _buildBulletPoint("Quyền yêu cầu xóa dữ liệu (Quyền được lãng quên - Right to be forgotten)."),
                  _buildBulletPoint("Quyền hạn chế hoặc phản đối việc xử lý dữ liệu."),
                  _buildBulletPoint("Quyền rút lại sự đồng ý bất kỳ lúc nào mà không ảnh hưởng đến tính hợp pháp của việc xử lý trước đó."),
                ]),
                _buildSection("7. Phụ lục Cookie và Theo dõi", [
                  _buildParagraph("Ứng dụng có thể sử dụng Tracking Cookies và Analytics tools nhằm phân tích hành vi để tối ưu hoá trải nghiệm giao diện người dùng, không nhằm mục đích định danh cá nhân trái phép."),
                ]),
                _buildSection("8. Liên hệ hỗ trợ", [
                  _buildParagraph("Mọi thắc mắc về quyền riêng tư và Điều khoản sử dụng, vui lòng liên hệ:"),
                  const SizedBox(height: 8),
                  const Text("• Điện thoại: 1900 xxxx\n• Email hỗ trợ: support@smartclinic.com\n• Địa chỉ: Số 1, Đường Y Tế, TP. HCM", style: TextStyle(height: 1.6, fontSize: 15)),
                ]),
                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    "© 2026 ICARE. All rights reserved.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "CHÍNH SÁCH BẢO MẬT",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E3A8A),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            "(Privacy Policy - Chuẩn GDPR & PLVN)",
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: 12),
        Center(
          child: Text(
            "Cập nhật lần cuối: 19/03/2026",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1E0FF)),
      ),
      child: const Text(
        "Ứng dụng ICARE (“Chúng tôi”) cam kết ưu tiên bảo vệ tuyệt đối quyền riêng tư và dữ liệu cá nhân của người dùng (“Bạn”) tuân thủ nghiêm ngặt Quy định bảo vệ dữ liệu chung (GDPR), Luật An toàn thông tin mạng Việt Nam và Nghị định 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân.",
        style: TextStyle(
          fontSize: 14.5,
          height: 1.6,
          color: Color(0xFF1F2937),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 6),
          ...items.map((item) => _buildBulletPoint(item)),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "•",
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF3B82F6),
              height: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF374151),
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: Color(0xFF374151),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

