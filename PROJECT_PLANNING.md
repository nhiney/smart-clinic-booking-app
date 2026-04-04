# Smart Healthcare Appointment Booking Application - Project Planning Document

## 1. Project Overview

**Description:**
A smart, accessible mobile healthcare application connecting patients with doctors for appointment scheduling, medical record management, and consultation. Uniquely designed for elderly and non-tech-savvy users, the system integrates a Voice-First AI assistant and a seamless QR check-in workflow for physical clinic visits.

**Goals:**
- Provide a zero-friction appointment booking experience.
- Reduce missed appointments via automated FCM reminders and Voice AI intervention.
- Streamline hospital waiting room traffic via an encrypted QR Code checking system.

**Scope:**
- **In-Scope**: Patient, Doctor, Admin, Scanner apps (bundled or role-routed), Voice Navigation, Maps, Authentication, Records Management.
- **Out-of-Scope (V1)**: Video telehealth consultations, in-app payment gateways.

---

## 2. System Architecture Overview

**Modules:**
Built using Clean Architecture (Presentation, Domain, Data layers) and Riverpod State Management. The system integrates 11 highly cohesive modules ranging from Authentication to AI Voice Processing.

**Data Flow (UI → Backend → DB):**
1. **User Action**: User taps the Microphone (Presentation).
2. **State/ViewModel**: Riverpod controller invokes `ProcessVoiceIntentUseCase` (Domain).
3. **Repository**: UseCase calls `AIAssistantRepository` implementation (Data).
4. **Backend/API**: Repository triggers Firebase Cloud Function for NLP processing.
5. **Database**: Cloud Function queries Cloud Firestore.
6. **Response**: Data resolves back through the layers, updating the UI state and triggering Text-to-Speech auditory feedback.

---

## 3. Full Feature Breakdown

### Module 1: Authentication Module
- **Description**: Handles phone-based OTP login and role assignment.
- **Feature List**: Login, OTP Verification, Role Parsing, Logout.

#### Feature: Phone Authentication
- **Description**: Secure login using Firebase Phone Auth.
- **Tasks**:
  - [ ] Initialize Firebase App in Flutter.
  - [ ] Implement `PhoneAuthRepository`.
  - [ ] Build Login UI Screen (Phone number text field).
  - [ ] Build OTP Verification UI Screen (Pin code input).
  - [ ] Handle Firebase `verifyPhoneNumber` logic and callbacks.
  - [ ] Map Auth UID to Firestore `users` collection.
- **Priority**: High
- **Complexity**: Medium
- **Dependencies**: Backend & Database Module setup.
- **Acceptance Criteria**:
  - User receives SMS OTP within 10 seconds.
  - Valid OTP logs user in and redirects to Role Router.
  - Invalid OTP shows a clear UI error.

### Module 2: User Profile Module
- **Description**: Management of personal demographic and account profile data.
- **Feature List**: Profile Creation, Avatar Upload, Update Details.

#### Feature: Setup Patient Profile
- **Description**: First-time setup for newly authenticated users.
- **Tasks**:
  - [ ] Create `UserModel` entity.
  - [ ] Build Profile Setup UI Form (Name, DOB, Address).
  - [ ] Write Firestore `set()` query for new user creation.
  - [ ] Ensure role is hardcoded to `patient` during self-registration.
- **Priority**: High
- **Complexity**: Easy
- **Dependencies**: Authentication Module.
- **Acceptance Criteria**:
  - Required fields cannot be bypassed.
  - Data correctly persists to the `users` Firestore collection.

### Module 3: Patient Module
- **Description**: Core interface for the end-user seeking care.
- **Feature List**: Home Dashboard, Medical History Viewer, Medication Tracker.

#### Feature: Home Dashboard (Accessible)
- **Description**: The primary entry point tailored for elderly accessibility.
- **Tasks**:
  - [ ] Design high-contrast UI with large fonts.
  - [ ] Implement upcoming appointment card widget.
  - [ ] Integrate the giant "Microphone" button (Voice AI entry point).
  - [ ] Build bottom navigation bar.
- **Priority**: High
- **Complexity**: Medium
- **Dependencies**: Authentication, System Architecture routing.
- **Acceptance Criteria**:
  - Fonts must scale with device accessibility settings.
  - UI successfully queries and displays the next active appointment.

### Module 4: Doctor Module
- **Description**: Interface for medical professionals to manage their schedule.
- **Feature List**: Schedule Dashboard, Update Appointment Status, Write Prescriptions.

