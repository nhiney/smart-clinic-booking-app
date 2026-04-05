import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/health_summary.dart';
import '../../domain/entities/medication_reminder.dart';
import '../../domain/entities/health_article.dart';

class HealthSummaryModel extends HealthSummary {
  const HealthSummaryModel({
    required super.userId,
    required super.heartRate,
    required super.bloodPressure,
    required super.bloodSugar,
    required super.bmi,
    required super.lastUpdated,
  });

  factory HealthSummaryModel.fromJson(Map<String, dynamic> json) {
    HealthMetric _parseMetric(Map<String, dynamic> m) => HealthMetric(
          label: m['label'] as String,
          value: m['value'] as String,
          unit: m['unit'] as String,
          status: HealthStatus.values.firstWhere(
            (s) => s.name == (m['status'] as String? ?? 'unknown'),
            orElse: () => HealthStatus.unknown,
          ),
          recordedAt: (m['recordedAt'] as Timestamp).toDate(),
        );

    return HealthSummaryModel(
      userId: json['userId'] as String,
      heartRate: _parseMetric(json['heartRate'] as Map<String, dynamic>),
      bloodPressure: _parseMetric(json['bloodPressure'] as Map<String, dynamic>),
      bloodSugar: _parseMetric(json['bloodSugar'] as Map<String, dynamic>),
      bmi: _parseMetric(json['bmi'] as Map<String, dynamic>),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  /// Returns mock data for development/offline mode.
  factory HealthSummaryModel.mock(String userId) {
    final now = DateTime.now();
    return HealthSummaryModel(
      userId: userId,
      heartRate: HealthMetric(
        label: 'Heart Rate',
        value: '72',
        unit: 'bpm',
        status: HealthStatus.normal,
        recordedAt: now,
      ),
      bloodPressure: HealthMetric(
        label: 'Blood Pressure',
        value: '120/80',
        unit: 'mmHg',
        status: HealthStatus.normal,
        recordedAt: now,
      ),
      bloodSugar: HealthMetric(
        label: 'Blood Sugar',
        value: '95',
        unit: 'mg/dL',
        status: HealthStatus.normal,
        recordedAt: now,
      ),
      bmi: HealthMetric(
        label: 'BMI',
        value: '22.4',
        unit: 'kg/m²',
        status: HealthStatus.normal,
        recordedAt: now,
      ),
      lastUpdated: now,
    );
  }
}

class MedicationReminderModel extends MedicationReminder {
  const MedicationReminderModel({
    required super.id,
    required super.medicationName,
    required super.dosage,
    required super.scheduledTime,
    required super.isTaken,
    super.notes,
  });

  factory MedicationReminderModel.fromJson(Map<String, dynamic> json, String docId) {
    return MedicationReminderModel(
      id: docId,
      medicationName: json['medicationName'] as String,
      dosage: json['dosage'] as String,
      scheduledTime: (json['scheduledTime'] as Timestamp).toDate(),
      isTaken: json['isTaken'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'medicationName': medicationName,
        'dosage': dosage,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'isTaken': isTaken,
        'notes': notes,
      };

  static List<MedicationReminderModel> mockList() {
    final now = DateTime.now();
    return [
      MedicationReminderModel(
        id: 'mock_1',
        medicationName: 'Paracetamol 500mg',
        dosage: '1 tablet',
        scheduledTime: now.copyWith(hour: 8, minute: 0),
        isTaken: true,
      ),
      MedicationReminderModel(
        id: 'mock_2',
        medicationName: 'Vitamin D3 1000IU',
        dosage: '1 capsule',
        scheduledTime: now.copyWith(hour: 12, minute: 0),
        isTaken: false,
      ),
      MedicationReminderModel(
        id: 'mock_3',
        medicationName: 'Omega-3 Fish Oil',
        dosage: '2 capsules',
        scheduledTime: now.copyWith(hour: 20, minute: 0),
        isTaken: false,
      ),
    ];
  }
}

class HealthArticleModel extends HealthArticle {
  const HealthArticleModel({
    required super.id,
    required super.title,
    required super.summary,
    super.imageUrl,
    required super.source,
    required super.publishedAt,
    super.articleUrl,
  });

  factory HealthArticleModel.fromJson(Map<String, dynamic> json, String docId) {
    return HealthArticleModel(
      id: docId,
      title: json['title'] as String,
      summary: json['summary'] as String,
      imageUrl: json['imageUrl'] as String?,
      source: json['source'] as String,
      publishedAt: (json['publishedAt'] as Timestamp).toDate(),
      articleUrl: json['articleUrl'] as String?,
    );
  }

  static List<HealthArticleModel> mockList() {
    final now = DateTime.now();
    return [
      HealthArticleModel(
        id: 'news_1',
        title: '5 thói quen lành mạnh giúp tăng cường miễn dịch',
        summary: 'Nghiên cứu mới chỉ ra rằng việc duy trì giấc ngủ đủ giấc và tập thể dục đều đặn có thể tăng cường hệ miễn dịch lên đến 40%.',
        source: 'WHO Health News',
        publishedAt: now.subtract(const Duration(hours: 2)),
      ),
      HealthArticleModel(
        id: 'news_2',
        title: 'Chế độ ăn uống tốt cho bệnh nhân tiểu đường',
        summary: 'Các chuyên gia dinh dưỡng khuyến cáo người bệnh tiểu đường nên ưu tiên thực phẩm có chỉ số đường huyết thấp.',
        source: 'Bộ Y tế Việt Nam',
        publishedAt: now.subtract(const Duration(hours: 5)),
      ),
      HealthArticleModel(
        id: 'news_3',
        title: 'Tầm quan trọng của việc kiểm tra sức khỏe định kỳ',
        summary: 'Khám sức khỏe định kỳ giúp phát hiện sớm các bệnh tiềm ẩn và tăng khả năng điều trị thành công.',
        source: 'Vinmec Health',
        publishedAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }
}
