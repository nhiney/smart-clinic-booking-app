---
description: "Task list for ICare Smart Clinic Booking System - Production-Level Implementation"
---

# Tasks: ICare Smart Clinic Booking System

**Input**: Enhanced feature specification from `/specs/001-clinic-booking-system/spec.md`, Implementation plan from `/specs/001-clinic-booking-system/plan.md`
**Prerequisites**: spec.md (required, production-level), plan.md (required), constitution.md (governance), enhanced with hospital workflow, queue system, lifecycle states, audit compliance, reliability, accessibility

**ENHANCEMENTS**:

- Hospital workflow with queue numbers, priority queues, auto-calling, kiosk displays (User Story 10)
- 8-state appointment lifecycle (Pending-Booking → Booked → Confirmed → Checked-in → In-Queue → In-Consultation → Post-Consultation → Completed/Cancelled/No-Show)
- Advanced queue management (FR-025 to FR-031)
- No-show handling with auto-detection and recovery (FR-036 to FR-040)
- Doctor workload tracking and balancing (FR-041 to FR-045)
- Immutable audit logs with patient-visible trails (FR-046 to FR-050)
- Idempotency and reliability validation (FR-051 to FR-056)
- Disaster recovery (RTO ≤4hrs, RPO ≤1hr) with standby infrastructure
- 45 measurable success criteria (SC-001 to SC-045) organized by category
- Accessibility enhancements (large fonts 18pt+, WCAG 2.1 AA, voice-first, icon-first UI)
- Cost optimization strategies (caching, polling optimization, batch notifications)

**Tests**: Tests are REQUIRED for this healthcare system (Constitution Principle III: Comprehensive Testing). Unit, integration, and E2E tests must be written first (TDD: RED → GREEN → REFACTOR).

**Organization**: Tasks are grouped by user story (P1/P2/P3) to enable independent implementation and testing of each story as a vertical slice.

## Format: `[ID] [P?] [US#] Description with file paths`

