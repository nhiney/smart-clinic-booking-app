ở giao diện trang chủ của người dùng kế bên nút thông báo là ngôn ngữ còn thông tin người dùng sẽ để lại ở chỗ ngôn ngữ, thiết kế giao diện trang quản lý hồ sơ người dùng trước cho tôi
## Quản lý cá nhân
- Cập nhật thông tin cá nhân
- Lưu thông tin phục vụ khám bệnh
- Nhập email để:
  - Nhận hồ sơ khám bệnh
  - Lưu trữ online

---
# 🎯 ROLE
You are a Senior Flutter UI/UX Designer + Flutter Architect + Product Designer specializing in healthcare apps.

You think like:
- UI/UX Expert → clean, modern, emotional, easy to use
- Product Designer → logical layout, user-friendly flow
- Flutter Developer → implementable UI (not just design)

---

# 🎯 TASK

Design and implement the **Patient Profile Management Screen UI** inside the Patient Home Module.

⚠️ IMPORTANT CONTEXT:
- On Home Screen: top-right has Notification icon
- Next to it is Language button
- REMOVE Language button
- Replace it with User Profile entry (avatar or icon)
- When user taps → navigate to Profile Screen

---

# 📦 FEATURE: QUẢN LÝ CÁ NHÂN (PATIENT PROFILE UI)

---

# 🎨 UI/UX REQUIREMENTS (VERY IMPORTANT)

Design MUST be:
- Clean (like modern healthcare apps)
- Soft color (blue / white / light gradient)
- Friendly, not too technical
- Clear sections (grouped information)
- Easy for non-tech users

---

# 🧱 SCREEN STRUCTURE

## 🔹 1. HEADER (TOP AREA)

- Back button (left)
- Title: "Hồ sơ cá nhân"
- Optional: avatar (center or below header)

---

## 🔹 2. AVATAR SECTION

- Circle avatar (default icon if no image)
- Button:
  - "Đổi ảnh" (optional)

---

## 🔹 3. PERSONAL INFORMATION SECTION

Title: "Thông tin cá nhân"

Fields:
- Họ và tên (editable)
- Số điện thoại (readonly)
- Ngày sinh (date picker)
- Giới tính (dropdown)
- Địa chỉ (text)

UI:
- Rounded input fields
- Icon prefix (user, phone, calendar...)

---

## 🔹 4. MEDICAL INFORMATION SECTION

Title: "Thông tin y tế"

Fields:
- Nhóm máu (dropdown)
- Dị ứng (text)
- Tiền sử bệnh (multi-line text)

---

## 🔹 5. EMAIL SETTINGS SECTION

Title: "Cài đặt email"

Fields:
- Email (text input)

Toggles:
- Nhận hồ sơ khám bệnh qua email
- Lưu trữ hồ sơ online

⚠️ UX:
- If toggle ON → email required
- Show helper text

---

## 🔹 6. ACTION BUTTONS

- Primary button: "Lưu thông tin"
- Secondary button: "Hủy"

Design:
- Full width
- Rounded
- Clear hierarchy

---

# ✨ UX DETAILS (IMPORTANT)

- Show loading indicator when saving
- Show success snackbar: "Cập nhật thành công"
- Show error messages under fields
- Auto scroll to first error
- Keyboard handling (avoid overflow)

---

# 🎯 INTERACTION FLOW

1. User opens profile screen
2. Data is loaded (show loading shimmer)
3. User edits fields
4. Click "Lưu thông tin"
5. Validate
6. If valid → save → show success

---

# 🧠 SMART UX (BONUS)

- Auto-fill name & phone from auth
- Disable phone editing
- Save button disabled until changes made
- Smooth animation (fade / slide)

---

# 🎨 DESIGN STYLE

- Border radius: 12–16
- Spacing: 12–16 px
- Icons: Material Icons
- Colors:
  - Primary: Blue (#4A90E2)
  - Background: Light grey/white
- Card-based layout

---

# 🏗️ OUTPUT REQUIRED

AI must generate:

1. Full Flutter UI code:
   - patient_profile_screen.dart

2. Reusable widgets:
   - custom_text_field.dart
   - section_title.dart
   - toggle_switch.dart

3. Responsive layout
4. Clean, readable code

---

# 🚫 DO NOT

- Do not implement Firebase logic here (UI only)
- Do not modify unrelated screens
- Do not use ugly/basic UI
- Do not skip UX details


# Tìm kiếm & khám bệnh
- Tìm bác sĩ theo:
  - Chuyên khoa
  - Đánh giá
  - Vị trí
- Xem chi tiết:
  - Kinh nghiệm
  - Lịch làm việc

---
You are a Senior Flutter + Firebase Engineer. Implement Doctor Search & Detail Feature in Patient Module using Clean Architecture. User can search doctors by specialty, rating, and location; display list with name, avatar, specialty, rating, clinic; support filter combination and handle empty results. On tap doctor → open detail screen showing experience, description, rating, clinic info, and working schedule (days + time slots). Use Firebase Firestore collection "doctors" (fields: doctorId, name, avatarUrl, specialty, rating, experienceYears, description, clinicName, location, schedule). Implement real Firestore queries (filter + sort), not mock data. Ensure loading, error, and empty states. Do not break existing project, only add this feature with controller, UI screens (search + detail), and Firebase integration.


## Chọn bệnh viện
- Xem:
  - Tên
  - Đánh giá
  - Địa chỉ
- Gợi ý:
  - Gần nhất
  - Theo nhu cầu

---
You are a Senior Flutter + Firebase Engineer. Implement Hospital Selection Feature in Patient Module using Clean Architecture. User can view hospital list with name, rating, and address; support suggestions including nearest hospitals (based on user location) and recommendations based on user needs (e.g., specialty or service). Use Firebase Firestore collection "hospitals" (fields: hospitalId, name, rating, address, location (GeoPoint), specialties/services). Implement real data fetching (no mock), basic filtering/sorting (nearest, highest rating, matching needs), and handle loading, empty, and error states. Provide UI screen with list cards, simple filter/sort options, and selection interaction. Do not modify unrelated files, do not break existing flow, only add this feature with controller, UI, and Firestore integration.