#### Feature: Doctor Schedule Management
- **Description**: View and modify today's appointments.
- **Tasks**:
  - [ ] Create Doctor Home Screen UI (List view of daily appointments).
  - [ ] Write query to fetch `appointments` where `doctorId == currentUserId`.
  - [ ] Build "Update Status" dropdown/dialog (Pending → Confirmed → Completed).
  - [ ] Build Medical Record Entry form for completed appointments.
- **Priority**: High
- **Complexity**: Medium
- **Dependencies**: Authentication Module (Doctor Role).
- **Acceptance Criteria**:
  - Doctor only sees their own assigned appointments.
  - Status updates reflect immediately in Firestore.

### Module 5: Admin Module
- **Description**: Administrative oversight and global user management.
- **Feature List**: User Management, Global Analytics, Doctor Verification.

#### Feature: Admin User Dashboard
- **Description**: Basic overview of system health.
- **Tasks**:
  - [ ] Build Admin routing logic.
  - [ ] Create aggregated count queries (Total Patients, Total Bookings).
  - [ ] Build simple chart/list UI.
- **Priority**: Low
- **Complexity**: Easy
- **Dependencies**: Authentication Module (Admin Role).
- **Acceptance Criteria**:
  - Admin successfully routes to the admin-specific portal on login.
  - Data points accurately summarize Firestore collections.

### Module 6: AI Chatbot Module
- **Description**: The intelligence layer that processes textual NLP.
- **Feature List**: Intent parsing, Specialty Matching, Slot recommendation.

#### Feature: NLP Intent Processing
- **Description**: Extracting actionable data from user strings.
- **Tasks**:
  - [ ] Setup Firebase Cloud Function for AI processing.
  - [ ] Integrate Google Vertex AI / Dialogflow in the function.
  - [ ] Map natural language to JSON schema (intent, symptom, time).
  - [ ] Build Flutter Domain UseCase to send text and receive the structured JSON.
- **Priority**: Medium
- **Complexity**: Hard
- **Dependencies**: Backend Cloud Functions.
- **Acceptance Criteria**:
  - "I want to see a dentist tomorrow" correctly extracts `{intent: search, specialty: dentistry, date: tomorrow}`.

### Module 7: Voice AI Module
- **Description**: The accessibility hardware interaction layer.
- **Feature List**: Speech-to-Text translation, Text-to-Speech feedback.

#### Feature: End-to-End Voice Booking
- **Description**: Transcribe speech, process it, and talk back to the user.
- **Tasks**:
  - [ ] Add `speech_to_text` hardware permissions.
  - [ ] Build `VoiceBookingController` state notifier.
  - [ ] Connect STT output to the AI Chatbot Module.
  - [ ] Add `flutter_tts` for auditory output of the AI response.
  - [ ] Sync UI animations with listening/processing states.
- **Priority**: High
- **Complexity**: Hard
- **Dependencies**: AI Chatbot Module.
- **Acceptance Criteria**:
  - Microphone picks up audio correctly.
  - User receives synthesized voice feedback upon successful NLP parsing.

### Module 8: QR Check-in Module
- **Description**: Bridge between digital booking and physical hospital arrival.
- **Feature List**: Secure QR Generation, Scanner Role Interface, Validation API.

#### Feature: Secure Check-in Flow
- **Description**: Generating and scanning a cryptographically secure appointment token.
- **Tasks**:
  - [ ] Implement `generateBookingQR` Cloud Function (signs appt ID with secret).
  - [ ] Add `qr_flutter` to render the hash in the Patient app after booking.
  - [ ] Build a Camera Scanner UI using `mobile_scanner` for the Scanner Role.
  - [ ] Implement `verifyHospitalCheckIn` Cloud Function to decrypt and update status to `checked_in`.
- **Priority**: Medium
- **Complexity**: Medium
- **Dependencies**: Patient Module (Booking), Scanner Role Auth.
- **Acceptance Criteria**:
  - Scanning a valid QR flips the DB status to `checked_in`.
  - Scanning a fake/manipulated QR displays an "Invalid Ticket" error.

### Module 9: Notification Module
- **Description**: System to alert users of important events.
- **Feature List**: Booking Confirmations, Medication Reminders.

#### Feature: Local & Push Reminders
- **Description**: Reminding patients 2 hours before their visit.
- **Tasks**:
  - [ ] Setup Firebase Cloud Messaging (FCM) certificates.
  - [ ] Save device token to user's Firestore profile.
  - [ ] Write a scheduled Cloud Function (Cron job) to poll upcoming appointments.
  - [ ] Dispatch FCM payload to the targeted device token.
