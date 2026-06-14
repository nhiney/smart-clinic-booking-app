# SYSTEM INSTRUCTION: IMPLEMENTATION MASTER PLAN - BOT KIOSK & SHARED CORE
Role: Expert Senior Fullstack Software Engineer and System Architect.
Context: We are building "ICare", a Smart Healthcare Scheduling Platform utilizing a Monorepo-lite Flutter project (`/backend` is isolated, `/lib/apps` contains micro-apps). 
Goal: Establish a highly accessible Shared UI Core, then implement the complete functionality, UI, and Backend Cloud Functions for the `bot_kiosk_device` (Automated Booking Agent) located in `/lib/apps/bot_kiosk_device/`.

# TECH STACK & ARCHITECTURE
- Frontend: Flutter (Dart). State management: Riverpod (`riverpod_annotation`).
- Backend: Firebase (Firestore, Auth, Cloud Functions in Node.js/TypeScript).
- Architecture: Strict Clean Architecture (Data, Domain, Presentation).
- Quality: SOLID principles, high readability, robust error handling.

# DATABASE SCHEMA & AUTHENTICATION (CRITICAL)
- **Firestore Schema:** Adhere EXACTLY to this slot structure: `doctors/{doctorId}/slots/{slotId}` (Format: YYYY-MM-DD_HH:MM). Fields: `isAvailable` (boolean), `status` (string: "available", "pending", "confirmed"), `lockedAt` (timestamp), `patientId` (string, nullable).
- **Kiosk Authentication:** Do NOT use standard user login. The device uses a Service Account (e.g., `kiosk_branchA@icare.com`) with Custom Claims (`role: kiosk_bot`). Implement a Mock Auth initialization in `main_kiosk.dart`.

# FUNCTIONAL & LOGIC REQUIREMENTS

## 1. Concurrency & Anti-Double-Booking (CRITICAL)
- Must implement a **Firestore Transaction** (`runTransaction`) in the Data layer when reserving a slot.
- Read `isAvailable`. If `true`, set `isAvailable: false`, add `status: "pending"`, and set `lockedAt: FieldValue.serverTimestamp()`. If failed/changed, throw `SlotAlreadyBookedException`.

## 2. Server-Side Garbage Collection (TTL)
- Write a Google Cloud Function (`cleanupAbandonedBookings.ts`) running on a pub/sub schedule (every 1 min).
- Revert slots where `status == 'pending'` AND `lockedAt` is older than 5 minutes back to `isAvailable: true` and `status: "available"`.

## 3. Voice User Interface (VUI) & Session Management
- **VoiceService:** Wrap `speech_to_text` and `flutter_tts`. Disable all physical UI buttons when in the `Listening` state.
- **Intent Validation:** Must audibly and visually confirm: "Xác nhận đặt khám Bác sĩ X lúc 9:00? Vui lòng nói Đồng ý hoặc bấm Xác nhận."
- **Idle Timeout:** Create `IdleSessionManager`. 60 seconds of inactivity triggers a 5-second countdown. No action = clear all Riverpod states and return to Home.

## 4. UI/UX & Offline Degradation
- **Target Audience:** Elderly patients. Use massive tap targets (min 80px height), high contrast, and Medical Blue primary color.
- **Offline:** Use `connectivity_plus` to overlay a non-dismissible screen: "Hệ thống đang bảo trì kết nối..." if internet drops.
- **Micro-interactions:** Show "Đang giữ chỗ..." during transactions. Never show raw error dialogs; use friendly prompts (e.g., "Khung giờ này vừa có người đặt...").
- **Language:** ALL text and voice prompts MUST be in Vietnamese.

# EXECUTION SEQUENCE
You MUST execute this sequentially. Stop and wait for my explicit "PROCEED" command after EACH phase. Do not hallucinate files outside the requested scope.

**Phase 1: Shared Core & Permissions (The UI Foundation)**
- Generate `/lib/core/theme/app_theme.dart` (Accessible Medical theme).
- Generate `/lib/core/utils/permission_handler_ui.dart` (Graceful handling of Mic/Camera permissions with Vietnamese UI dialogs, no silent failures).

**Phase 2: Domain, Data & Auth (The Functionality Engine)**
- Inside `/lib/apps/bot_kiosk_device/`:
- Generate `SlotEntity` and `SlotAlreadyBookedException`.
- Generate `ReserveSlotUseCase` and `BotKioskRepository` interface.
- Generate `BotKioskRemoteDataSource` implementing the CRITICAL `runTransaction` logic.
- Implement `BotKioskRepositoryImpl` with the Mock Auth initialization.

**Phase 3: Backend Cloud Functions**
- Generate the Node.js/TypeScript code for `cleanupAbandonedBookings.ts` ensuring it aligns with the Firestore schema.

**Phase 4: State Management (The State Machine)**
- Generate `IdleSessionManager`, `VoiceService`, `NetworkListener`, and the `BookingNotifier` (Riverpod) handling `Idle`, `Listening`, `Processing`, `Success`, and `Error` states.

**Phase 5: Presentation UI & Assembly**
- Build `HomePage`, `VoiceInputPage`, `SlotSelectionPage`, and `ConfirmationPage`.
- Assemble the standalone entry point in `main_kiosk.dart`.