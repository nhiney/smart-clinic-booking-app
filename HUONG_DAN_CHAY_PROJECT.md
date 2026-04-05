# 🩺 Hướng dẫn Chạy Dự án ICare (Smart Clinic Booking)

Ứng dụng **ICare** được phát triển bằng framework **Flutter** (Frontend) kết hợp với **Firebase** (Backend). Tài liệu này cung cấp hướng dẫn chi tiết nhất để bạn có thể cài đặt và chạy dự án thành công trên cả **Windows (Android)** và **macOS (iOS)**.

---

## 📋 1. Yêu cầu Hệ thống (Prerequisites)

Trước khi bắt đầu, hãy đảm bảo máy tính của bạn đã cài đặt các công cụ sau:

| Công cụ | Mô tả | Link cài đặt |
| :--- | :--- | :--- |
| **Flutter SDK** | Phiên bản ≥ 3.3.0 | [Cài đặt](https://docs.flutter.dev/get-started/install) |
| **Dart SDK** | Đi kèm với Flutter | - |
| **JDK (Java)** | Để build ứng dụng Android | [Tải JDK](https://www.oracle.com/java/technologies/downloads/) |
| **Node.js & npm** | Để chạy Firebase Functions (nếu cần) | [Tải Node.js](https://nodejs.org/) |
| **Firebase CLI** | Công cụ quản lý Firebase | `npm install -g firebase-tools` |
| **CocoaPods** | Chỉ dành cho máy Mac (để build iOS) | `sudo gem install cocoapods` |

---

## 🚀 2. Các Bước Cài đặt Dự án

### 🔹 Bước 1: Clone dự án và Cài đặt Thư viện
Mở Terminal (macOS) hoặc Command Prompt/PowerShell (Windows) và chạy các lệnh sau:

```bash
# 1. Tải mã nguồn về máy
git clone https://github.com/your-username/smart_clinic_booking.git
cd smart_clinic_booking

# 2. Cài đặt các gói thư viện Flutter
flutter pub get
```

### 🔹 Bước 2: Đăng ký Tài nguyên (Assets)
Đảm bảo bạn đã khai báo thư mục chứa Font và Icon trong tệp `pubspec.yaml` để ứng dụng có thể nhận diện:

```yaml
flutter:
  assets:
    - assets/icons/
    - assets/fonts/
    - assets/images/
```

### 🔹 Bước 3: Sinh mã tự động (Build Runner) - ⚠️ QUAN TRỌNG
Dự án sử dụng **Injectable** và **Json Serializable**. Đây là bước **BẮT BUỘC** để khởi tạo hệ thống Dependency Injection. Nếu thiếu bước này, ứng dụng sẽ báo lỗi không tìm thấy các file `.config.dart`.

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 💻 3. Hướng dẫn theo từng Hệ điều hành

### 🍎 Dành cho macOS & iOS
Nếu bạn muốn chạy trên Trình giả lập (Simulator) hoặc iPhone thật:

1.  **Cài đặt Pods (Chỉ dành cho iOS):**
    ```bash
    cd ios
    pod install
    cd ..
    ```
2.  **Mở Simulator:** Mở ứng dụng **Simulator** từ Xcode.
3.  **Kiểm tra thiết bị:** `flutter devices`
4.  **Chạy app:** `flutter run`

### 🪟 Dành cho Windows & Android
Nếu bạn muốn chạy trên Trình giả lập Android (Emulator) hoặc điện thoại Android thật:

1.  **Bật Virtualization:** Đảm bảo BIOS đã bật ảo hóa (VT-x/AMD-V).
2.  **Mở Android Emulator:** Mở từ Android Studio (Device Manager).
3.  **Kiểm tra thiết bị:** `flutter devices`
4.  **Chạy app:** `flutter run`

---

## 🛠️ 4. Cấu hình Firebase (Nếu chuyển dự án mới)

Dự án hiện đã có sẵn các file cấu hình mẫu. Nếu bạn muốn sử dụng tài khoản Firebase riêng:
*   **Android:** Copy tệp `google-services.json` vào thư mục `android/app/`.
*   **iOS:** Copy tệp `GoogleService-Info.plist` vào thư mục `ios/Runner/`.
*   **CLI:** Chạy lệnh `flutterfire configure` để tự động hóa quá trình này.

---

## ❓ 5. Xử lý Lỗi thường gặp (Troubleshooting)

| Vấn đề | Giải pháp |
| :--- | :--- |
| **Lỗi `injection.config.dart`** | Chạy lại lệnh ở **Bước 3** (`build_runner`). |
| **Lỗi Pod Install (Mac)** | Chạy `pod repo update` rồi thử lại. |
| **Lỗi Gradle (Android)** | Chạy `flutter clean` sau đó chạy lại `flutter run`. |
| **Không nhận diện Font/Icon** | Kiểm tra đường dẫn trong `pubspec.yaml` có đúng tab (indent) hay chưa. |

---
**💡 Mẹo:** Luôn chạy `flutter clean` và `flutter pub get` nếu bạn gặp các lỗi lạ liên quan đến thư viện hoặc cache!

**Chúc bạn phát triển dự án ICare thành công!** 🏥✨
