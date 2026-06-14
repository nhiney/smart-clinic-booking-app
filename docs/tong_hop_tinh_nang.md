# Tổng hợp Phân rã Chi tiết Tính năng ICare (Task-Oriented)

Dưới đây là bản phân rã tính năng chi tiết đến mức module/task, được thiết kế chuyên biệt để giúp bạn dễ dàng bóc tách thành các Epic, Feature và Ticket (Jira/Trello) để phân công cho đội ngũ phát triển.

---

## 1. Vai trò: Bệnh nhân (Patient)
*App Mobile dành cho người dùng cuối (End-User).*

### 1.1 Module Xác thực & Định danh (Auth & KYC)
*   [ ] Giao diện Đăng ký bằng Số điện thoại/Email.
*   [ ] Xác thực OTP qua SMS/Email (Firebase Auth).
*   [ ] Giao diện Đăng nhập & Quên mật khẩu.
*   [ ] Quản lý phiên đăng nhập (Refresh token, Device binding).
*   [ ] Định danh điện tử (KYC): Upload CMND/CCCD, chụp ảnh chân dung xác thực.

### 1.2 Module Hồ sơ Cá nhân & Gia đình (Profile & Family)
*   [ ] CRUD (Tạo, Xem, Sửa, Xóa) thông tin cá nhân (Họ tên, ngày sinh, giới tính, nhóm máu, tiền sử dị ứng).
*   [ ] Thêm hồ sơ người thân (Family Profile) để đặt lịch hộ.
*   [ ] Chỉnh sửa, cập nhật bệnh lý nền của người thân.

### 1.3 Module Tìm kiếm & Khám phá (Search & Maps)
*   [ ] Trang chủ (Home) hiển thị Dịch vụ, Bác sĩ nổi bật, Tin tức y tế.
*   [ ] Bộ lọc tìm kiếm bác sĩ/phòng khám (Theo chuyên khoa, đánh giá, số năm kinh nghiệm).
*   [ ] Tích hợp Bản đồ (Google Maps/OSM): Tìm bệnh viện gần nhất, tính khoảng cách, chỉ đường.

### 1.4 Module Đặt lịch Khám (Appointment & Booking)
*   [ ] Chọn loại hình dịch vụ: Khám tại viện, Xét nghiệm, Khám doanh nghiệp, Tái khám.
*   [ ] Luồng chọn ngày giờ (Slot selection) kết hợp kiểm tra slot trống (Real-time).
*   [ ] Luồng nhập triệu chứng ban đầu.
*   [ ] **Core Logic:** Khóa slot tạm thời (Lock slot) trong thời gian chờ thanh toán (chống Double-booking).
*   [ ] Chức năng: Đổi lịch (Reschedule), Hủy lịch (Cancel).
*   [ ] Đăng ký Danh sách chờ (Waitlist) khi hết slot trống.

### 1.5 Module Thanh toán & Viện phí (Payment, Invoice)
*   [ ] Tích hợp Cổng thanh toán (VNPay, MoMo, Stripe).
*   [ ] Xử lý luồng thanh toán viện phí, phí đặt lịch.
*   [ ] Xử lý hoàn tiền (Refund logic) khi hủy lịch hợp lệ.
*   [ ] Lưu trữ và hiển thị Lịch sử giao dịch, Hóa đơn điện tử (Invoice).
*   [ ] Quản lý thẻ Bảo hiểm y tế (Insurance) & Tính toán miễn giảm.

### 1.6 Module Hồ sơ Y tế & Cận lâm sàng (EMR & Lab)
*   [ ] Hiển thị lịch sử các lần khám bệnh (chuẩn HL7/FHIR).
*   [ ] Hiển thị kết quả xét nghiệm, chẩn đoán hình ảnh (Cận lâm sàng).
*   [ ] Chức năng Upload tệp y khoa cá nhân (PDF, X-ray, MRI) có quản lý phiên bản.
*   [ ] Chia sẻ/Cấp quyền xem hồ sơ bệnh án cho bác sĩ.

### 1.7 Module Đơn thuốc & Hỗ trợ (Medication & Support)
*   [ ] Xem chi tiết toa thuốc (Tên thuốc, liều lượng, hướng dẫn).
*   [ ] Theo dõi uống thuốc (Pill Tracker): Nhắc nhở uống thuốc hàng ngày.
*   [ ] Đặt mua thuốc trực tuyến.
*   [ ] Gọi cấp cứu khẩn cấp (SOS button).
*   [ ] Đăng ký thủ tục nhập viện trực tuyến (Admission).
*   [ ] Hệ thống Ticket, Chatbot, FAQ, Hotline hỗ trợ khách hàng.
*   [ ] Đánh giá & Xếp hạng (Rating/Review) bác sĩ sau khi khám.

