# ICare — Smart Medical Booking App

A mobile healthcare application built with **Flutter** and **Firebase** that streamlines  
medical appointment booking, patient record management, and clinic discovery.

Designed with accessibility in mind — including voice-assisted booking for elderly and non-tech-savvy users.

> **Note**: This is a student project built for learning purposes.  
> It demonstrates real-world mobile architecture patterns, Firebase integration, and end-to-end feature development.

---

## Table of Contents

- [Features](#features)
- [AI & Voice Interaction](#ai--voice-interaction)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Database Design](#database-design-firestore)
- [Key Workflows](#key-workflows)
- [Challenges & Solutions](#challenges--solutions)
- [Testing](#testing)
- [Getting Started](#getting-started)
- [Future Improvements](#future-improvements)

---

## Features

| Category | Details |
|---|---|
| **Appointment Booking** | Search doctors → select time slot → confirm booking with conflict detection |
| **Doctor Discovery** | Browse doctors by specialty, view ratings, experience, and availability |
| **QR Check-in System** | Auto check-in at hospital via secure, encrypted QR Scanner |
| **Medical Records** | View diagnosis history, prescriptions, and doctor notes |
| **Medication Tracker** | Track active medications with dosage, frequency, and schedule |
| **Notifications** | In-app notifications for booking confirmations, reminders, and updates |
| **AI & Voice Chatbot** | Voice-first natural interaction (Speech-To-Text / Text-To-Speech) parsing intent & entities |
| **Authentication** | Phone-based OTP verification with 5 core roles (Patient, Doctor, Admin, Scanner, Chatbot) |
| **User Profiles** | Manage personal info, avatar, and account settings |

---

## AI & Voice Interaction

The system features an advanced, yet simple, AI Voice Chatbot interaction layer designed specifically for the elderly:

- **Input**: Voice (Speech-to-Text) translating to text strings.
- **Processing**: Intent Detection (book/cancel/search) & Entity Extraction (Specialty, Date, Time, Location).
- **Output**: Automatic system UI suggestions combined with Text-to-Speech (TTS) auditory feedback.
- Designed to handle unclear input gracefully (asking again simply, rather than forcing manual typing).

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter (Dart) |
| **State Management** | Provider + Flutter BLoC |
| **Dependency Injection** | GetIt + Injectable (code generation) |
| **Backend / Database** | Firebase (Cloud Firestore, Authentication) |
| **Maps** | flutter_map (OpenStreetMap) + latlong2 |
| **Networking** | Dio |
| **Local Storage** | Hive + SharedPreferences |
| **Routing** | GoRouter |
| **UI Components** | table_calendar, Shimmer, Lottie animations, cached_network_image |
| **Form Handling** | Formz |
| **Code Generation** | build_runner, json_serializable, injectable_generator |

---

## System Architecture

The project follows **Clean Architecture** principles, separating each feature into three distinct layers:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│         (Screens, Controllers, Widgets)              │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│          (Entities, Use Cases, Repository            │
│                   Interfaces)                        │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│      (Models, Remote Datasources, Repository         │
│                 Implementations)                     │
└──────────────────────┬──────────────────────────────┘
                       │
              ┌────────▼────────┐
              │    Firebase      │
              │  (Firestore +    │
              │  Authentication) │
              └─────────────────┘
```

### Data Flow

```
User Action → Screen → Controller (Provider) → Use Case → Repository (interface)
                                                               │
                                                    Repository Implementation
                                                               │
                                                     Remote Datasource
                                                               │
                                                        Cloud Firestore
```

### Dependency Injection

Dependencies are wired using **GetIt** with **Injectable** for code generation. Datasources, repositories, and use cases are registered at app startup via `configureDependencies()`, while controllers are provided through Flutter's `MultiProvider` tree.

---

## Project Structure

```
lib/
├── main.dart                         # App entry point, DI setup, provider tree
├── firebase_options.dart             # Auto-generated Firebase config
│
├── config/
│   └── dependency_injection/         # GetIt + Injectable setup
│
├── core/
│   ├── constants/                    # App-wide constants
│   ├── error/                        # Error handling utilities
│   ├── network/                      # Network configuration (Dio)
│   ├── services/                     # Shared services
│   ├── theme/                        # App theme (AppTheme.light)
│   ├── utils/                        # Utility functions (date formatting, etc.)
│   └── widgets/                      # Reusable UI components
│
├── features/
│   ├── appointment/                  # Booking system
│   │   ├── data/                     #   ├── datasources/  models/  repositories/
│   │   ├── domain/                   #   ├── entities/  usecases/  repositories/
│   │   └── presentation/            #   └── screens/  controllers/  widgets/
│   │
│   ├── auth/                         # Authentication & user management
│   ├── doctor/                       # Doctor profiles & search
│   ├── maps/                         # Clinic map & location features
│   ├── medical_record/               # Patient medical history
│   ├── medication/                   # Medication tracking
│   ├── notification/                 # In-app notifications
│   └── profile/                      # User profile management
│
├── routes/                           # GoRouter route definitions
└── shared/                           # Cross-feature shared code
```

Each feature module is **self-contained** — it owns its data layer, domain logic, and presentation, making the codebase modular and easy to navigate.

---

## Database Design (Firestore)

### Collections Overview

```
Firestore
├── users/                  # All registered users
├── doctors/                # Doctor profiles & availability
├── appointments/           # Booking records
├── medical_records/        # Diagnosis & prescription history
├── medications/            # Patient medication schedules
└── notifications/          # In-app notification entries
```

### Document Schemas

#### `users/{userId}`
| Field | Type | Description |
|---|---|---|
| `id` | string | Firebase Auth UID |
| `name` | string | Display name |
| `email` | string | Email address |
| `phone` | string | Phone number (used for OTP login) |
| `role` | string | `patient` \| `doctor` \| `admin` \| `scanner` \| `chatbot` |
| `avatarUrl` | string | Profile image URL |
| `createdAt` | timestamp | Account creation date |

#### `doctors/{doctorId}`
| Field | Type | Description |
|---|---|---|
| `name` | string | Doctor's name |
| `specialty` | string | e.g., "Cardiology", "Dentistry" |
| `hospital` | string | Affiliated hospital or clinic |
| `rating` | number | Average rating (0.0 – 5.0) |
| `experience` | number | Years of experience |
| `latitude` / `longitude` | number | Clinic location coordinates |
| `availableDays` | array\<string\> | e.g., `["Monday", "Wednesday", "Friday"]` |
| `availableTimeSlots` | array\<string\> | e.g., `["09:00", "10:00", "14:00"]` |

#### `appointments/{appointmentId}`
| Field | Type | Description |
|---|---|---|
| `patientId` | string | Reference to `users` collection |
| `doctorId` | string | Reference to `doctors` collection |
| `patientName` / `doctorName` | string | Denormalized names for quick display |
| `specialty` | string | Doctor's specialty |
| `dateTime` | timestamp | Appointment date and time |
| `status` | string | `pending` \| `confirmed` \| `cancelled` \| `completed` |
| `notes` | string | Patient's notes or symptoms |
| `secureQrHash` | string | Used for encrypted hospital check-in validations |
| `createdAt` | timestamp | Booking creation time |

#### `medical_records/{recordId}`
| Field | Type | Description |
|---|---|---|
| `patientId` | string | Reference to patient |
| `doctorId` | string | Reference to treating doctor |
| `diagnosis` | string | Diagnosis details |
| `prescription` | string | Prescribed medications |
| `notes` | string | Additional clinical notes |
| `date` | timestamp | Record date |

#### `medications/{medicationId}`
| Field | Type | Description |
|---|---|---|
| `patientId` | string | Reference to patient |
| `name` | string | Medication name |
| `dosage` | string | e.g., "500mg" |
| `frequency` | string | e.g., "Daily" |
| `time` | string | Scheduled time (e.g., "08:00") |
| `startDate` / `endDate` | timestamp | Duration of medication |
| `isActive` | boolean | Whether currently active |

### Security Rules

Firestore rules enforce **document-level access control**:

- **Users**: Can only read/update their own profile
- **Doctors**: Readable by any authenticated user
- **Appointments**: Only accessible by the involved patient or doctor
- **Medical Records**: Only the patient or the treating doctor can read
- **Medications**: Only the owning patient can read/write

```javascript
// Example: Appointment access control
match /appointments/{appointmentId} {
  allow read: if request.auth != null &&
    (resource.data.patientId == request.auth.uid ||
     resource.data.doctorId == request.auth.uid);
}
```

---

## Key Workflows

### Appointment Booking Flow

```
┌──────────┐     ┌──────────────┐     ┌─────────────┐     ┌──────────────┐
│  Browse   │────▶│ Select Doctor │────▶│ Pick Date & │────▶│   Confirm    │
│  Doctors  │     │  & Specialty  │     │  Time Slot   │     │ Booking & QR │
└──────────┘     └──────────────┘     └─────────────┘     └──────┬───────┘
                                                                  │
                                         ┌────────────────────────▼──────┐
                                         │  Write to Firestore           │
                                         │  appointments collection      │
                                         │  Status: "pending"            │
                                         └───────────────────────────────┘
```

1. Patient searches doctors visually OR via the **Voice AI Assistant**.
2. Selects a doctor and views availability.
3. Picks a slot or lets the Voice AI pick the best matched slot automatically.
4. Confirms booking — receives a **Secure QR Code** incorporating patient ID, appt ID, and timestamp. Data saves to `appointments` collection.

### QR Check-in Flow

1. **Arrival**: Patient arrives at the hospital.
2. **Scan Phase**: Staff/Admin uses the `Scanner` Role on the app to scan the patient's QR.
3. **Verification**: Backend reads `appointment_id`, `patient_id` and validates the signature via Cloud Functions.
4. **Completion**: If valid, the system updates the appointment status to `checked_in` and plays auditory confirmation to the patient.

### Schedule Conflict Prevention

- Each doctor has a defined list of `availableDays` and `availableTimeSlots`
- The UI only allows booking within these predefined slots
- Before creating an appointment, the system queries existing bookings for the same `doctorId + dateTime` to prevent double-booking
- Appointment status transitions (`pending → confirmed → completed`) are enforced through the controller logic

### Authentication Flow

```
Phone Input → OTP Verification → Profile Setup → Home Screen
                  │
        Firebase Phone Auth
        (verifyPhoneNumber)
```

1. User enters phone number
2. Firebase sends OTP via SMS
3. User enters the code; Firebase verifies it
4. If new user → create profile in `users` collection with `role: "patient"`
5. If existing user → load profile and navigate to home

---

## Challenges & Solutions

### 1. Data Consistency in Concurrent Bookings
**Problem**: Two patients could theoretically book the same time slot simultaneously.  
**Solution**: The booking flow queries existing appointments for the target `doctorId + dateTime` before writing. Firestore's strong consistency on document reads ensures the query returns the latest state. For this project scope, this query-then-write approach is sufficient. A production system would use Firestore transactions for atomic check-and-write.

### 2. Denormalized Data vs. Firestore Joins
**Problem**: Firestore doesn't support joins. Displaying an appointment requires patient name, doctor name, and specialty.  
**Solution**: We denormalize by storing `patientName`, `doctorName`, and `specialty` directly in the appointment document. This trades slight data redundancy for significantly faster reads — a common Firestore pattern.

### 3. Role-Based Access Across the App
**Problem**: Different users (patient, doctor, admin) need different views and permissions.  
**Solution**: The `role` field in the `users` collection drives both UI rendering (different home screens / menu items) and Firestore security rules (document-level read/write restrictions).

### 4. Offline-Friendly Architecture
**Problem**: Mobile users may have inconsistent network connectivity.  
**Solution**: Firestore's built-in offline persistence caches data locally. Combined with Hive for app-specific local storage, the app can display cached data when offline and sync automatically when connectivity is restored.

### 5. Clean Architecture Overhead
**Problem**: Clean Architecture introduces many files and layers for each feature.  
**Solution**: We use **Injectable** for code generation to reduce boilerplate in the DI setup, and maintain a strict folder convention (`data/domain/presentation`) so new features follow a predictable pattern.

---

## Testing

The test suite is organized into three levels:

```
test/
├── unit/              # Business logic, use cases, entities
├── widget/            # Individual widget rendering and interaction
└── integration/       # End-to-end user flows
```

### Testing Strategy

| Level | What We Test | Tools |
|---|---|---|
| **Unit** | Entity creation, use case logic, data transformations, repository contracts | `flutter_test` |
| **Widget** | Screen rendering, user interactions, controller state changes | `flutter_test`, `Provider` mocking |
| **Integration** | Full booking flow, auth flow, navigation between screens | `flutter_test`, `integration_test` |

### Key Test Scenarios

- Appointment creation with valid data
- Appointment cancellation and status transitions
- Schedule conflict detection (double-booking prevention)
- Auth flow: phone verification → profile creation → login
- Doctor search and filtering by specialty
- Medical record creation and retrieval by patient
- Medication CRUD operations
- Firestore security rule validation (unauthorized access blocked)
- Edge cases: empty inputs, network errors, invalid time slots

### Running Tests

```bash
# Unit & Widget tests
flutter test

# Integration tests (requires emulator or device)
flutter test integration_test/
```

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.3.0
- Dart SDK ≥ 3.3.0
- Firebase project with Firestore and Authentication enabled
- A physical device or emulator (iOS / Android)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/smart_clinic_booking.git
cd smart_clinic_booking

# 2. Install dependencies
flutter pub get

# 3. Generate code (Injectable, JSON serialization, Hive adapters)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Set up Firebase
#    - Create a Firebase project at https://console.firebase.google.com
#    - Enable Firestore and Phone Authentication
#    - Download google-services.json (Android) and GoogleService-Info.plist (iOS)
#    - Place them in the appropriate directories
#    - Run: flutterfire configure

# 5. Deploy Firestore security rules
firebase deploy --only firestore:rules

# 6. Run the app
flutter run
```

---

## Future Improvements

- [ ] **Firestore Transactions** — Replace query-then-write with atomic transactions for fully race-condition-free booking
- [ ] **Push Notifications** — Integrate Firebase Cloud Messaging for real-time booking reminders
- [ ] **Video Consultation** — Add a video call feature using WebRTC or Agora SDK
- [ ] **Payment Integration** — Support online payment for consultations via VNPay or Momo
- [ ] **Advanced Voice Assistant** — Upgrade from basic speech-to-text to intent recognition with Dialogflow
- [ ] **Doctor Dashboard** — A dedicated interface for doctors to manage their schedules and patient lists
- [ ] **Admin Panel** — Web-based admin dashboard for user management and analytics
- [ ] **Localization** — Full Vietnamese and English language support with `flutter_localizations`
- [ ] **CI/CD Pipeline** — Automated testing and deployment with GitHub Actions

---

## License

This project is developed for educational purposes as part of a Mobile Application Development course.

---

<p align="center">
  Built with Flutter & Firebase
</p>
