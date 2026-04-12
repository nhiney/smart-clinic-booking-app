# 3. Bệnh nhân (Patient)

## Phân chia chức năng

### Chức năng 1: 


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

## QR Check-in
- Nhận mã QR
- Check-in tại bệnh viện

Bổ sung:
- QR dynamic (có expiry)
- QR signed token chống giả mạo

---

## Navigation
- Trang chủ
- Hồ sơ
- Phiếu khám
- Thông báo
- Tài khoản

---

### Chức năng 2: Medical + AI + Support + Experience

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

## Nhập viện
- Đăng ký nhập viện

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

## Đánh giá
- Rating bác sĩ
- Review bệnh viện
