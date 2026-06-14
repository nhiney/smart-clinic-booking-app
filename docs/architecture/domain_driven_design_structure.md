# Cấu trúc Thư mục Domain-Driven Design (DDD)

Dự án hiện tại áp dụng kiến trúc Domain-Driven Design (DDD) để gom nhóm các features thành 7 Domain (Bounded Contexts) chính thay vì để dàn trải 26 features độc lập. 
Cấu trúc này giúp tăng tính cohesion, giảm coupling, và định hướng phát triển dễ dàng cho các team/module khác nhau.

## Danh sách 7 Bounded Contexts

1. **`identity/`**
   - **Mục đích:** Quản lý người dùng, hồ sơ cá nhân và xác thực.
   - **Các Features:** `auth`, `kyc`, `profile`, `family`.

2. **`booking_system/`**
   - **Mục đích:** Quá trình đặt lịch khám, xếp hàng chờ và check-in.
   - **Các Features:** `booking`, `appointment`, `checkin`.

3. **`clinical/`**
   - **Mục đích:** Nghiệp vụ chuyên môn y khoa (dành cho cả bác sĩ và bệnh nhân).
   - **Các Features:** `consultation`, `medical_record`, `lab`, `medication`, `admission`, `clinical` (giao diện cốt lõi cho bác sĩ).

4. **`finance/`**
   - **Mục đích:** Xử lý thanh toán, hóa đơn và bảo hiểm.
   - **Các Features:** `payment`, `invoice`, `insurance`.

5. **`discovery/`**
   - **Mục đích:** Tra cứu, tìm kiếm phòng khám, bác sĩ, và tin tức y tế.
   - **Các Features:** `home`, `maps`, `content`.

6. **`support_services/`**
   - **Mục đích:** Các tiện ích hỗ trợ, cảnh báo, thông báo, chatbot.
   - **Các Features:** `support`, `notification`, `sos`, `review`, `ai` (Triage AI).

7. **`roles/`**
   - **Mục đích:** Giao diện Dashboard/Control Panel đặc thù cho các roles không phải là end-user chính (Admin, Bác sĩ).
   - **Các Features:** `doctor` (lịch trực bác sĩ, trạng thái), `admin` (dashboard, IAM).

## Cách import
Thay vì import `package:smart_clinic_booking/features/feature_name/...`, cấu trúc import giờ sẽ là:
`package:smart_clinic_booking/features/domain_name/feature_name/...`
*Lưu ý: Tất cả code liên quan đến import đã được refactor tự động bằng script.*
