# ICare — System Tasks & Architecture (Production)

---

# 1. Kiến trúc hệ thống

## Áp dụng:

- Clean Architecture
- RBAC (Role-Based Access Control)
- Realtime + Offline-first
- AI Voice Assistant

## Bổ sung:

- Microservices-ready architecture
- Event-driven architecture (Cloud Functions)
- CQRS (Command Query Responsibility Segregation)
- Multi-tenant (nhiều bệnh viện)

---

# 3. 3 Layer chính

### 1. Presentation Layer

- UI (Screen, Widget)
- State (BLoC / Provider)

Bổ sung:

- Responsive (mobile, tablet)
- Accessibility (font lớn, voice navigation)
- Dark mode
- Skeleton loading
- Error state / Empty state

---

### 2. Domain Layer

- Business logic
- UseCase
- Entity

Bổ sung:

- Domain validation rules
- RBAC guard trong UseCase
- Scheduling engine (xử lý logic đặt lịch)

---

### 3. Data Layer

- Firebase / API
- Repository
- Model + Mapper

Bổ sung:

- API abstraction (ready backend riêng)
- Cache strategy (memory + Hive)
- Retry / timeout (Dio interceptor)

---

# 2. Các vai trò trong hệ thống

1. Bệnh nhân (Patient)
2. Bác sĩ (Doctor)
3. Quản trị viên (Admin)
4. Thiết bị người dùng (User Device)
5. Thiết bị quét QR (Scanner Device)

Bổ sung: 6. Super Admin  
7. Hospital Manager

---

# 3. Bệnh nhân (Patient)

## Xác thực & tài khoản

- Đăng ký / đăng nhập bằng OTP
- Quên mật khẩu:
  - Gửi OTP qua phone/email
  - Xác nhận → đặt lại mật khẩu

Bổ sung:

- Refresh token
- Device binding
- Session management

---

## Quản lý cá nhân

- Cập nhật thông tin cá nhân
- Lưu thông tin phục vụ khám bệnh
- Nhập email để:
  - Nhận hồ sơ khám bệnh
  - Lưu trữ online

---

## Tìm kiếm & khám bệnh

- Tìm bác sĩ theo:
  - Chuyên khoa
  - Đánh giá
  - Vị trí
- Xem chi tiết:
  - Kinh nghiệm
  - Lịch làm việc

---

## Chọn bệnh viện

- Xem:
  - Tên
  - Đánh giá
  - Địa chỉ
- Gợi ý:
  - Gần nhất
  - Theo nhu cầu

---

## Đặt lịch khám

### Bao gồm:

- Khám tại cơ sở
- Khám chuyên khoa
- Xét nghiệm
- Mua thuốc
- Khám doanh nghiệp

### Quy trình:

- Chọn ngày giờ
- Nhập triệu chứng
- Chọn khoa khám

Bổ sung:

- Lock slot (giữ lịch tạm)
- Reschedule (đổi lịch)
- Waitlist (danh sách chờ)
- Auto cancel nếu chưa thanh toán
- Chống double booking

---

## Hủy lịch

- Hủy lịch đã đặt
- Cập nhật trạng thái

---

## Quản lý khám bệnh

- Lịch sử khám
- Hồ sơ bệnh án
- Kết quả cận lâm sàng
- Đơn thuốc
- Theo dõi thuốc

Bổ sung:

- Upload file (PDF, X-ray, MRI)
- Versioning hồ sơ
- Chia sẻ hồ sơ
- Chuẩn HL7 / FHIR

---

## Thanh toán & hồ sơ

- Thanh toán viện phí
- Xem hóa đơn
- Lưu hồ sơ khám

Bổ sung:

- VNPay / MoMo / Stripe
- Payment status
- Refund
- Transaction history

---

## Nhập viện

- Đăng ký nhập viện

---

## QR Check-in

- Nhận mã QR
- Check-in tại bệnh viện

Bổ sung:

- QR dynamic (có expiry)
- QR signed token chống giả mạo

---

## Thông báo

- Xác nhận lịch
- Nhắc lịch khám
- Hủy lịch

Bổ sung:

- Push + Email + SMS
- Notification theo hành vi
- Reminder thông minh

---

## AI & Voice

### Voice Assistant:

- Đặt lịch bằng giọng nói
- Hủy lịch bằng giọng nói
- Gợi ý thông minh
- Phản hồi TTS

### Voice Chat:

- Voice → Text
- Gợi ý:
  - lịch
  - thời gian
  - bác sĩ

