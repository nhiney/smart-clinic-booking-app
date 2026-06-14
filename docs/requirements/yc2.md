# SYSTEM INSTRUCTION: QR CHECK-IN KIOSK MODULE
Role: Expert Senior Flutter Developer and System Architect.
Project: "ICare" (Smart Healthcare Platform).
Goal: Build a completely new standalone module: `qr_checkin_device`. This is a dedicated Check-in Kiosk where patients scan their appointment QR codes upon arriving at the hospital. 

# ARCHITECTURE & INTEGRATION
- Tech Stack: Flutter, Firebase (Firestore, Auth), Riverpod (riverpod_annotation).
- Architecture: Clean Architecture (Domain, Data, Presentation).
- Location: The module MUST be isolated inside `/lib/apps/qr_checkin_device/` with its own entry point `main_qr_kiosk.dart`.

# DIRECTORY STRUCTURE (/lib/apps/qr_checkin_device/)
  /data
    /models
    /repositories 
    /datasources 
  /domain
    /entities (e.g., CheckInResultEntity)
    /repositories 
    /usecases (e.g., ProcessCheckInUseCase)
  /presentation
    /pages (ScannerPage, ResultOverlay)
    /widgets 
    /state (Riverpod Notifiers handling scanner lifecycle, debounce, and auto-reset)
  /core
    /errors (Custom Exceptions)
    /utils (AudioPlayer, NetworkListener)

# FUNCTIONAL & LOGIC REQUIREMENTS

## 1. QR Payload & Device Authentication
- The QR code payload will be a JSON string: `{"bookingId": "string"}`. 
- The Kiosk authenticates using its own Service Account (e.g., `kiosk_scanner_A@icare.com`). Do NOT use standard user login. Implement a mock auth in `main_qr_kiosk.dart`.

## 2. Business Logic & Constraints (ProcessCheckInUseCase)
Execute a strict Firestore Transaction (`runTransaction`) to prevent double-scan race conditions:
1. Fetch the booking using `bookingId`.
2. If booking doesn't exist -> throw `InvalidQRCodeException`.
3. If `status` is already "arrived" or "completed" -> throw `AlreadyCheckedInException`.
4. **Time Constraint:** If the current time is more than 60 minutes before the scheduled appointment time -> throw `TooEarlyException`.
5. If valid, update Firestore: set `status: "arrived"` and `checkInTime: FieldValue.serverTimestamp()`.

## 3. Scanner Hardware & UX (CRITICAL SAFEGUARDS)
- **Dependency:** Strictly use `mobile_scanner` package.
- **Throttling/Debounce (CRITICAL):** The scanner fires continuously. You MUST implement a lock state in the Riverpod notifier. The moment the *first* QR frame is detected, pause the `MobileScannerController` immediately to prevent multiple API calls.
- **App Lifecycle:** Implement `WidgetsBindingObserver`. You MUST pause the camera when the app goes to the background and resume/reinitialize it when returning to the foreground to prevent camera freezing.
- **Offline Handling:** Use `connectivity_plus`. Display a non-dismissible overlay "Hệ thống đang bảo trì kết nối..." if offline.
- **Micro-interactions:** - On Success: Play a "Beep" sound, overlay a massive GREEN screen: "Check-in Thành công / Số thứ tự: X".
  - On Error: Play an error sound, overlay a massive RED screen with specific messages ("Mã không hợp lệ", "Bạn đã check-in rồi", or "Chưa đến giờ check-in").
- **Auto-Reset:** Display the result overlay for exactly 3 seconds, then automatically dispose the overlay, clear the state, and `start()` the scanner again. No user interaction required.

# EXECUTION STEPS (STOP AND WAIT FOR APPROVAL AFTER EACH STEP)
1. **Step 1: Domain & Core:** Generate Entities, Exceptions (`InvalidQRCodeException`, `AlreadyCheckedInException`, `TooEarlyException`), and `ProcessCheckInUseCase`. 
2. **Step 2: Data Layer:** Implement Firestore Datasource using `runTransaction`. 
3. **Step 3: Presentation - State:** Setup Riverpod notifiers focusing on debounce logic, scanner lifecycle, and 3-second auto-reset.
4. **Step 4: Presentation - UI:** Build `ScannerPage` handling `WidgetsBindingObserver` for the camera, and the massive Result Overlays. ALL text MUST be in Vietnamese.
5. **Step 5: Main Entry Point:** Create `main_qr_kiosk.dart` to bootstrap this specific device.