### 1.8 Module Thông báo & Check-in (Notification & Queue)
*   [ ] Lắng nghe Thông báo đa kênh (Push Notification, SMS, Email).
*   [ ] Tạo và hiển thị mã QR Code động (có expiry token) dùng để Check-in.
*   [ ] Màn hình theo dõi số thứ tự và thời gian chờ dự kiến (Estimated Wait Time).

---

## 2. Vai trò: Bác sĩ (Doctor)
*App/Web Tablet dành cho đội ngũ chuyên môn.*

### 2.1 Module Lịch trình & Trạng thái (Doctor Schedule)
*   [ ] Đăng nhập hệ thống bác sĩ.
*   [ ] Xem lịch biểu làm việc (Ngày/Tuần/Tháng).
*   [ ] Bật/Tắt trạng thái làm việc (Đang khám / Tạm nghỉ / Rảnh).

### 2.2 Module Hàng đợi Phòng khám (Clinic Queue)
*   [ ] Hiển thị danh sách bệnh nhân đang chờ theo thời gian thực.
*   [ ] **Core Logic:** Sắp xếp hàng đợi theo mức độ ưu tiên (Cấp cứu > Người cao tuổi > Thông thường).
*   [ ] Nút "Gọi số tiếp theo" (Gửi trigger cập nhật màn hình Kiosk bên ngoài và App bệnh nhân).
*   [ ] Quản lý trạng thái bệnh nhân (Đang chờ -> Đang khám -> Hoàn tất -> Vắng mặt).

### 2.3 Module Lâm sàng & Khám bệnh (Clinical & EMR)
*   [ ] Giao diện truy cập nhanh lịch sử bệnh án (EMR) của bệnh nhân trước khi khám.
*   [ ] Xem kết quả Cận lâm sàng / Xét nghiệm của bệnh nhân.
*   [ ] Form nhập liệu kết luận chẩn đoán, ghi chú lâm sàng.
*   [ ] Luồng ra quyết định chỉ định bệnh nhân đi xét nghiệm thêm.

### 2.4 Module Kê đơn thuốc (Medication Prescription)
*   [ ] Tìm kiếm thuốc từ danh mục hệ thống.
*   [ ] Kê đơn (Chọn thuốc, số lượng, liều dùng, ghi chú sử dụng).
*   [ ] Chữ ký điện tử / Xác nhận lưu đơn thuốc.

### 2.5 Hoàn tất & Đóng ca
*   [ ] Nút "Hoàn tất ca khám".
*   [ ] Tự động lưu hồ sơ vào EMR.
*   [ ] Tự động tính toán lại EWT cho những người đang chờ bên ngoài.

---

## 3. Vai trò: Quản trị viên (Admin)
*Web Dashboard quản lý toàn hệ thống.*

### 3.1 Module Quản trị Hệ thống & Người dùng (IAM)
*   [ ] Quản lý danh sách tài khoản: Admin, Bác sĩ, Nhân sự.
*   [ ] Thiết lập Phân quyền (Role-Based Access Control - RBAC).

### 3.2 Module Danh mục Cấu hình (Master Data Catalog)
*   [ ] CRUD Chi nhánh / Phòng khám.
*   [ ] CRUD Chuyên khoa (Departments).
*   [ ] CRUD Danh mục Dịch vụ khám & Bảng giá.
*   [ ] CRUD Danh mục Thuốc & Vật tư y tế.

### 3.3 Module Điều phối & Lịch biểu (Global Scheduling)
*   [ ] Giao diện Drag & Drop phân công ca trực cho bác sĩ.
*   [ ] Quản lý đơn xin nghỉ phép, điều phối bác sĩ thay thế.
*   [ ] Cấu hình khung giờ (Slot interval: ví dụ 15 phút/ca).

### 3.4 Module Báo cáo, Giám sát & Bảo mật (Dashboard & Audit)
*   [ ] Biểu đồ thống kê số lượng bệnh nhân, lưu lượng theo khung giờ.
*   [ ] Báo cáo Doanh thu theo phương thức thanh toán.
*   [ ] Báo cáo Hiệu suất bác sĩ (Thời gian khám trung bình).
*   [ ] **Security:** Xem Nhật ký hệ thống (Audit Logs) được băm SHA-256 để kiểm toán bảo mật dữ liệu.
*   [ ] Quản lý trạng thái các thiết bị Kiosk (Online/Offline) và cấp phát Service Account Token.

---

## 4. Vai trò: Thiết bị Bot Kiosk (Automated Booking Agent)
*App chạy trên thiết bị Kiosk thông minh đặt tại bệnh viện.*

### 4.1 Module Lõi Hệ thống & Xác thực (Core & Auth)
*   [ ] Đăng nhập ngầm bằng Service Account (Mock Auth ẩn).
*   [ ] Giám sát kết nối mạng: Hiện Overlay "Đang bảo trì" nếu rớt mạng.

