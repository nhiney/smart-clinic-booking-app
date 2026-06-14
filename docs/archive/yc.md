Hãy đóng vai Senior Mobile AI Engineer + Flutter Architect.

Triển khai module "AI & Voice Assistant" chạy THỰC TẾ trên mobile (Android + iOS), production-ready, không bug.

========================================
I. BẮT BUỘC (CRITICAL)
========================================

- KHÔNG dùng API trả phí
- Code phải chạy được ngay (flutter run)
- Không lỗi compile
- Không thiếu import:
  import 'package:flutter/material.dart';

========================================
II. PERMISSION (BẮT BUỘC)
========================================

Thiết lập:

1. Android:
- RECORD_AUDIO permission

2. iOS:
- Info.plist:
  NSMicrophoneUsageDescription

3. Runtime permission handling

========================================
III. STATE MANAGEMENT
========================================

- Dùng Riverpod hoặc Bloc
- State gồm:
  - idle
  - listening
  - processing
  - speaking

========================================
IV. VOICE FLOW
========================================

Voice → STT → Text → Intent → Action → TTS

Xử lý:
- Nếu không nghe được → báo lỗi
- Nếu không parse được → hỏi lại

========================================
V. INTENT PARSER (VIETNAMESE)
========================================

- Regex + keyword
- Handle:
  - đặt lịch
  - hủy lịch
  - hỏi bác sĩ
  - hỏi thời gian

- Extract:
  - ngày
  - giờ
  - chuyên khoa

========================================
VI. CONTEXT-AWARE CHATBOT
========================================

- Lưu context trong memory
- Ví dụ:
  intent trước = đặt lịch
  → câu sau bổ sung thông tin

- Reset context sau khi hoàn thành

========================================
VII. ERROR HANDLING
========================================

Handle:
- Không có voice input
- Speech sai
- Không hiểu intent

========================================
VIII. LIFECYCLE
========================================

- dispose():
  - stopListening()
  - stopTTS()

========================================
IX. VOICE CONFIG
========================================

speech_to_text:
- localeId: 'vi_VN'

========================================
X. ACTION THẬT
========================================

- Khi đặt lịch:
  → gọi function booking
- Khi hủy:
  → gọi cancel
- Không được chỉ log

========================================
XI. UI/UX
========================================

- Mic animation
- Loading khi đang nghe
- Hiển thị text realtime

========================================
XII. DEBUG
========================================

- Log:
  - text nhận được
  - intent
  - entity

========================================
XIII. OUTPUT
========================================

1. Kiến trúc
2. Flow
3. Code đầy đủ:
   - VoiceService
   - AIService
   - IntentParser
   - UI Screen
4. Không thiếu file
5. Không lỗi compile