import 'dart:convert';

enum IntentType {
  booking,
  cancel,
  doctorInfo,
  timeInfo,
  unknown
}

class ParsedIntent {
  final IntentType type;
  final Map<String, String> entities;
  final String originalText;

  ParsedIntent({
    required this.type,
    this.entities = const {},
    required this.originalText,
  });

  @override
  String toString() => 'ParsedIntent(type: $type, entities: $entities, text: $originalText)';
}

class IntentParser {
  // Regex patterns for intents (Vietnamese)
  static final RegExp _bookingPattern = RegExp(r'(đặt|hẹn|khám|tạo|đăng ký)\s+(lịch|khám|hẹn|lịch khám)', caseSensitive: false);
  static final RegExp _cancelPattern = RegExp(r'(hủy|không|dừng|bỏ)\s+(lịch|hẹn|khám|lịch khám)', caseSensitive: false);
  static final RegExp _doctorPattern = RegExp(r'(bác sĩ|ai|tên|danh sách)\s+(khám|điều trị|chữa|nào)', caseSensitive: false);
  static final RegExp _timePattern = RegExp(r'(mấy giờ|khi nào|lúc nào|thời gian|giờ giấc)', caseSensitive: false);

  // Entities extraction (Specialties)
  static final Map<String, List<String>> _specialtyMap = {
    'Nhi khoa': ['nhi', 'trẻ em', 'em bé'],
    'Nội khoa': ['nội', 'nội tổng quát'],
    'Ngoại khoa': ['ngoại', 'phẫu thuật'],
    'Sản khoa': ['sản', 'phụ khoa', 'bà bầu', 'mang thai'],
    'Mắt': ['mắt', 'nhãn khoa'],
    'Da liễu': ['da liễu', 'da', 'mụn'],
    'Tai Mũi Họng': ['tai', 'mũi', 'họng', 'tmh'],
    'Răng Hàm Mặt': ['răng', 'nha khoa', 'hàm', 'mặt'],
  };

  ParsedIntent parse(String text, [ParsedIntent? context]) {
    final cleanText = text.toLowerCase().trim();
    
    IntentType type = IntentType.unknown;
    Map<String, String> entities = {};

    // 1. Check for basic intents
    if (_bookingPattern.hasMatch(cleanText)) {
      type = IntentType.booking;
    } else if (_cancelPattern.hasMatch(cleanText)) {
      type = IntentType.cancel;
    } else if (_doctorPattern.hasMatch(cleanText)) {
      type = IntentType.doctorInfo;
    } else if (_timePattern.hasMatch(cleanText)) {
      type = IntentType.timeInfo;
    }

    // 2. Context handling (Section VI)
    if (type == IntentType.unknown && context != null) {
      if (context.type == IntentType.booking) {
        // If previous was booking, and current text has specialty, it's still booking
        type = IntentType.booking;
      }
    }

    // 3. Entity Extraction
    _specialtyMap.forEach((specialty, keywords) {
      for (var kw in keywords) {
        if (cleanText.contains(kw)) {
          entities['specialty'] = specialty;
          break;
        }
      }
    });

    // Time extraction
    if (cleanText.contains('mai')) entities['date'] = 'Ngày mai';
    if (cleanText.contains('hôm nay')) entities['date'] = 'Hôm nay';
    if (cleanText.contains('chiều')) entities['time_slot'] = 'Buổi chiều';
    if (cleanText.contains('sáng')) entities['time_slot'] = 'Buổi sáng';
    
    // Hour extraction (e.g., "8 giờ", "8h")
    final hourMatch = RegExp(r'(\d+)\s*(giờ|h)').firstMatch(cleanText);
    if (hourMatch != null) {
      entities['hour'] = hourMatch.group(1)!;
    }

    return ParsedIntent(
      type: type,
      entities: entities,
      originalText: text,
    );
  }
}