Bổ sung:

- AI triage (phân tích triệu chứng)
- AI recommendation (bác sĩ, lịch)
- Chatbot context-aware
- Nhắc uống thuốc bằng AI

---

## Hỗ trợ bệnh nhân

- Chatbot
- Hotline
- FAQ
- Hướng dẫn

Bổ sung:

- Ticket support system

---

## Tính năng bổ sung

- Tin tức
- Dịch vụ nổi bật
- Bảng giá
- Thư viện sức khỏe
- Khảo sát
- Liên hệ

---

## Bản đồ

- Google Maps API
- Tìm bệnh viện gần

---

## Navigation

- Trang chủ
- Hồ sơ
- Phiếu khám
- Thông báo
- Tài khoản

---

# 4. Bác sĩ (Doctor)

## Đăng nhập

- Theo role bác sĩ

---

## Quản lý lịch

- Xem lịch khám
- Xác nhận / từ chối

---

## Khám bệnh

- Cập nhật trạng thái
- Xem hồ sơ bệnh nhân

---

## Bệnh án

- Chẩn đoán
- Đơn thuốc
- Ghi chú

Bổ sung:

- Ký số đơn thuốc
- Gửi đơn thuốc qua email/app

---

## Nâng cao

- Dashboard
- Quản lý thời gian rảnh

Bổ sung:

- Video call (telemedicine)
- Chat với bệnh nhân
- AI hỗ trợ chẩn đoán
- Rating bác sĩ

---

# 5. Admin

## Quản lý user

- Xem danh sách
- Khóa tài khoản
- Phân quyền

---

## Quản lý bác sĩ

- Duyệt hồ sơ
- Chỉnh sửa thông tin

---

## Thống kê

- Tổng user
- Tổng lịch khám
- Hoạt động hệ thống

Bổ sung:

- Doanh thu
- Tỷ lệ hủy lịch
- No-show rate

---

Bổ sung:

- CMS (quản lý nội dung)
- Voucher / khuyến mãi
- Quản lý khiếu nại

---

# 6. Hospital Management

- Quản lý khoa
- Quản lý phòng khám
- Quản lý giường bệnh
- Quản lý thiết bị y tế

---

# 7. Thiết bị người dùng

- Nhận notification (FCM)
- Cache (Hive)
- Đồng bộ dữ liệu
- Offline

Bổ sung:

- Background sync
- Offline queue retry
- Smart cache invalidation

---

# 8. Thiết bị QR

## Chức năng

- Quét QR
- Gửi server

## Backend

- Xác thực QR
- Kiểm tra lịch

## Kết quả

- Thành công
- Thất bại

---

# 9. Công nghệ

- Flutter
- Firebase:
  - Firestore
  - Auth
  - FCM
- Provider + BLoC
- GetIt + Injectable
- Hive
- Dio

Bổ sung:

- Cloud Functions
- REST / GraphQL API
- CI/CD (GitHub Actions / Codemagic)
- Crashlytics
- Logging system

---

# 10. Quy trình

## Đặt lịch

Tìm bác sĩ → chọn giờ → xác nhận → lưu DB

Bổ sung:
Lock slot → Payment → Confirm → Release nếu timeout

---

## QR

Scan → xác thực → cập nhật

---

## Voice

Voice → Text → Intent → Confirm

---

# 11. Database

## Collections:

- users
- doctors
- appointments
- medical_records
- medications
- notifications

Bổ sung:

- payments
- reviews
- hospitals
- departments
- audit_logs
- support_tickets

---

# 12. Bảo mật

- Firestore Rules
- RBAC
- OTP
- QR mã hóa

Bổ sung:

- JWT + Refresh token
- Device binding
- Audit log
- Encryption dữ liệu nhạy cảm
- Rate limiting
- GDPR / HIPAA-like

---

# 13. Notification

- Xác nhận
- Nhắc lịch
- Hủy lịch

Bổ sung:

- Multi-channel
- Smart scheduling

---

# 13. Testing

- Unit Test
- Widget Test
- Integration Test

Bổ sung:

- E2E Test
- Load testing
- Security testing

---

# 14. Xử lý lỗi

- Trùng lịch
- Mất mạng
- OTP sai
- QR hết hạn

Bổ sung:

- Retry mechanism
- Global error handler
- Crash reporting

---

# 15. Mở rộng

- Thanh toán online
- Video call
- AI nâng cao
- Admin web

Bổ sung:

- Multi-language
- Multi-hospital
- Plugin system
- AI analytics