### 4.2 Module Nhận diện & AI Tương tác (Voice UI & AI Triage)
*   [ ] Tích hợp Speech-to-Text (STT): Nhận diện giọng nói Tiếng Việt.
*   [ ] Tích hợp Text-to-Speech (TTS): Phát âm thanh hướng dẫn bằng Tiếng Việt.
*   [ ] Xử lý AI Triage: Gửi text nhận diện lên AI để phân tích triệu chứng và trả về mã chuyên khoa phù hợp.
*   [ ] State Machine giao diện: Idle (Chờ) -> Listening (Đang nghe) -> Processing (Xử lý) -> Success/Error.

### 4.3 Module Đặt lịch (Voice Booking)
*   [ ] Gọi API lấy danh sách bác sĩ / khung giờ trống theo kết quả AI.
*   [ ] Đọc phản hồi để bệnh nhân xác nhận (VD: "Khám bác sĩ A lúc 9h. Đọc Xác nhận hoặc Hủy").
*   [ ] **Core Logic:** Thực thi Transaction Firestore đặt lịch trực tiếp.

### 4.4 Module Quản lý Phiên (Session Timeout)
*   [ ] Khóa toàn bộ tương tác chạm (Touch) khi máy đang ở trạng thái Listening.
*   [ ] Đếm ngược 60s không thao tác -> Hiện đếm ngược 5s -> Xóa State (Reset về màn hình chính).
*   [ ] (Backend Task) Cloud Function: Dọn dẹp rác (TTL) các slot booking Kiosk tạo ra nhưng bị kẹt quá 5 phút.

---

## 5. Vai trò: Thiết bị QR Kiosk (Check-in Device)
*App chạy trên Kiosk quét mã tại quầy Lễ tân.*

### 5.1 Module Phần cứng & Camera (Scanner Hardware)
*   [ ] Tích hợp Mobile Scanner đọc mã QR.
*   [ ] Lắng nghe App Lifecycle: Tắt camera khi app ẩn, bật lại khi app hiện (chống treo camera).
*   [ ] **Core Logic (Throttling):** Khóa luồng ngay lập tức khi phát hiện Frame QR đầu tiên (ngăn việc call API check-in 10 lần/giây).

### 5.2 Module Nghiệp vụ Check-in (Business Logic)
*   [ ] Giải mã chuỗi JSON từ mã QR.
*   [ ] Thực thi Firestore Transaction nguyên tử (Atomic):
    *   Kiểm tra tính tồn tại của booking.
    *   Kiểm tra logic thời gian (Báo lỗi `TooEarlyException` nếu đến sớm hơn 60 phút).
    *   Kiểm tra logic lặp (Báo lỗi `AlreadyCheckedInException` nếu đã quét trước đó).
*   [ ] Đẩy trạng thái `arrived` lên server và lấy Queue Token (Số thứ tự).

### 5.3 Module Giao diện Phản hồi (Micro-interactions)
*   [ ] Play âm thanh (Beep thành công / Buzz thất bại).
*   [ ] Hiển thị Overlay toàn màn hình khổng lồ (Màu Xanh: Thành công kèm Số thứ tự / Màu Đỏ: Báo lỗi chi tiết bằng Tiếng Việt).
*   [ ] **Auto-Reset:** Tự động tắt Overlay và mở lại Scanner sau đúng 3 giây không cần thao tác bấm.
*   [ ] UI/UX Cảnh báo mất kết nối mạng.

---

## 6. Lưu ý về Quản lý Mã nguồn (Git Rules)
*Để đảm bảo bảo mật và source code sạch, các thành viên lưu ý **TUYỆT ĐỐI KHÔNG** đẩy các thư mục/file sau lên Git (đã được cấu hình trong `.gitignore`):*

*   **Tài liệu & Log nội bộ:** Thư mục `docs/` (chứa yêu cầu, thiết kế hệ thống, tài liệu tổng hợp này) và các file `*.log`.
*   **Môi trường & Bảo mật (Secrets):** Các file `.env`, `local.properties`, file keystore/jks (chứa chứng chỉ app), và các file mật khẩu.
*   **Firebase Config (Nhạy cảm):** `google-services.json` (Android) và `GoogleService-Info.plist` (iOS) - *Mỗi máy dev tự cấu hình nội bộ hoặc tải từ Firebase Console*.
*   **Build & Cache (Code rác):** Các thư mục `build/`, `.dart_tool/`, `.pub-cache/`, `ios/Pods/`, `android/.gradle/`.
*   **Cấu hình IDE:** Thư mục `.idea/`, `.vscode/`, `.cursor/`, và `.DS_Store` (Mac).