- **Priority**: Medium
- **Complexity**: Medium
- **Dependencies**: Backend & Database Module.
- **Acceptance Criteria**:
  - Scheduled notification physically triggers on the target device.

### Module 10: Maps Module
- **Description**: Geo-location context for finding nearby hospitals.
- **Feature List**: Google Maps Integration, Radius Search.

#### Feature: Nearby Clinic Locator
- **Description**: Finding doctors by proximity.
- **Tasks**:
  - [ ] Integrate `google_maps_flutter` package.
  - [ ] Plot Doctor `clinic_location` GeoPoints as map markers.
  - [ ] Implement user location permissions (`geolocator`).
  - [ ] Build bottom sheet card for marker taps.
- **Priority**: Low
- **Complexity**: Medium
- **Dependencies**: Doctor Module (Location data in DB).
- **Acceptance Criteria**:
  - Map accurately shows user's blue dot and nearby doctor pins.

### Module 11: Backend & Database Module
- **Description**: The core data structuring and serverless logic.
- **Feature List**: Security Rules, Indexes, Background triggers.

#### Feature: Database Security & Schemas
- **Description**: Securing the clinical data.
- **Tasks**:
  - [ ] Write `firestore.rules` to strictly enforce role-based access.
  - [ ] Build compound indexes for complex queries (e.g., `specialty` + `rating`).
  - [ ] Deploy indexing to Firebase via `firebase init`.
- **Priority**: High
- **Complexity**: Medium
- **Dependencies**: None.
- **Acceptance Criteria**:
  - A patient cannot read another patient's medical records.
  - CLI deployment of strict rules succeeds.

---

## 6. Sprint Planning

### Sprint 1: Core Foundation (Weeks 1-2)
- Architecture Scaffolding & CI/CD setup.
- Authentication Module (Phone OTP, Role Router).
- Backend & Database Module (Security schema formulation).
- User Profile Module (CRU operations).

### Sprint 2: Clinical Workflows (Weeks 3-4)
- Patient Module (Search Doctor, Slot selection, Booking).
- Doctor Module (Schedule view, Appointments management, Prescription).
- Admin Module (Basic overview UI).

### Sprint 3: Smart Additions (Weeks 5-6)
- AI Chatbot Module (NLP Cloud Function).
- Voice AI Module (STT/TTS UI binding).
- QR Check-in Module (Scanner UI and Verification backend).
- Notification & Maps Module.

---

## 7. Team Assignment Suggestion (For 4 Members)

| Member | Role | Responsibilities |
|--------|------|------------------|
| **Dev 1 (Lead/Backend)** | Cloud Engineer | Firestore Security Rules, Cloud Functions (QR generation, NLP parsing handler), FCM trigger logic. |
| **Dev 2 (Frontend Core)** | Mobile Dev | Setup Clean Architecture bindings, Riverpod State, Authentication UI, User Profile, Doctor Dashboard. |
| **Dev 3 (Hardware/AI)** | Mobile Dev | Voice AI Module (Speech-To-Text/TTS), AI Chatbot UI mapping, Google Maps integration. |
| **Dev 4 (QA & Workflows)** | Mobile Dev / QA | Patient Booking Flow, QR UI generation & Scanner Implementation, end-to-end bug testing, UI accessibility styling. |

---

## 8. Risk & Challenges

- **Technical Risks**:
  - *Cloud Function Cold Starts*: May cause the Voice Assistant to feel slow occasionally.
  - *Maps Billing*: Accidental infinite loops querying Google Maps can rack up API costs.
- **UX Risks**:
  - *Voice Transcription Inaccuracy*: Highly dependent on device microphones and elderly speaker clarity. Must have a fallback manual UI.
  - *Accessibility*: Texts might clip or break layouts when system font settings are cranked to maximum by visually impaired users.
- **Integration Risks**:
  - *QR Expiry Handling*: Requires strict synchronization between mobile offline timestamps and server time.

---

## 9. Bonus Features (Optional for V1)
- **Family Sharing Mode**: Allows a younger family member to bind and manage bookings for an elderly parent inside their own app.
- **Offline Mode**: Hive Database caching the patient's upcoming QR ticket so check-in works even if hospital basement connectivity is dead.
- **Telemedicine Hook**: Adding WebRTC buttons inside the appointment details if the booking type is marked as 'Virtual'.
