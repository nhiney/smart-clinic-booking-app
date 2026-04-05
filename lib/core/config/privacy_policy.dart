import 'package:cloud_firestore/cloud_firestore.dart';

class PrivacyPolicy {
  final String version;
  final String content; // Markdown string
  final String? pdfUrl; // Backup link to PDF
  final DateTime updatedAt;

  PrivacyPolicy({
    required this.version,
    required this.content,
    this.pdfUrl,
    required this.updatedAt,
  });

  factory PrivacyPolicy.fromMap(Map<String, dynamic> map, String id) {
    return PrivacyPolicy(
      version: id,
      content: map['content'] as String? ?? 'No content available.',
      pdfUrl: map['pdfUrl'] as String?,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Default static content (Hardcoded fallback)
  factory PrivacyPolicy.fallback() {
    return PrivacyPolicy(
      version: 'default',
      content: '''# CHÍNH SÁCH BẢO MẬT VÀ ĐIỀU KHOẢN SỬ DỤNG DỮ LIỆU CÁ NHÂN
(Bản dự phòng cục bộ - ICare)
... [Vui lòng truy cập ứng dụng để xem bản cập nhật nhất]''',
      pdfUrl: 'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf',
      updatedAt: DateTime.now(),
    );
  }
}
