# ICare — System Tasks & Architecture (Production)

Ứng dụng đặt lịch khám bệnh thông minh hướng tới:
- Người lớn tuổi, người ở nông thôn (ít am hiểu công nghệ)
- Người dùng tri thức, người nước ngoài

=> Yêu cầu:
- UI cực kỳ đơn giản, dễ dùng
- Nhưng vẫn chuyên nghiệp, mạnh mẽ, scalable

---

# 1. Kiến trúc hệ thống

## Áp dụng:

- Clean Architecture
- RBAC (Role-Based Access Control)
- Realtime + Offline-first
- AI Voice Assistant

## Nâng cao:

- Microservices-ready architecture
- Event-driven architecture (Cloud Functions)
- CQRS (Command Query Responsibility Segregation)
- Multi-tenant (nhiều bệnh viện)

## Bổ sung quan trọng:

- Idempotent API (tránh double booking/payment)
- Eventual consistency handling
- Distributed locking (booking slot)
- Monitoring & Observability
- Disaster recovery (backup, restore, failover)
- Cost optimization (Firebase quota control)

---

# 2. System Layers

## 1. Presentation Layer

- UI (Screen, Widget)
- State (BLoC / Provider)

### Bổ sung:
- Responsive (mobile, tablet)
- Accessibility:
  - Font lớn
  - Voice navigation
  - UI tối giản cho người già
- Dark mode
- Skeleton loading
- Error state / Empty state
- Multi-language (vi/en)

---

## 2. Domain Layer

- Business logic
- UseCase
- Entity

### Bổ sung:
- Domain validation rules
- RBAC guard trong UseCase
- Scheduling engine (đặt lịch)
- Queue engine (xếp hàng)
- Appointment lifecycle management

---

## 3. Data Layer

- Firebase / API
- Repository
- Model + Mapper
- SQLite / Hive

### Bổ sung:
- API abstraction
- Cache strategy (memory + Hive)
- Retry / timeout (Dio interceptor)
- Offline queue
- Sync engine

---

# 3. Vai trò hệ thống

1. Patient (Bệnh nhân)
2. Doctor (Bác sĩ)
3. Admin
4. User Device
5. QR Scanner Device

---

# 4. Patient (Bệnh nhân)

## Xác thực

- OTP login
- Quên mật khẩu (OTP)

### Bổ sung:
- JWT + Refresh token
- Device binding
- Session management

---

## Hồ sơ cá nhân

- Cập nhật thông tin
- Lưu thông tin khám
- Email nhận hồ sơ

---

## Tìm kiếm

- Theo chuyên khoa
- Đánh giá
- Vị trí

---

## Bệnh viện

- Danh sách bệnh viện
- Gợi ý gần nhất

---

## Đặt lịch khám

### Loại:
- Khám
- Xét nghiệm
- Nhập viện
- Cấp cứu
- Mua thuốc

---

## 🔥 Quy trình thực tế (CRITICAL)

1. Đặt lịch
2. Thanh toán
3. Nhận QR
4. Check-in
5. Lấy số thứ tự
6. Chờ khám
7. Vào khám
8. Xét nghiệm (nếu có)
9. Nhận kết quả
10. Kết luận
11. Thanh toán
12. Nhận thuốc

---

## Appointment Lifecycle

- Booked
- Confirmed
- Checked-in
- In-progress
- Completed
- Cancelled
- No-show

---

## Bổ sung logic

- Lock slot
- Waitlist
- Reschedule
- Auto cancel
- Anti double booking

---

## Queue System (NEW)

- Số thứ tự
- Real-time queue
- Ước lượng thời gian
- Priority queue (người già, cấp cứu)

---

## No-show Handling

- Detect no-show
- Auto release slot
- Penalize user

---

## Hồ sơ bệnh án

- Lịch sử khám
- Kết quả
- Đơn thuốc

### Bổ sung:
- Upload file (PDF, X-ray)
- Versioning
- Share record
- HL7 / FHIR standard

---

## Thanh toán

- VNPay / MoMo / Stripe

### Bổ sung:
- Payment status
- Refund
- Transaction history
- Idempotent payment

---

## QR Check-in

- QR dynamic (expiry)
- Signed QR token

---

## Notification

- Push / SMS / Email
- Reminder thông minh

---

## AI & Voice

- Voice booking
- Voice cancel
- AI triage (phân tích triệu chứng)
- AI recommendation
- Chatbot context-aware

---

## Support

- Chatbot
- Hotline
- Ticket system

---

## Bản đồ

- Google Maps
- Gợi ý gần nhất

---

# 5. Doctor

## Chức năng

- Xem lịch
- Xác nhận lịch
- Khám bệnh
- Xem hồ sơ

---

## Bệnh án

- Chẩn đoán
- Đơn thuốc

### Bổ sung:
- Ký số
- Gửi đơn thuốc
- Upload kết quả

---

## Nâng cao

- Dashboard
- Quản lý thời gian

### Bổ sung:
- Video call
- Chat
- AI hỗ trợ
- Rating

---

## Workload Management

- Giới hạn số bệnh nhân/ngày
- Phân bổ đều
- Break time

---

# 6. Admin

## Quản lý

- User
- Doctor
- Bệnh viện
- Khoa
- Phòng
- Giường bệnh
- Thiết bị

---

## Thống kê

- User
- Booking
- Doanh thu
- No-show rate

---

## Bổ sung

- CMS
- Voucher
- Complaint system
- Audit log

---

# 7. Device

## User Device

- Offline
- Sync
- Cache

### Bổ sung:
- Background sync
- Retry queue
- Cache invalidation

---

## QR Device

- Scan QR
- Validate
- Assign queue

---

# 8. Công nghệ

- Flutter
- Firebase:
  - Firestore
  - Auth
  - FCM
- BLoC / Provider
- GetIt
- Hive
- Dio

---

## Bổ sung

- Cloud Functions
- REST / GraphQL
- CI/CD
- Crashlytics
- Logging system

---

# 9. Database

## Collections:

- users
- doctors
- appointments
- medical_records
- medications
- notifications
- payments
- hospitals
- departments
- reviews
- audit_logs
- support_tickets

---

# 10. Bảo mật

- RBAC
- OTP
- Firestore rules

---

## Bổ sung:

- JWT
- Encryption dữ liệu
- Audit log đầy đủ
- Rate limiting
- HIPAA-like compliance

---

# 11. Monitoring & Reliability

- Logging tập trung
- Crash tracking
- Health check
- Alert system

---

# 12. Backup & Recovery

- Backup định kỳ
- Restore
- Failover

---

# 13. Testing

- Unit
- Widget
- Integration
- E2E
- Load test
- Security test

---

# 14. Error Handling

- Retry
- Global handler
- Crash report

---

# 15. Mở rộng

- Multi-language
- Multi-hospital
- Plugin system
- AI analytics

---

# 🎯 KẾT LUẬN

Hệ thống ICare đạt mức:
- Production-ready architecture
- Real-world hospital workflow
- Scalable & secure
- Accessible for all users