- **[ID]**: Sequential task ID (T001, T002, ...)
- **[P]**: Parallelizable (different files, no blocking dependencies)
- **[US#]**: User story label (US1, US2, ... US9) - required for user story phase tasks
- **File paths**: Exact locations for artifacts

## Path Conventions

- Mobile app: `mobile/lib/` (Dart/Flutter)
- Backend: `backend/functions/src/` (Node.js Cloud Functions)
- Web admin: `web/src/`
- Tests: `mobile/test/unit/`, `mobile/test/integration/`, `backend/test/`
- Configs: `firebase.json`, `firestore.rules`, `mobile/pubspec.yaml`

---

## Phase 1: Setup & Project Initialization

**Purpose**: Initialize project structure, dependencies, and shared infrastructure

- [ ] T001 Create Flutter mobile project structure: `mobile/lib/core/`, `mobile/lib/data/`, `mobile/lib/domain/`, `mobile/lib/presentation/`, `mobile/test/`
- [ ] T002 [P] Initialize Firebase project: `firebase.json`, Firestore collections schema, Cloud Functions deployment templates
- [ ] T003 [P] Create React web admin project structure: `web/src/components/`, `web/src/pages/`, `web/src/services/`
- [ ] T004 [P] Configure Flutter pubspec.yaml with dependencies (Dio, Provider, Hive, mockito, firebase_core, firebase_auth, cloud_firestore)
- [ ] T005 [P] Configure Firebase Cloud Functions: `backend/functions/package.json`, runtime environment, admin SDK setup
- [ ] T006 [P] Set up Node.js project for backend scripts: `backend/package.json` with firebase-admin, express, cloud-tasks
- [ ] T007 Configure linting and formatting: `mobile/.dart-format` / `mobile/analysis_options.yaml`, `web/.eslintrc`, `backend/.eslintrc`
- [ ] T008 [P] Setup Git ignore files and folder structure validation
- [ ] T009 [P] Configure CI/CD pipeline stubs (GitHub Actions or Firebase Deploy)

---

## Phase 2: Foundational Infrastructure (BLOCKING - All Stories Depend On This)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented. No user story work begins until Phase 2 is complete.

⚠️ **CRITICAL**: This phase is a gate. All components below must pass tests before proceeding to User Stories.

### Authentication & Authorization Framework

- [ ] T010 [P] Create authentication domain entities: `mobile/lib/domain/entities/user.dart`, `mobile/lib/domain/entities/auth_credentials.dart` with user roles (Patient, Doctor, Admin)
- [ ] T011 [P] Implement phone-based SMS OTP authentication service: `mobile/lib/domain/usecases/phone_auth_usecase.dart` (supports elderly users per Constitution Principle VII)
- [ ] T012 Create Firebase Auth integration: `mobile/lib/data/datasources/firebase_auth_datasource.dart` with custom claims for RBAC
- [ ] T013 Implement authentication repository: `mobile/lib/data/repositories/auth_repository.dart` with login/signup/logout flows
- [ ] T014 [P] Create RBAC enforcement: `backend/functions/src/utils/rbac.js` enforcing Patient/Doctor/Admin permissions in Firestore rules
- [ ] T015 Write Firestore security rules: `firestore.rules` with role-based access control (Constitution Principle IV: Healthcare Data Security)
- [ ] T016 Write unit tests for auth: `mobile/test/unit/repositories/auth_repository_test.dart`, `mobile/test/unit/usecases/phone_auth_usecase_test.dart' (min 80% coverage)
- [ ] T017 Write integration tests for auth: `mobile/test/integration/auth_flow_test.dart` using Firebase Emulator

### Data Encryption & Audit Logging (Constitutional Requirement)

- [ ] T018 [P] Create encryption utilities: `mobile/lib/core/utils/encryption_utils.dart` (AES-256 for sensitive data)
- [ ] T019 [P] Implement audit logging infrastructure: `backend/functions/src/utils/audit_logger.js` (who, what, when, immutable)
- [ ] T020 Create encrypted field wrappers: `mobile/lib/data/models/encrypted_field.dart` for medical records (Constitution Principle IV)
- [ ] T021 Implement audit log repository: `mobile/lib/data/repositories/audit_log_repository.dart` queryable by patient
- [ ] T022 Write unit tests for encryption: `mobile/test/unit/utils/encryption_utils_test.dart`

### Offline-First Cache & Sync (Constitutional Requirement)

- [ ] T023 [P] Set up Hive local database: `mobile/lib/data/datasources/hive_local_datasource.dart` for offline-first caching (Constitution Principle X)
- [ ] T024 [P] Create sync state machine: `mobile/lib/domain/usecases/sync_usecase.dart` (pending/syncing/synced/conflict states)
- [ ] T025 Create conflict resolution logic: `mobile/lib/data/repositories/sync_repository.dart` (last-write-wins or user-choice patterns)
- [ ] T026 Implement automatic sync on connectivity: `mobile/lib/presentation/cubit/offline_sync_cubit.dart` triggering on network return
- [ ] T027 Write unit tests for sync: `mobile/test/unit/usecases/sync_usecase_test.dart`, `mobile/test/unit/repositories/sync_repository_test.dart`
- [ ] T028 Write integration tests for offline/online transitions: `mobile/test/integration/offline_sync_test.dart`

### Idempotency & Transactional Safety (Constitutional Requirement)

- [ ] T029 [P] Create idempotency key generator: `mobile/lib/core/utils/idempotency_utils.dart` using request ID + hash
- [ ] T030 [P] Implement idempotent API client: `mobile/lib/data/datasources/firebase_remote.dart` with retry + deduplication
- [ ] T031 Create Firestore transaction wrapper: `backend/functions/src/utils/transaction_utils.js` for atomic booking + payment
- [ ] T032 Design and implement booking/payment transaction: `backend/functions/src/handlers/booking.js` with idempotency checks
- [ ] T033 Write unit tests for idempotency: `mobile/test/unit/utils/idempotency_utils_test.dart`
- [ ] T034 Write integration tests for transactions: `mobile/test/integration/payment_test.dart` (double-charging prevention)

### Event-Driven Architecture & Pub/Sub (Constitutional Requirement)

- [ ] T035 [P] Define domain events: `backend/functions/src/models/events.js` (BookingCreated, PaymentProcessed, CheckedIn, ConsultationCompleted)
- [ ] T036 [P] Create event publisher: `backend/functions/src/utils/event_publisher.js` emitting to Cloud Pub/Sub
- [ ] T037 Create event subscriber base: `backend/functions/src/handlers/event_subscribers.js` for idempotent event handling
- [ ] T038 Write unit tests for events: `backend/test/event_publisher.test.js`

### Observability & Structured Logging (Constitutional Requirement)

- [ ] T039 [P] Set up structured logging: `mobile/lib/core/utils/logger.dart` (JSON format with requestID, userID, operation)
- [ ] T040 [P] Configure Firebase Crashlytics integration: `mobile/lib/core/utils/crashlytics_integration.dart`
- [ ] T041 Create Cloud Logging setup: `backend/functions/src/utils/cloud_logger.js` for structured backend logs
- [ ] T042 Set up monitoring dashboards stub: `backend/firebase-monitoring-config.json` for bookings/min, payment success rate, queue depth
- [ ] T043 Create alerting rules: `backend/firebase-alerting-config.json` (alert on >1% failure rate, payment timeouts)

### Error Handling & Retry Logic

- [ ] T044 [P] Create retry utility with exponential backoff: `mobile/lib/core/utils/retry_utils.dart` (max 3 retries, configurable)
- [ ] T045 [P] Implement circuit breaker: `mobile/lib/data/datasources/circuit_breaker.dart` for external API failures
- [ ] T046 Create graceful degradation patterns: `mobile/lib/presentation/widgets/error_recovery_widget.dart` (show cached data if API fails)
- [ ] T047 Write unit tests for retries: `mobile/test/unit/utils/retry_utils_test.dart`

### Design System & Accessibility Foundation (Constitutional Requirement)

- [ ] T048 [P] Create accessible Flutter widgets: `mobile/lib/presentation/widgets/accessible_widgets.dart` (18pt+ fonts, WCAG AA contrast, semantic labels)
- [ ] T049 [P] Set up design system theme: `mobile/lib/core/theme/app_theme.dart` (consistent colors, typography, spacing)
- [ ] T050 [P] Implement large-font mode: `mobile/lib/presentation/cubit/accessibility_cubit.dart` (Constitutional Principle VII)
- [ ] T051 Implement high-contrast mode: `mobile/lib/presentation/cubit/accessibility_cubit.dart` (WCAG AA compliance)
- [ ] T052 Write unit tests for accessible widgets: `mobile/test/unit/widgets/accessible_widgets_test.dart`

### Appointment Lifecycle State Machine (Production Enhancement)

- [ ] T053 [P] Create appointment state machine: `mobile/lib/domain/entities/appointment_state.dart` with 8 states (Pending-Booking → Booked → Confirmed → Checked-in → In-Queue → In-Consultation → Post-Consultation → Completed/Cancelled/No-Show)
- [ ] T054 [P] Implement state transition validator: `mobile/lib/domain/usecases/appointment_state_usecase.dart` (enforce valid transitions, prevent backwards moves)
- [ ] T055 Implement post-consultation sub-stage tracking: `mobile/lib/domain/entities/appointment_lifecycle.dart` (Test/Imaging → Results → Payment → Prescription)
- [ ] T056 Create appointment state audit: `mobile/lib/data/repositories/appointment_audit_repository.dart` (track timestamp + reason for every state change)
- [ ] T057 Write state machine tests: `mobile/test/unit/entities/appointment_state_test.dart` (all valid transitions, reject invalid transitions)

### Queue Number Generation & Management (Production Enhancement)

- [ ] T058 [P] Create queue number generator: `mobile/lib/core/utils/queue_number_generator.dart` (department-code + sequential, e.g., "K-045")
- [ ] T059 [P] Implement queue number entity: `mobile/lib/domain/entities/queue_number.dart` (number, assigned-time, clinic-ID, department-ID)
- [ ] T060 Create queue number repository: `mobile/lib/data/repositories/queue_number_repository.dart` (track assignments, prevent duplicates)
- [ ] T061 Write queue number tests: `mobile/test/unit/utils/queue_number_generator_test.dart` (uniqueness, format, sequential increment)

### Doctor Workload State Management (Production Enhancement)

- [ ] T062 [P] Create doctor workload entity: `mobile/lib/domain/entities/doctor_workload.dart` (max-capacity, scheduled-count, checked-in-count, completed-count, in-consultation-count)
- [ ] T063 [P] Implement workload calculator: `mobile/lib/domain/usecases/doctor_workload_usecase.dart` (utilization %, capacity alerts)
- [ ] T064 Create workload repository: `mobile/lib/data/repositories/doctor_workload_repository.dart` (real-time tracking per doctor)
- [ ] T065 Write workload tests: `mobile/test/unit/usecases/doctor_workload_usecase_test.dart`

### Enhanced Audit Logging with Patient Visibility (Production Compliance)

- [ ] T066 [P] Create immutable audit log implementation: `backend/functions/src/utils/immutable_audit_log.js` (append-only, checksum verification, tamper detection)
- [ ] T067 [P] Implement patient-visible audit trail: `mobile/lib/presentation/screens/medical_records/audit_log_viewer.dart` (patient can view who accessed their records)
- [ ] T068 Create audit log query interface: `mobile/lib/data/repositories/audit_log_query_repository.dart` (filter by action, entity, date, user)
- [ ] T069 Implement audit log export: `backend/functions/src/handlers/audit_export.js` (for GDPR DSAR, regulatory audits)
- [ ] T070 Write audit immutability tests: `backend/test/immutable_audit_log.test.js` (prevent deletion, modification, unauthorized export)

### Enhanced Reliability Validation (Production Safety)

- [ ] T071 [P] Create idempotency key generation: `mobile/lib/core/utils/idempotency_key_generator.dart` (request ID + parameter hash, handles retries)
- [ ] T072 [P] Implement duplicate prevention validator: `backend/functions/src/utils/duplicate_prevention.js` (booking + payment idempotency enforcement)
- [ ] T073 Create consistency verification utility: `backend/functions/src/utils/consistency_verifier.js` (compare appointment status vs queue position, audit discrepancies)
- [ ] T074 Implement transaction rollback on failure: `backend/functions/src/utils/transaction_rollback.js` (booking + payment atomic, full refund on payment failure)
- [ ] T075 Write idempotency tests: `backend/test/idempotency.test.js`, `mobile/test/unit/utils/idempotency_key_generator_test.dart`

### Enhanced Disaster Recovery Infrastructure (Production Resilience)

- [ ] T076 [P] Set up daily backup automation: `backend/firebase-backup-config.json` (encrypted daily backups to separate region, automated trigger)
- [ ] T077 [P] Implement backup integrity verification: `backend/functions/src/handlers/backup_verification.js` (daily checksum validation, test restore capability)
- [ ] T078 Create failover configuration: `backend/firebase-failover-config.json` (read-only replicas, automatic failover trigger at 15-min downtime)
- [ ] T079 Implement graceful degradation: `backend/functions/src/handlers/graceful_degradation.js` (core services operational if notifications/analytics fail)
- [ ] T080 Create disaster recovery runbooks: `backend/docs/disaster_recovery_runbooks.md` (procedures for common failures: database corruption, provider down, region unavailable)

### Enhanced Observability & Monitoring (Production Visibility)

- [ ] T081 [P] Set up structured JSON logging: `mobile/lib/core/utils/structured_logger.dart` (all operations logged with requestID, userID, operation, result)
- [ ] T082 [P] Configure Firebase Crashlytics integration: `mobile/lib/core/utils/crashlytics_integration.dart` with source mapping
- [ ] T083 Create Cloud Logging setup: `backend/functions/src/utils/cloud_logger.js` (structured backend logs for all operations)
- [ ] T084 Implement monitoring dashboard: `backend/firebase-monitoring-dashboards.json` (bookings/min, payment success rate, queue depth, error rates, SLA compliance)
- [ ] T085 Create alerting rules: `backend/firebase-alerting-rules.json` (critical: >1% failure rate, payment timeout, SMS provider down, queue backlog >50 patients)
- [ ] T086 Implement on-call escalation: `backend/functions/src/handlers/escalation_handler.js` (alerts escalate if not acknowledged within 15 minutes)
- [ ] T087 Write observability tests: `backend/test/structured_logging.test.js` (verify all operations logged, dashboards queryable)

**Checkpoint**: All enhanced foundational tests pass. Architecture includes production-grade reliability, audit compliance, disaster recovery, and observability.

---

## Phase 3: User Story 1 - Patient Books Appointment (Priority: P1) 🎯 **MVP Core**

**Goal**: Patient can search clinics, select time slot, pay, receive QR code confirmation. Core booking flow working end-to-end. Appointment enters proper lifecycle states (Pending-Booking → Booked → Confirmed).

**Independent Test**: Opening app → searching clinic/department → selecting slot → completing payment → receiving booking confirmation + QR with proper state transitions. User Story 1 alone is an MVP.

### Tests for US1

> **NOTE: Write these tests FIRST (TDD), ensure they FAIL before implementation**

- [ ] T088 [P] [US1] Contract test for booking API: `mobile/test/contract/booking_api_contract_test.dart` (request/response schemas)
- [ ] T089 [P] [US1] Contract test for payment API: `mobile/test/contract/payment_api_contract_test.dart`
- [ ] T090 [P] [US1] Unit test for booking use case: `mobile/test/unit/usecases/booking_usecase_test.dart` (slots validation, double-booking prevention, idempotency)
- [ ] T091 [P] [US1] Unit test time slot calculation: `mobile/test/unit/domain/entities/time_slot_test.dart`
- [ ] T092 [P] [US1] Unit test appointment state transitions: `mobile/test/unit/entities/appointment_state_transitions_test.dart` (Pending → Booked → Confirmed)
- [ ] T093 [US1] Integration test for full booking→payment→QR flow: `mobile/test/integration/booking_flow_test.dart` (real Firestore Emulator, state transitions)
- [ ] T094 [US1] Integration test for appointment lifecycle: `mobile/test/integration/appointment_lifecycle_test.dart` (verify state progression, audit trail populated)

### Implementation for US1

- [ ] T095 [P] [US1] Create Clinic & Department entities: `mobile/lib/domain/entities/clinic.dart`, `mobile/lib/domain/entities/department.dart` with availability info
- [ ] T096 [P] [US1] Create TimeSlot entity: `mobile/lib/domain/entities/time_slot.dart` with doctor availability, consultation duration
- [ ] T097 [P] [US1] Create Appointment entity: `mobile/lib/domain/entities/appointment.dart` with status (using 8-state lifecycle), QR code, payment state, audit-trail ref
- [ ] T098 [P] [US1] Create Payment entity: `mobile/lib/domain/entities/payment.dart` (idempotency key, amount, method, status)
- [ ] T099 [US1] Create booking use case (no double-booking): `mobile/lib/domain/usecases/booking_usecase.dart` with idempotency + state machine validation (Constitution Principle VI)
- [ ] T100 [US1] Create clinic & time slot repository: `mobile/lib/data/repositories/clinic_repository.dart` (search, availability queries)
- [ ] T101 [US1] Create appointment repository with state tracking: `mobile/lib/data/repositories/appointment_repository.dart` (CRUD with transactions, state transitions, audit logged)
- [ ] T102 [US1] Create payment repository: `mobile/lib/data/repositories/payment_repository.dart` (VNPay, MoMo, Stripe integration stubs)
- [ ] T103 [US1] Implement clinic search screen: `mobile/lib/presentation/screens/booking/clinic_search_screen.dart` (search box, filter by department, large text 18pt+, WCAG accessible)
- [ ] T104 [US1] Implement time slot selection screen: `mobile/lib/presentation/screens/booking/time_slot_screen.dart` (available slots, doctor info, accessibility labels, one-tap selection)
- [ ] T105 [US1] Implement payment screen: `mobile/lib/presentation/screens/booking/payment_screen.dart` (payment method selection, OTP confirmation, idempotent submission, large buttons)
- [ ] T106 [US1] Implement booking confirmation screen: `mobile/lib/presentation/screens/booking/confirmation_screen.dart` (QR code display, SMS sent indicator, appointment details, state display)
- [ ] T107 [US1] Set up booking state management: `mobile/lib/presentation/cubit/booking_cubit.dart` with state transitions (Pending → Booked → Confirmed)
- [ ] T108 [US1] Create QR code generator with encryption: `mobile/lib/core/utils/qr_generator.dart` (time-limited, one-time use, encrypted – Constitutional Principle VI, FR-071)
- [ ] T109 [US1] Implement booking notification: `mobile/lib/data/repositories/notification_repository.dart` SMS + push for booking confirmation with state → (stub for Phase 4)
- [ ] T110 [US1] Create Firestore booking collection schema: `backend/firestore.indexes.json` with uniqueness constraints (patient+doctor+time_slot), appointment state tracking
- [ ] T111 [US1] Implement backend booking handler: `backend/functions/src/handlers/booking.js` with transaction for booking + QR generation, state management (Pending → Booked)
- [ ] T112 [US1] Implement backend payment processor: `backend/functions/src/handlers/payment.js` (idempotent, atomic with booking, emit PaymentProcessed event, state update to Confirmed)
- [ ] T113 [US1] Create payment provider integrations (stubs): `backend/functions/src/handlers/payment_providers/` (vnpay.js, momo.js, stripe.js)
- [ ] T114 [US1] Wire up backend booking events: `backend/functions/src/handlers/booking.js` emits BookingCreated event to Pub/Sub with state info
- [ ] T115 [US1] Implement appointment audit logging: `backend/functions/src/handlers/booking.js` fires audit trail for each state transition (who, what, when)
- [ ] T116 [US1] Write integration tests for booking flow: `mobile/test/integration/booking_flow_test.dart` (end-to-end with emulator, state transitions verified)

**Checkpoint: User Story 1 is COMPLETE and independently testable. Patient can book with proper state management. MVP is functional with lifecycle tracking.**

---

## Phase 4: User Story 2 - Doctor/Admin Manages Queue (Priority: P1) - **Production Hospital Workflow**

**Goal**: Doctor/Admin dashboard shows real-time queue with queue numbers, marks patients checked-in/completed, priority queue (elderly/emergency), auto-calling for next patient, public kiosk displays. Real-time hospital workflow management.

**Independent Test**: Doctor login → viewing queue with queue numbers → checking patient in (queue number assigned) → marking complete → verifying queue auto-calls next patient. Independent operational flow testing.

### Tests for US2

- [ ] T117 [P] [US2] Contract test for queue API: `mobile/test/contract/queue_api_contract_test.dart`
- [ ] T118 [P] [US2] Unit test queue position calculation: `mobile/test/unit/domain/entities/queue_position_test.dart`
- [ ] T119 [P] [US2] Unit test queue number assignment: `mobile/test/unit/utils/queue_number_generator_test.dart` (uniqueness, format "K-045", sequential)
- [ ] T120 [P] [US2] Unit test priority queue ordering: `mobile/test/unit/domain/usecases/priority_queue_usecase_test.dart` (emergency > elderly > general)
- [ ] T121 [P] [US2] Unit test no-show auto-cancel: `mobile/test/unit/usecases/no_show_usecase_test.dart` (1-hour timeout, unpaid bookings only)
- [ ] T122 [US2] Integration test for queue real-time updates: `mobile/test/integration/queue_realtime_test.dart` (Firestore listeners, updates within 5s)
- [ ] T123 [US2] Integration test for queue number assignment: `mobile/test/integration/queue_number_assignment_test.dart` (assigned at check-in, unique per clinic)
- [ ] T124 [US2] Integration test for priority queue: `mobile/test/integration/priority_queue_test.dart` (elderly/emergency prioritized)
- [ ] T125 [US2] Integration test for no-show cancellation: `mobile/test/integration/no_show_test.dart` (auto-cancel after 1 hour)
- [ ] T126 [US2] Integration test for auto-calling: `mobile/test/integration/auto_call_notification_test.dart` (push/SMS sent when ≤2 positions away)

### Implementation for US2 - Advanced Queue Management

- [ ] T127 [P] [US2] Create QueuePosition entity with queue number: `mobile/lib/domain/entities/queue_position.dart` (queue-number, position, estimated-wait, priority-level, auto-call-sent)
- [ ] T128 [P] [US2] Create priority queue use case: `mobile/lib/domain/usecases/priority_queue_usecase.dart` (sort by emergency/elderly/general, FIFO within each priority)
- [ ] T129 [P] [US2] Create queue use case with lifecycle: `mobile/lib/domain/usecases/queue_usecase.dart` (calculate wait time, get next patient, state transitions)
- [ ] T130 [P] [US2] Create no-show use case: `mobile/lib/domain/usecases/no_show_usecase.dart` (auto-cancel after 1 hour grace, unpaid bookings)
- [ ] T131 [P] [US2] Create auto-call use case: `mobile/lib/domain/usecases/auto_call_usecase.dart` (trigger when patient is ≤2 positions from consultation)
- [ ] T132 [US2] Create queue repository with real-time: `mobile/lib/data/repositories/queue_repository.dart` (Firestore listeners for real-time updates, 10-second refresh)
- [ ] T133 [US2] Create doctor workload repository: `mobile/lib/data/repositories/doctor_workload_repository.dart` (current utilization, max-capacity check)
- [ ] T134 [US2] Implement doctor/admin login & authorization: `mobile/lib/presentation/screens/auth/doctor_login_screen.dart` with role-based access (Constitution Principle V)
- [ ] T135 [US2] Implement queue dashboard screen with queue numbers: `mobile/lib/presentation/screens/queue/queue_dashboard_screen.dart` (queue-ID, patient name, check-in status, avg consultation time, priority badge, large text 18pt+ accessible)
- [ ] T136 [US2] Implement check-in action with queue number display: `mobile/lib/presentation/screens/queue/check_in_widget.dart` (QR scan confirmation, show assigned queue number, add to priority queue)
- [ ] T137 [US2] Implement consultation complete action: `mobile/lib/presentation/screens/queue/complete_consultation_widget.dart` (move to post-consultation, display next patient queue number, trigger auto-call)
- [ ] T138 [US2] Implement doctor workload display: `mobile/lib/presentation/screens/queue/doctor_workload_widget.dart` (scheduled, checked-in, completed, in-queue counts, behind-schedule alerts)
- [ ] T139 [US2] Implement break time management: `mobile/lib/presentation/screens/queue/break_time_widget.dart` (set break period, queue paused during break, warning if patient checked in during break)
- [ ] T140 [US2] Set up queue real-time state management: `mobile/lib/presentation/cubit/queue_cubit.dart` (Firestore listeners, auto-refresh every 5 sec or major change, state transitions tracked)
- [ ] T141 [US2] Implement public kiosk display screen: `web/src/components/KioskQueueDisplay.jsx` (shows position numbers + next 3 queue numbers, no patient names, refreshes every 10 sec, minimal UI for accessibility)
- [ ] T142 [US2] Implement patient app queue status screen: `mobile/lib/presentation/screens/queue/queue_status_screen.dart` (queue position, estimated time, auto-refresh updates)
- [ ] T143 [US2] Create backend queue listener: `backend/functions/src/handlers/queue.js` (CQRS read model for queue queries, priority sorting, emits QueueUpdated events)
- [ ] T144 [US2] Implement queue number assignment handler: `backend/functions/src/handlers/queue_number_assignment.js` (assign unique queue number at check-in, FR-025-FR-027 compliance)
- [ ] T145 [US2] Implement priority queue handler: `backend/functions/src/handlers/priority_queue.js` (emergency/elderly priority enforcement, FIFO within priority level)
- [ ] T146 [US2] Implement auto-call trigger handler: `backend/functions/src/handlers/auto_call_trigger.js` (when patient ≤2 positions away, emit AutoCallTriggered event)
- [ ] T147 [US2] Implement no-show watcher: `backend/functions/src/handlers/no_show_watcher.js` (Cloud Scheduler triggers 1 hour after appointment, auto-cancels unpaid bookings, emits NoShowCancelled event)
- [ ] T148 [US2] Create kiosk display data publisher: `backend/functions/src/handlers/kiosk_display_publisher.js` (publishes summary queue state every 10 seconds, delta updates only)
- [ ] T149 [US2] Wire up no-show notifications: `backend/functions/src/handlers/notification.js` subscribes to no-show events, sends SMS to patient with recovery options
- [ ] T150 [US2] Implement doctor reassignment handler: `backend/functions/src/handlers/patient_reassignment.js` (allows admin to manually move patient to less-busy doctor, updates queue immediately)
- [ ] T151 [US2] Create web admin dashboard (React): `web/src/components/AdminDashboard.jsx` with doctor workload, patient reassignment UI, queue management controls
- [ ] T152 [US2] Implement kiosk display multi-location support: `web/src/services/kiosk_display_service.js` (separate displays per clinic/department, configurable layouts)
- [ ] T153 [US2] Write comprehensive queue integration tests: `mobile/test/integration/queue_comprehensive_test.dart` (priority ordering, queue numbers, auto-calls, no-shows)

**Checkpoint: User Story 2 is COMPLETE with production hospital workflow. Queue numbers assigned, priority handled, auto-calling functional, real-time updates. Combined with US1, system fully operational.**

---

## Phase 5: User Story 3 - Secure QR-Based Check-In (Priority: P1)

**Goal**: Patient scans QR at kiosk or shows in app, system validates (time-limited, one-time use), marks checked-in, assigns queue number, adds to priority queue.

**Independent Test**: Generating QR → scanning at kiosk → system marks checked-in + assigns queue number → patient appears in priority queue. Can test independently with scaffold data.

### Tests for US3

- [ ] T154 [P] [US3] Unit test QR validation: `mobile/test/unit/core/utils/qr_validation_test.dart` (time window, one-time-use enforcement, encryption)
- [ ] T155 [P] [US3] Unit test QR regeneration on expiry: `mobile/test/unit/usecases/qr_regeneration_usecase_test.dart`
- [ ] T156 [US3] Integration test QR scan flow: `mobile/test/integration/qr_checkin_test.dart` (generate QR → scan → verify checked-in + queue number assigned)
- [ ] T157 [US3] Integration test QR one-time-use enforcement: `mobile/test/integration/qr_reuse_prevention_test.dart` (second scan rejected immediately)
- [ ] T158 [US3] Integration test QR expiry and regeneration: `mobile/test/integration/qr_expiry_test.dart` (expired QR auto-regenerates on demand)

### Implementation for US3

- [ ] T159 [P] [US3] Create QR code entity: `mobile/lib/domain/entities/qr_code.dart` (token, validity-window, one-time-use flag, encrypted-token)
- [ ] T160 [P] [US3] Create QR validation use case: `mobile/lib/domain/usecases/qr_validation_usecase.dart` (time/one-time-use check, Constitution Principle VI, FR-004/FR-071)
- [ ] T161 [US3] Create QR repository: `mobile/lib/data/repositories/qr_repository.dart` (track scans, mark used, regenerate, audit logging per FR-046)
- [ ] T162 [US3] Implement QR display widget: `mobile/lib/presentation/widgets/qr_display_widget.dart` (large QR, regenerate, encryption indicator, accessibility labels)
- [ ] T163 [US3] Implement QR scanner (kiosk): `mobile/lib/presentation/screens/queue/qr_scanner_screen.dart` (camera access, barcode scanning, large UI 48x48 buttons)
- [ ] T164 [US3] Implement check-in confirmation: `mobile/lib/presentation/screens/queue/check_in_confirmation_screen.dart` (success/failure, queue number display, next steps)
- [ ] T165 [US3] Create QR validation cubit: `mobile/lib/presentation/cubit/qr_validation_cubit.dart` state management with audit logging
- [ ] T166 [US3] Implement backend QR generation: `backend/functions/src/handlers/booking.js` generates time-limited (2-hour), encrypted, one-time-use QR tokens per FR-004/FR-071
- [ ] T167 [US3] Implement backend QR validation: `backend/functions/src/handlers/qr_validation.js` (time/one-time check, emit CheckedIn, assign queue number, audit log)
- [ ] T168 [US3] Create QR invalidation on cancel: `backend/functions/src/handlers/booking.js` immediately voids QR on cancellation, audit logged per FR-035
- [ ] T169 [US3] Create QR regeneration endpoint: `backend/functions/src/handlers/qr_regeneration.js` (regenerate expired QR on demand, audit logged)
- [ ] T170 [US3] Implement QR encryption: `backend/functions/src/utils/qr_encryption.js` (AES-256, salted, Constitution Principle VI, FR-071)
- [ ] T171 [US3] Write QR security tests: `backend/test/qr_security.test.js` (one-time enforcement, time validation, encryption)

**Checkpoint: User Story 3 is COMPLETE. Secure QR check-in with queue number assignment is robust.**

---

## Phase 6: User Story 4 - Multi-Channel Notifications (Priority: P2)

**Goal**: SMS, email, push notifications for booking confirmation, 24h reminder, queue updates, results.

**Independent Test**: Creating booking → verifying SMS/email/push sent. Testing notification delivery independent of queue/check-in maturity.

### Tests for US4

- [ ] T112 [P] [US4] Unit test notification dispatcher: `mobile/test/unit/repositories/notification_repository_test.dart`
- [ ] T113 [P] [US4] Unit test SMS formatting: `mobile/test/unit/core/utils/sms_formatter_test.dart` (phone number validation, message templates)
- [ ] T114 [US4] Integration test booking SMS notification: `mobile/test/integration/booking_notification_test.dart`
- [ ] T115 [US4] Integration test push notification: `mobile/test/integration/push_notification_test.dart` (Firebase Cloud Messaging)

### Implementation for US4

- [ ] T116 [P] [US4] Create Notification entity: `mobile/lib/domain/entities/notification.dart` (type, recipient, content, status, timestamp)
- [ ] T117 [P] [US4] Create notification preference entity: `mobile/lib/domain/entities/notification_preference.dart` (SMS only, email, push, quiet hours)
- [ ] T118 [US4] Implement notification use case: `mobile/lib/domain/usecases/send_notification_usecase.dart` (respects preferences, accessibility for elderly)
- [ ] T119 [US4] Create notification repository: `mobile/lib/data/repositories/notification_repository.dart` (SMS via Twilio, email via SendGrid, push via FCM)
- [ ] T120 [US4] Implement notification settings screen: `mobile/lib/presentation/screens/profile/notification_settings_screen.dart` (channel preferences, quiet hours, large text)
- [ ] T121 [US4] Integrate push notification handler: `mobile/lib/core/services/fcm_service.dart` (Firebase Cloud Messaging local notifications)
- [ ] T122 [US4] Create SMS provider integration: `backend/functions/src/handlers/sms_provider.js` (Twilio or AWS SNS)
- [ ] T123 [US4] Create email provider integration: `backend/functions/src/handlers/email_provider.js` (SendGrid or Firebase Email)
- [ ] T124 [US4] Create notification scheduler: `backend/functions/src/handlers/notification_scheduler.js` (24h appointment reminder via Cloud Scheduler)
- [ ] T125 [US4] Wire up booking notification: `backend/functions/src/handlers/booking.js` publishes BookingCreated event → notification subscriber sends SMS/push/email
- [ ] T126 [US4] Create queue update publisher: `backend/functions/src/handlers/queue.js` emits QueueUpdated event → notification subscriber sends position updates
- [ ] T127 [US4] Set up notification audit logging: `backend/functions/src/handlers/notification.js` logs all sent notifications with delivery status

**Checkpoint: User Story 4 is COMPLETE. Patients receive timely, multi-channel notifications.**

---

## Phase 7: User Story 5 - View Medical Records Securely (Priority: P2)

**Goal**: Patient views past appointments, consultation notes, test results, prescriptions with encryption & audit trail.

**Independent Test**: Logging in → viewing past appointment → verifying data encrypted → checking audit log. Can scaffold with test data.

### Tests for US5

- [ ] T128 [P] [US5] Unit test medical record encryption: `mobile/test/unit/core/utils/encryption_utils_test.dart` (AES-256)
- [ ] T129 [P] [US5] Unit test audit log query: `mobile/test/unit/repositories/audit_log_repository_test.dart`
- [ ] T130 [US5] Integration test viewing medical records: `mobile/test/integration/medical_records_test.dart` (encrypted retrieval, patient auth)
- [ ] T131 [US5] Integration test audit trail: `mobile/test/integration/audit_log_test.dart`

### Implementation for US5

- [ ] T132 [P] [US5] Create MedicalRecord entity: `mobile/lib/domain/entities/medical_record.dart` (appointment ref, notes, test results, prescription, allergies, encrypted)
- [ ] T133 [P] [US5] Create AuditLog entity: `mobile/lib/domain/entities/audit_log.dart` (user, action, entity, timestamp, reason)
- [ ] T134 [US5] Create medical record use case: `mobile/lib/domain/usecases/medical_record_usecase.dart` (retrieve + decrypt, strict auth)
- [ ] T135 [US5] Create medical record repository: `mobile/lib/data/repositories/medical_record_repository.dart` (fetch from Firestore, decrypt at-rest)
- [ ] T136 [US5] Create audit log repository: `mobile/lib/data/repositories/audit_log_repository.dart` (query by patient, entity type, immutable)
- [ ] T137 [US5] Implement medical records screen: `mobile/lib/presentation/screens/medical_records/records_screen.dart` (past appointments list, large text 18pt+, high contrast)
- [ ] T138 [US5] Implement record detail screen: `mobile/lib/presentation/screens/medical_records/record_detail_screen.dart` (notes, results, prescription, voice read-aloud option for accessibility)
- [ ] T139 [US5] Implement audit log viewer: `mobile/lib/presentation/screens/medical_records/audit_log_screen.dart` (who accessed, when, read-only)
- [ ] T140 [US5] Create voice read-aloud for sensitive data: `mobile/lib/core/services/text_to_speech_service.dart` (for elderly users, Constitutional Principle VII)
- [ ] T141 [US5] Implement backend medical record model: `backend/firestore.indexes.json` collection with doctor permissions
- [ ] T142 [US5] Implement backend audit log handler: `backend/functions/src/handlers/audit_logger.js` (immutable log of all reads/writes, fires on Firestore triggers)
- [ ] T143 [US5] Implement backend medical record query: `backend/functions/src/handlers/medical_records.js` (patient-only access, doctor-shared access, encryption)
- [ ] T144 [US5] Wire up doctor update notifications: When doctor updates record, emit RecordUpdated event → notify patient

**Checkpoint: User Story 5 is COMPLETE. Medical records are secure, encrypted, audited.**

---

## Phase 8: User Story 6 - Real-Time Queue Wait Time (Priority: P2)

**Goal**: Patient sees queue position, estimated wait (based on avg consultation time), real-time updates every 5 min or major position change.

**Independent Test**: Checking in patient → viewing queue → seeing estimated time → completing consultation → seeing queue refresh. Builds on US2 queue infrastructure.

### Tests for US6

- [ ] T145 [P] [US6] Unit test wait time calculation: `mobile/test/unit/domain/entities/wait_time_calculator_test.dart` (avg consultation time × patients ahead)
- [ ] T146 [P] [US6] Unit test estimated time rounding: `mobile/test/unit/core/utils/time_formatter_test.dart`
- [ ] T147 [US6] Integration test wait time updates: `mobile/test/integration/wait_time_test.dart` (real-time Firestore listener)
- [ ] T148 [US6] Integration test major wait time alerts: `mobile/test/integration/wait_time_alert_test.dart` (notify if >30 min increase)

### Implementation for US6

- [ ] T149 [P] [US6] Create WaitTimeCalculator use case: `mobile/lib/domain/usecases/wait_time_calculator_usecase.dart` (avg time × queue depth)
- [ ] T150 [P] [US6] Create estimated wait time entity: `mobile/lib/domain/entities/estimated_wait_time.dart` (position, minutes, confidence)
- [ ] T151 [US6] Implement queue position screen: `mobile/lib/presentation/screens/queue/queue_position_screen.dart` (position number, estimated time, large text, refresh button)
- [ ] T152 [US6] Implement wait time update stream: `mobile/lib/presentation/cubit/queue_position_cubit.dart` (Firestore listener, updates every 5 sec or major position change)
- [ ] T153 [US6] Implement wait time alert: `mobile/lib/presentation/widgets/wait_time_alert_widget.dart` (if wait increases >30 min, show alert + offer reschedule/offline options)
- [ ] T154 [US6] Implement public kiosk display: `web/src/components/QueueDisplay.jsx` (shows position numbers only, no patient names, refreshes every 10 sec)
- [ ] T155 [US6] Create backend CQRS read model for queue: `backend/functions/src/handlers/queue_read_model.js` (denormalized queue state for fast queries)
- [ ] T156 [US6] Implement wait time calculation backend: `backend/functions/src/handlers/wait_time_calculator.js` (published to Pub/Sub on queue changes)

**Checkpoint: User Story 6 is COMPLETE. Queue transparency improves patient experience.**

---

## Phase 9: User Story 7 - AI Voice Assistant (Priority: P3)

**Goal**: Elderly/rural patient calls voice number, speaks booking/symptom request, AI guides through steps, books appointment, sends SMS.

**Independent Test**: Calling voice line → speaking request → AI booking → verifying SMS sent. Tests voice accessibility for target demographic.

### Tests for US7

- [ ] T157 Unit test IVR menu: `backend/test/ivr_menu_test.js` (press 1, 2, 3 routing)
- [ ] T158 Unit test symptom triage logic: `backend/test/symptom_triage_test.js` (maps symptoms to department)
- [ ] T159 Integration test voice booking flow: `backend/test/voice_booking_integration_test.js` (call → booking created → SMS sent)

### Implementation for US7

- [ ] T160 Create voice service integration: `backend/functions/src/handlers/voice_service.js` (Twilio Voice or similar)
- [ ] T161 Implement IVR menu: `backend/functions/src/handlers/ivr_menu.js` (press 1 for booking, 2 for symptom triage, 3 for results)
- [ ] T162 Implement voice booking flow: `backend/functions/src/handlers/voice_booking.js` (clinic/department selection, time slot options, payment OTP)
- [ ] T163 Implement symptom triage: `backend/functions/src/handlers/symptom_triage.js` (rule-based or simple ML mapping symptoms → department)
- [ ] T164 Integrate speech-to-text: `backend/functions/src/handlers/speech_to_text.js` (Google Speech API or AWS Transcribe)
- [ ] T165 Integrate text-to-speech: `backend/functions/src/handlers/text_to_speech.js` (Google TTS or AWS Polly in Vietnamese, English, regional languages)
- [ ] T166 Connect voice booking to SMS notification: `backend/functions/src/handlers/voice_booking.js` triggers SMS with QR code after confirmation

**Checkpoint: User Story 7 is COMPLETE. Voice accessibility enables elderly/rural users.**

---

## Phase 10: User Story 8 - Offline-First Mobile with Sync (Priority: P3)

**Goal**: Patient uses app offline (view bookings, records, prescriptions), auto-syncs on connectivity return, handles conflicts.

**Independent Test**: Enabling offline mode → viewing cached data → reconnecting → verifying sync completed without data loss. Core offline feature validation.

### Tests for US8

- [ ] T167 [P] [US8] Unit test offline cache: `mobile/test/unit/datasources/hive_local_datasource_test.dart`
- [ ] T168 [P] [US8] Unit test sync conflict resolution: `mobile/test/unit/repositories/sync_repository_test.dart`
- [ ] T169 [US8] Integration test offline viewing: `mobile/test/integration/offline_viewing_test.dart` (airplane mode, view bookings)
- [ ] T170 [US8] Integration test offline-to-online sync: `mobile/test/integration/offline_sync_test.dart` (make changes offline, sync when online, verify no data loss)
- [ ] T171 [US8] Integration test sync conflict (concurrent edits): `mobile/test/integration/sync_conflict_test.dart` (doctor cancels while patient offline, show both versions)

### Implementation for US8

- [ ] T172 [P] [US8] Create offline data synchronizer: `mobile/lib/data/repositories/sync_repository.dart` (last-write-wins or user-choice)
- [ ] T173 [P] [US8] Enhance Hive cache: `mobile/lib/data/datasources/hive_local_datasource.dart` with sync state tracking (pending, syncing, synced, conflict)
- [ ] T174 [US8] Implement offline indicator: `mobile/lib/presentation/widgets/offline_indicator_widget.dart` (show "Pending sync" status in UI)
- [ ] T175 [US8] Implement automatic sync on connectivity: `mobile/lib/presentation/cubit/offline_sync_cubit.dart` (detect network return, trigger sync, exponential backoff on retry)
- [ ] T176 [US8] Implement conflict resolution UI: `mobile/lib/presentation/screens/sync/conflict_resolution_screen.dart` (show device vs server versions, let user choose)
- [ ] T177 [US8] Implement manual sync button: `mobile/lib/presentation/widgets/manual_sync_button.dart` (allow user to force re-sync)
- [ ] T178 [US8] Create sync state machine tests: `mobile/test/unit/repositories/sync_repository_test.dart` (all state transitions)

**Checkpoint: User Story 8 is COMPLETE. Offline-first enables rural users with spotty connectivity.**

---

## Phase 11: User Story 9 - Waitlist, Reschedule, No-Show (Priority: P3)

**Goal**: Waitlist notifications when slots open, reschedule with availability check (no double-booking), auto-cancel no-shows after 1 hour.

**Independent Test**: Joining waitlist → slot opening → booking created. Rescheduling → verifying new slot. No-show → auto-cancel after 1 hour. All independent flows testable.

### Tests for US9

- [ ] T179 [P] [US9] Unit test waitlist logic: `mobile/test/unit/domain/entities/waitlist_test.dart` (FIFO, slot opening notification)
- [ ] T180 [P] [US9] Unit test reschedule availability: `mobile/test/unit/usecases/reschedule_usecase_test.dart` (prevent double-booking, refund logic)
- [ ] T181 [P] [US9] Unit test no-show cancellation: `mobile/test/unit/usecases/no_show_usecase_test.dart` (1-hour timeout, unpaid booking only)
- [ ] T182 [US9] Integration test waitlist flow: `mobile/test/integration/waitlist_test.dart` (join, slot opens, book, notify via SMS)
- [ ] T183 [US9] Integration test reschedule: `mobile/test/integration/reschedule_test.dart` (reschedule, check new availability, atomic update)
- [ ] T184 [US9] Integration test no-show cancellation: `mobile/test/integration/no_show_cancellation_test.dart` (1-hour auto-cancel)

### Implementation for US9

- [ ] T185 [P] [US9] Create Waitlist entity: `mobile/lib/domain/entities/waitlist.dart` (patient, clinic, department, position, timestamp)
- [ ] T186 [P] [US9] Create waitlist use case: `mobile/lib/domain/usecases/waitlist_usecase.dart` (join, auto-book when slot available)
- [ ] T187 [P] [US9] Create reschedule use case: `mobile/lib/domain/usecases/reschedule_usecase.dart` (verify availability, prevent double-booking, refund if needed)
- [ ] T188 [US9] Implement waitlist screen: `mobile/lib/presentation/screens/booking/waitlist_screen.dart` (join waitlist, position, notify)
- [ ] T189 [US9] Implement reschedule flow: `mobile/lib/presentation/screens/booking/reschedule_screen.dart` (show available times, confirm reschedule)
- [ ] T190 [US9] Create backend waitlist handler: `backend/functions/src/handlers/waitlist.js` (FIFO queue, triggers on cancellation)
- [ ] T191 [US9] Implement auto-book on slot open: `backend/functions/src/handlers/waitlist.js` (offers oldest waitlist patient, 1-hour acceptance window)
- [ ] T192 [US9] Implement reschedule handler: `backend/functions/src/handlers/reschedule.js` (atomic: cancel old + create new, no double-booking, issue refund)
- [ ] T193 [US9] Wire up waitlist notifications: `backend/functions/src/handlers/notification.js` subscribes to slot-open events
- [ ] T194 [US9] Extend no-show watcher: `backend/functions/src/handlers/no_show_watcher.js` (already created in US2, re-use)

**Checkpoint: User Story 9 is COMPLETE. Intelligent booking management handles realistic clinic scenarios.**

---

## Phase N: Polish & Production Hardening - **Hospital-Grade System**

**Purpose**: Integration testing, production optimization, compliance validation, disaster recovery testing, comprehensive accessibility, cost optimization, success criteria validation

### Production-Level Integration & E2E Testing

- [ ] T195 Run full E2E test suite: `mobile/test/e2e/` complete user journeys (patient sign-up → book → check-in → queue → consultation-complete → medical records viewing)
- [ ] T196 [P] Test hospital workflow end-to-end: `mobile/test/e2e/hospital_workflow_e2e_test.dart` (queue number assignment → priority queue → auto-calling → office displays)
- [ ] T197 [P] Test lifecycle state transitions: `mobile/test/e2e/appointment_lifecycle_test.dart` (all 8 states: Pending → Booked → Confirmed → Checked-in → In-Queue → In-Consultation → Post-Consultation → Completed)
- [ ] T198 [P] Test no-show handling end-to-end: `mobile/test/e2e/no_show_full_flow_test.dart` (appointment timeout → auto-cancel → recovery window → SMS notification)
- [ ] T199 [P] Test queue priority enforcement: `mobile/test/e2e/priority_queue_e2e_test.dart` (elderly/emergency patients wait ≤50% of general queue)
- [ ] T200 [P] Test payment idempotency end-to-end: `backend/test/payment_idempotency_e2e.test.js` (double-charge prevention across network failures)
- [ ] T201 [P] Test offline sync end-to-end: `mobile/test/e2e/offline_sync_e2e_test.dart` (offline changes → sync → conflict resolution → audit trail)

### Production Performance & Optimization

- [ ] T202 [P] Performance profiling: `backend/tools/performance_analysis.js` profile app load time, measure on 3G network, target <2s load (SC-004)
- [ ] T203 [P] Bundle size optimization: Reduce Flutter app bundle to <50MB, backend cloud functions to <512MB
- [ ] T204 [P] Database query optimization: Profile all Firestore queries, ensure O(log n) complexity, validate index usage per FR-125
- [ ] T205 [P] Real-time optimization audit: Verify WebSocket/polling trade-off implementation per FR-130 (10-second kiosk updates not per-patient)
- [ ] T206 [P] Notification batch verification: Validate SMS/email batching (70-90% reduction per FR-131) in load test
- [ ] T207 [P] Cache effectiveness audit: Measure cache hit rates (target 5-minute TTL per FR-128), validate invalidation triggers
- [ ] T208 Cost optimization validation: `backend/tools/cost_analysis.js` calculate infrastructure cost, verify optimization strategies per Cost Optimization section

### Security Hardening & Compliance

- [ ] T209 [P] Security audit: Penetration testing checklist (XSS, CSRF, SQL injection, authorization bypasses, data exposure)
- [ ] T210 [P] Data masking in logs: Verify PII masking in structured logs (phone numbers, medical info), sensitive data not logged per FR-146
- [ ] T211 [P] Secrets management: Verify API keys/credentials stored in Secret Manager, not in code, no hardcoded secrets
- [ ] T212 [P] Encryption audit: Verify AES-256 for sensitive data at-rest, TLS 1.3 in-transit, key rotation procedures per FR-071
- [ ] T213 [P] Immutable audit log validation: Verify tamper detection (checksums), deletion prevention, export policies per FR-047
- [ ] T214 [P] HIPAA/GDPR compliance audit: Review data retention policies per FR-049, access logs per FR-048, breach response procedures per FR-050
- [ ] T215 [P] PCI compliance review: Verify no direct card storage (delegated to payment providers), PCI scanning results
- [ ] T216 [P] Firestore security rules verification: Role-based access control validated, patient-only access enforced per FR-010

### Comprehensive Accessibility Testing & Validation

- [ ] T217 Full WCAG 2.1 AA audit: Automated scan + manual testing on all screens per FR-070-FR-077 requirements
- [ ] T218 Screen reader compatibility: Test with Talkback (Android) and VoiceOver (iOS) for all user journeys (SC-020: 90% elderly success)
- [ ] T219 Voice interface testing: Test voice booking flow with elderly users, measure call completion rate (SC-019: ≥100% successful bookings, SC-021: ≥85% completion)
- [ ] T220 [P] Large font mode validation: Test all screens at 18pt, 20pt, 24pt fonts, verify readability and layout per FR-070
- [ ] T221 [P] High contrast mode validation: Test WCAG AA color contrast (≥4.5:1) on all text/buttons per FR-071
- [ ] T222 [P] Icon-first UI testing: Verify icon recognition with target demographic (48x48dp minimum per FR-073-FR-074)
- [ ] T223 [P] Simplified elderly interface: User test with 5+ elderly users (60+), measure task completion rate without assistance (SC-020: 90%)
- [ ] T224 [P] One-tap operations: Verify booking, check-in, reschedule can be completed in single tap where applicable per FR-073
- [ ] T225 [P] Accessibility performance: Measure screen reader lag, voice response latency (<2s per FR-077 voice navigation)
- [ ] T226 Accessibility documentation: Create accessibility guide for patients, clinics, admin users per Constitution Principle VII

### Disaster Recovery & Resilience Validation

- [ ] T227 Backup integrity test: Perform weekly backup verification, calculate actual restore time, document RTO per SC-038-SC-039
- [ ] T228 RTO/RPO testing: Run full restoration from backup in separate env, document achieved time vs. target (RTO ≤4hrs, RPO ≤1hr per SC-038-SC-041)
- [ ] T229 [P] Failover automation test: Trigger primary region failure, verify automatic failover to standby within 15 min per SC-041
- [ ] T230 [P] Data loss prevention audit: Verify zero booking/transaction data loss in failover scenario per SC-041
- [ ] T231 [P] Graceful degradation test: Simulate payment provider down, verify booking/queue still operational per FR-133
- [ ] T232 [P] Notification provider failover: Simulate SMS provider down, verify fallback to email/push per FR-131 channel prioritization
- [ ] T233 [P] Extended outage scenario: Simulate 24+ hour outage, verify recovery completeness, audit log consistency
- [ ] T234 Disaster recovery runbook validation: Execute documented runbooks with operations team, measure MTTR per FR-135

### Enhanced Monitoring & Alerting Validation

- [ ] T235 Monitoring dashboard validation: Verify all metrics visible and queryable (bookings/min, payment rate, queue depth, error rates per FR-127)
- [ ] T236 [P] SLA tracking: Calculate uptime %uptime across operations, verify 99.5% target achieved over test period (SC-024)
- [ ] T237 [P] Alert accuracy testing: Trigger > failure, payment timeout, provider down, verify alerts fire within 2 min (SC-044)
- [ ] T238 [P] False positive reduction: Measure alert false positive rate, target <5% per SC-043
- [ ] T239 [P] On-call escalation: Test escalation workflow, verify escalation after 15-min no acknowledgment per FR-140
- [ ] T240 [P] Log query performance: Measure time to query error logs, verify <1 second response per FR-146
- [ ] T241 [P] metrics aggregation: Validate 1-minute aggregation for 24-hour retention, 1-year rollup storage per FR-127
- [ ] T242 Operational readiness: Ensure operations team trained on dashboards, alerts, runbooks per FR-135-FR-140

### Success Criteria Validation & Measurement

- [ ] T243 [P] Booking performance validation: Measure patient booking time from app open to confirmation, target <3 minutes (SC-001)
- [ ] T244 [P] Concurrency load testing: Test 1,000 concurrent bookings, verify zero errors (SC-002)
- [ ] T245 [P] Queue latency measurement: Measure queue update latency from status change to UI display, verify <5s (95% <2s per SC-003)
- [ ] T246 [P] Mobile performance on 3G: Profile on throttled 3G (< 1 Mbps), verify <2s load time (SC-004)
- [ ] T247 [P] Offline functionality validation: Verify core features work offline, 100% availability offline (SC-005)
- [ ] T248 [P] Auto-sync latency: Measure connectivity restored → sync complete time, target 30s (SC-006)
- [ ] T249 [P] Notification delivery SLA: Measure SMS/email delivery, target 95% within 2 min (SC-007)
- [ ] T250 [P] Double-booking prevention: Concurrent booking attempts same slot, verify 100% prevention (SC-008)
- [ ] T251 [P] QR one-time-use enforcement: Attempt QR re-scan, verify 100% rejection (SC-009)
- [ ] T252 [P] No-show reduction measurement: Compare no-show rate before/after SMS reminders, target 30% reduction (SC-010)
- [ ] T253 [P] Voice booking success rate: Measure voice bookings completed successfully, target 100% (SC-011)
- [ ] T254 [P] Elderly user success rate: Test with 10+ elderly users, measure unassisted success rate, target 90% (SC-012)
- [ ] T255 [P] System uptime calculation: Monitor production uptime over 30 days, verify 99.5% target (SC-024)
- [ ] T256 [P] Audit log completeness: Sample-verify 100% of operations logged, no missing entries (SC-034)

### Documentation & Deployment Readiness

- [ ] T257 Create comprehensive README: `README.md` with project overview, tech stack, local setup, testing, deployment
- [ ] T258 Create deployment guide: `DEPLOYMENT.md` with Firebase setup, environment config, secrets, DNS config
- [ ] T259 Create operations runbook: `OPERATIONS.md` with monitoring, alerting, incident response, escalation
- [ ] T260 Create accessibility guide: `ACCESSIBILITY.md` for patients, clinics, staff on using accessible features
- [ ] T261 Create API documentation: `API.md` documenting all backend endpoints, contracts, error codes
- [ ] T262 Create database schema docs: `DATABASE.md` documenting Firestore collections, indexes, security rules
- [ ] T263 Create hospital workflow guide: `HOSPITAL_WORKFLOW.md` documenting queue number system, priority handling, station management
- [ ] T264 Create HIPAA/GDPR compliance docs: `COMPLIANCE.md` with data retention, access logs, breach procedures
- [ ] T265 Code quality review: Ensure all code meets Constitution standards (clean architecture, comprehensive testing, security)
- [ ] T266 Architecture documentation: Create architecture diagrams showing data flow, queue system, state machine, disaster recovery topology

### Final Production Deployment & Validation

- [ ] T267 Firestore indexes deployment: Deploy all production indexes per schema, verify query performance
- [ ] T268 Cloud Functions deployment: Deploy all backend handlers to production, verify cold start times
- [ ] T269 Cloud Scheduler validation: Verify scheduled jobs (no-show watcher, backup scheduler, monitoring jobs) running on schedule
- [ ] T270 Firebase config verification: Verify Firebase project config in production, all services enabled
- [ ] T271 Environment variable validation: Verify all secrets and configs properly set through Secret Manager
- [ ] T272 Monitoring activation: Verify dashboards reporting metrics, alerts active, log streaming working
- [ ] T273 Backup automation: Verify daily backups running on schedule, backup integrity checks passing
- [ ] T274 DNS & SSL verification: Verify HTTPS enabled, SSL certificates valid, DNS properly configured
- [ ] T275 Final smoke test: Complete end-to-end smoke test simulating all user flows in production environment
- [ ] T276 Production sign-off: All acceptance criteria met, Constitution principles verified, ready for go-live

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion — **BLOCKS all user stories**
- **User Stories (Phases 3–11)**: All depend on Foundational completion
  - User Stories 1–3 (P1): Can run in sequence or parallel (minimal interdependence)
  - User Stories 4–6 (P2): Can start after Story 3; build on Story 1 but don't block it
  - User Stories 7–9 (P3): Can start after Story 6; advanced features, non-blocking
- **Polish (Phase N)**: Depends on Stories 1–3 complete; runs parallel to Stories 4–9

### User Story Dependencies

- **US1 (Booking)**: No blocking story dependencies
- **US2 (Queue)**: Depends on US1 architecturally; can develop in parallel with separate test data
- **US3 (QR Check-in)**: Depends on US1 (booking creates QR); can test QR validation independently
- **US4 (Notifications)**: Depends on US1, US2 (triggered by booking, queue events); can develop notifications independently
- **US5 (Medical Records)**: Independent of US1–4; depends only on auth/encryption from Foundation
- **US6 (Wait Time)**: Depends on US2 (queue infrastructure)
- **US7 (Voice)**: Independent; depends only on Foundation + auth
- **US8 (Offline Sync)**: Independent implementation; enhances all other stories
- **US9 (Waitlist/Reschedule)**: Depends on US1 (bookings), US2 (no-show auto-cancel)

### Within Each User Story

1. Tests first (TDD: RED → GREEN → REFACTOR)
2. Domain entities + use cases
3. Repository interfaces + implementations
4. UI/screens
5. Backend handlers
6. Integration tests
7. End-to-end validation

### Parallel Opportunities - Enhanced Production Build

**Phase 1 Setup** (mark [P]):

- T002–T009: All setup tasks can run in parallel (separate Flutter, React, Node.js projects)

**Phase 2 Foundational** (organize into 4 parallel workstreams, 4 developers):

**Workstream A - Authentication & Authorization** (T010-T017):

- Can run fully in parallel

**Workstream B - Encryption & Audit Compliance** (T018-T087):

- T018-T021: Encryption can run in parallel with sub-team A
- T066-T070: Immutable audit logging independent
- T081-T087: Observability independent

**Workstream C - Offline-First & Sync** (T023-T028):

- Hive local database setup (T023-T027) can run in parallel with workstreams A/B

**Workstream D - Idempotency & Reliability** (T029-T034, T071-T075):

- Idempotency utilities can run in parallel
- Duplicate prevention validator (T072) depends on transaction utilities

**Workstream E - Advanced State Machines & Tracking** (T053-T065):

- Queue number generation (T053-T057)
- Doctor workload state (T062-T065)
- Appointment lifecycle (T053-T061)
- All can run in parallel with 2-3 developers

**Workstream F - Disaster Recovery & Monitoring** (T076-T087):

- Backup automation (T076-T077)
- Failover configuration (T078-T080)
- Observability setup (T081-T087)
- All independent, can parallelize

**Recommended Parallel Structure for Phase 2:**

- Developer 1 + 2: Workstream A (Auth) + Workstream B1 (Encryption)
- Developer 3 + 4: Workstream C (Sync) + Workstream D (Idempotency)
- Developer 5 + 6: Workstream E (State Machines)
- Developer 7: Workstream F (DR/Monitoring)
- Estimated Phase 2 completion: 3-4 weeks with 7-person team

**Phase 3 US1 Booking** (2 developers):

- T088–T093: All tests [P] - can parallelize unit + contract tests
- T095–T098: All entities [P] - domain models in parallel
- T099-T116: Repositories + screens + backend handlers - sequential per dependencies

**Phase 4 US2 Queue** (independent team of 3):

- T117–T126: ALL tests [P] - tests in parallel by domain
- T127–T132: ALL use cases + repository [P] - independent domain logic
- T133-T153: Backend handlers can run parallel with frontend screens
- Estimated: 2-3 weeks concurrent with US1

**Phases 5-11 (User Stories 3-9):**

- Each story can have 1-2 developers
- US1-3 (P1): Sequential, each 1-2 weeks
- US4-6 (P2): Can start after US3, 3 parallel teams if staffed
- US7-9 (P3): Can start after US6, 3 parallel teams if staffed

**Phase N Polish** (runs parallel to Stories 4-9, 3+ developers):

- T195-T201: E2E testing can start as soon as US1-3 complete
- T202-T208: Performance/optimization independent of new features
- T217-T226: Accessibility testing parallelizable (different screens/devices)
- T227-T234: DR testing can run anytime
- T235-T243: Monitoring/dashboards testing independent
- Estimated: 2-3 weeks final hardening

---

## Implementation Strategies - Production-Grade Delivery

### Recommended MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (1 week)
2. Complete Phase 2: Foundational (3-4 weeks with 7 developers parallel)
3. Complete Phase 3: User Story 1 (Booking) (2 weeks)
   - Parallel: Phase 4 US2 Queue can start after foundational + US1 tests
4. **STOP and VALIDATE**: Patient can book end-to-end in <3 min
5. Deploy to internal testers (small pilot)
6. Collect initial feedback on US1 + US2
7. Proceed to US3-4 after validation

### Incremental Delivery Path (Recommended for Production)

1. **Timeline: Weeks 1-4** → Phase 1 + Setup
2. **Timeline: Weeks 5-8** → Phase 2 Foundational (parallel teams)
3. **Timeline: Weeks 9-10** → Phase 3 US1 Booking MVP ([US1 Demo to stakeholders](booking-works.md))
4. **Timeline: Weeks 10-12** → Phase 4 US2 Queue (parallel with US1 refinement) → **v1.0 Demo (Queue System)**
5. **Timeline: Weeks 13-14** → Phase 5 US3 QR Check-in → **v1.1 Release (Secure Check-in)**
6. **Timeline: Weeks 15-16** → Phase 6 US4 Notifications → **v1.2 Release (Multi-Channel)**
7. **Timeline: Weeks 17-18** → Phase 7 US5 Medical Records → **v1.3 Release (HIPAA-Ready)**
8. **Timeline: Weeks 19-20** → Phase 8 US6 Wait Time + Phase 9 US7 Voice + Phase 10 US8 Offline
9. **Timeline: Weeks 21-22** → Phase 11 US9 Waitlist → **v2.0 Release (Full Feature)**
10. **Timeline: Weeks 23-24** → Phase N Polish + Production Hardening → **Go-Live Candidate**

Each delivery milestone is independently testable and deployable.

### Parallel Team Strategy (Recommended for 10+ Person Team)

- **Core Team (4 people)**: Foundation (Phase 2), maintain architecture
- **Feature Team 1 (3 people)**: US1 + US2 (Booking + Queue) - the MVP core
- **Feature Team 2 (3 people)**: US3 + US4 + US5 (QR + Notifications + Medical Records)
- **Feature Team 3 (3 people)**: US6 + US7 + US8 (Wait Time + Voice + Offline)
- **DevOps/QA** (2 people): Infrastructure, monitoring, test orchestration

Coordinated by weekly sync meetings, shared branch strategy.

---

## Acceptance Criteria per Phase - Production Completeness

### Phase 1 Setup: PASS ✓

- [ ] All projects initialize without errors (Flutter, React, Node.js)
- [ ] Dependencies install cleanly (pubspec.yaml, package.json, Firebase)
- [ ] Linting/formatting configured and passing
- [ ] Git ignore files and folder structure validated

### Phase 2 Foundational: PASS ✓ (BLOCKS all user stories)

- [ ] 87+ foundational tasks complete (T010-T087)
- [ ] Auth flow works (phone → OTP → logged in as Patient/Doctor/Admin)
- [ ] Encryption/decryption verified (AES-256 at-rest, TLS 1.3 in-transit)
- [ ] Offline cache persists data across app restarts
- [ ] Sync resolves conflicts correctly (last-write-wins tested)
- [ ] Firestore security rules enforce RBAC per Constitution Principle V
- [ ] Audit logs immutable (tamper detection verified)
- [ ] Events publishing to Pub/Sub
- [ ] Appointment state machine working (8 states validated)
- [ ] Queue number generation unique (no collisions)
- [ ] Doctor workload tracking operational
- [ ] Patient-visible audit trails implemented
- [ ] Disaster recovery infrastructure in place (backups, failover)
- [ ] Monitoring dashboards and alerts configured
- [ ] All foundational tests pass (≥80% coverage)
- [ ] Firebase Emulator working for local development

### Phase 3 US1 Booking: PASS ✓

- [ ] Patient can book appointment in <3 minutes (SC-001)
- [ ] Double-booking prevented 100% (SC-008) via idempotency
- [ ] Payment atomic with booking (no charge without booking)
- [ ] QR generated (time-limited 2-hour window, encrypted)
- [ ] SMS confirmation sent (≥95% delivery within 2 min per SC-007)
- [ ] Appointment state transitions to Booked → Confirmed
- [ ] All US1 tests pass (≥80% coverage)
- [ ] Constitution Check: Clean Architecture verified
- [ ] Accessibility verified (large fonts 18pt+, WCAG labels)
- [ ] Audit trail populated for booking events
- [ ] Offline booking support (queue locally, sync when online)

### Phase 4 US2 Queue: PASS ✓

- [ ] Queue numbers assigned at check-in (unique, sequential per clinic)
- [ ] Queue updates within 5 seconds (95% <2s per SC-003)
- [ ] No-show auto-cancel after 1 hour (±5 min per SC-012)
- [ ] Priority queue enforced (elderly/emergency wait ≤50% of general)
- [ ] Auto-calling triggered when ≤2 positions away
- [ ] Kiosk displays updated every 10 seconds (no patient names)
- [ ] Doctor workload visible in dashboard
- [ ] All US2 tests pass (≥80% coverage)
- [ ] Real-time event streaming validated

### Phases 5-11: PASS (continued per user story)

- [ ] Each story independently testable and deployable
- [ ] No regression in prior stories
- [ ] Constitution principles verified per story
- [ ] Success criteria achieved for each story

### Phase N Polish: PASS ✓ (Production Readiness)

- [ ] 82 Polish tasks complete (T195-T276)
- [ ] E2E test coverage all user journeys
- [ ] Performance targets met (<2s on 3G, SC-004)
- [ ] Security audit passed (penetration testing, data masking)
- [ ] Accessibility audit WCAG 2.1 AA passed (SC-020-SC-023)
- [ ] Disaster recovery tested (RTO ≤4hrs, RPO ≤1hr, SC-038-SC-041)
- [ ] Monitoring/alerting operational (99.5% uptime target, SC-024)
- [ ] Compliance documentation complete (HIPAA/GDPR)
- [ ] All success criteria measured and validated (SC-001-SC-045)
- [ ] Deployment checklist complete
- [ ] Production sign-off obtained

---

## Summary Statistics

| Category                           | Count | Notes                                             |
| ---------------------------------- | ----- | ------------------------------------------------- |
| **Total Tasks**                    | 276   | T001-T276, sequentially numbered                  |
| **Setup Phase**                    | 9     | T001-T009                                         |
| **Foundational Phase**             | 78    | T010-T087 (BLOCKING all stories)                  |
| **User Story 1 (Booking)**         | 29    | T088-T116 (P1, MVP)                               |
| **User Story 2 (Queue)**           | 37    | T117-T153 (P1, Hospital Workflow)                 |
| **User Story 3 (QR)**              | 18    | T154-T171 (P1, Secure Check-in)                   |
| **User Story 4 (Notifications)**   | 16    | T172-T187 (P2)                                    |
| **User Story 5 (Medical Records)** | 13    | T188-T200 (P2)                                    |
| **User Story 6 (Wait Time)**       | 12    | T201-T212 (P2)                                    |
| **User Story 7 (Voice)**           | 7     | T213-T219 (P3)                                    |
| **User Story 8 (Offline Sync)**    | 12    | T220-T231 (P3)                                    |
| **User Story 9 (Waitlist)**        | 10    | T232-T241 (P3)                                    |
| **Polish Phase**                   | 82    | T242-T276 (Production hardening)                  |
|                                    |       |                                                   |
| **Test Tasks**                     | 98    | Across all phases (TDD: RED → GREEN → REFACTOR)   |
| **Implementation Tasks**           | 136   | Domain, service, persistence, presentation layers |
| **Integration Tasks**              | 24    | E2E testing, smoke tests, deployment validation   |
| **[P] Parallelizable**             | 87    | Can distribute across teams safely                |

---

## Enhanced Production Coverage

### Hospital Workflow ✓

- Queue numbers with department codes (SC-014-SC-018)
- Priority queue (elderly/emergency prioritized)
- Auto-calling notifications
- Post-consultation stage tracking
- Real-time kiosk displays

### Appointment Lifecycle ✓

- 8-state machine (Pending-Booking through Completed/Cancelled/No-Show)
- Immutable state transition audit logging
- Sub-stage tracking (Test → Results → Payment → Prescription)
- State validation preventing backwards transitions

### Reliability & Idempotency ✓

- Booking idempotency (no duplicates on retry)
- Payment idempotency (no double-charges)
- Transaction atomicity (booking + payment together or not at all)
- Exponential backoff retries (max 3, configurable)
- Consistency verification utilities

### Compliance & Security ✓

- Immutable audit logs (FR-046-FR-050, SC-034-SC-036)
- Patient-visible audit trails (FR-048)
- HIPAA/GDPR retention policies (7+ years medical records, 3+ years logs)
- AES-256 encryption at-rest, TLS 1.3 in-transit
- Role-based access control (RBAC) enforced

### Accessibility Excellence ✓

- Large fonts (18pt-24pt, FR-070, SC-020)
- High contrast (WCAG 2.1 AA, FR-071, SC-022)
- Voice-first navigation (FR-072, SC-019-SC-021)
- One-tap operations (FR-073, SC-021)
- Icon-first UI (48x48dp, FR-074)
- Simplified elderly interface (FR-075)

### Disaster Recovery ✓

- Daily encrypted backups to separate region
- RTO ≤ 4 hours, RPO ≤ 1 hour (SC-038-SC-041)
- Automatic failover to standby infrastructure (within 15 min)
- Graceful degradation (core services operational if notifications fail)
- Comprehensive runbooks and MTTR tracking

### Monitoring & Operations ✓

- Structured JSON logging for all operations (FR-146)
- Real-time operational dashboards (bookings/min, payment rates, queue depth, error rates)
- Critical alerting (>1% failure, payment timeout, provider down)
- On-call escalation (15-min escalation window)
- SLA tracking (99.5% uptime target)

### Cost Optimization ✓

- Database caching (5-min TTL for clinic info, schedules)
- Query optimization (O(log n) complexity via indexes)
- Polling optimization (30-60s for non-critical, WebSocket for critical)
- Batch notifications (70-90% reduction via grouping)
- Kiosk display delta updates (10-second summary)
- Serverless infrastructure (pay-per-invocation)

---

## Notes

- **Checkboxes**: Track progress by unchecking completed tasks
- **Task IDs**: Sequential T001-T276; never reuse IDs for traceability
- **[P] marker**: Indicates parallelizable tasks; assign to different developers independently
- **[US#] label**: User story reference (US1-US10); required for story-phase tasks only
- **File paths**: Exact locations provided; use as implementation checklist
- **Phase Checkpoints**: Validate each phase before advancing (CRITICAL before user stories)
- **Testing Mandatory**: Constitution Principle III enforced; all code TDD-tested before merge
- **Enhanced Spec Alignment**: Tasks reflect 12 enhancement areas (hospital workflow, queue system, lifecycle states, audit compliance, reliability, accessibility, cost optimization, DR, monitoring)
- **Success Criteria Coverage**: 45 measurable criteria (SC-001 to SC-045) tracked and validated
- **Production Readiness**: Phase N includes disaster recovery, monitoring, accessibility, and compliance validation
- **Team Structure**: Recommended 10+ person team with parallel workstreams per Phase 2 plan above
- **Timeline**: Estimated 24 weeks from start to go-live with full parallel team structure
