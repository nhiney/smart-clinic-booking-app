# Feature Specification: ICare Smart Clinic Booking System

**Feature Branch**: `001-clinic-booking-system`
**Created**: 2026-04-07
**Status**: Draft
**Input**: Production-ready smart healthcare system with appointment booking, queue management, medical records, and accessibility for elderly/rural users

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Patient Books an Appointment (Priority: P1)

Patient (elderly, using mobile device) opens ICare app, searches for a clinic/department, selects a time slot, makes payment, receives booking confirmation with QR code, and arrives at clinic for check-in.

**Why this priority**: Booking is the core feature; all other functionality depends on it. Without this, the system has no value.

**Independent Test**: Can be fully tested by: opening app → searching clinic → selecting time slot → completing payment → receiving booking confirmation. Delivers core value of enabling clinic access.

**Acceptance Scenarios**:

1. **Given** Patient is logged in and on clinic selection screen, **When** Patient searches for "Clinic A - Cardiology", **Then** System returns matching clinics with available time slots and department info
2. **Given** Patient has selected a time slot, **When** Patient proceeds to payment with VNPay, **Then** System processes payment and creates booking atomically (no charge without booking, no booking without charge)
3. **Given** Patient has completed payment, **When** Booking is confirmed, **Then** System generates unique QR code and sends booking details via SMS and app notification
4. **Given** Patient has existing booking, **When** Patient taps "View Booking", **Then** System displays appointment time, QR code, clinic location, estimated wait time, and cancel/reschedule options

---

### User Story 2 - Doctor/Admin Manages Queue and Appointments (Priority: P1)

Doctor/Admin logs into dashboard, views real-time queue with patient names and estimated consultation time, marks patients as checked-in or completed, and system automatically updates queue and next patient.

**Why this priority**: Queue management is essential for clinic operations; without it, doctors don't know who's next and can't efficiently serve patients.

**Independent Test**: Can be fully tested by: logging in as Doctor → viewing queue → checking patient in → marking consultation complete → verifying queue updated. Delivers independent value of operational efficiency.

**Acceptance Scenarios**:

1. **Given** Doctor is on queue dashboard, **When** System loads, **Then** Patient list displays with check-in status, consultation duration estimate, and priority level
2. **Given** Patient has scanned QR at check-in, **When** QR is valid and not already checked-in, **Then** System marks patient as checked-in and adds to active queue
3. **Given** Doctor completes patient consultation, **When** Doctor taps "Complete Consultation", **Then** System moves patient to post-consultation (test/result/payment) and displays next patient
4. **Given** No-show patient's appointment time expired, **When** Doctor has not marked them checked-in after 30 minutes, **Then** System auto-cancels appointment and notifies patient

---

### User Story 3 - Patient Receives Secure QR-Based Check-In (Priority: P1)

Patient arrives at clinic, scans QR code displayed at check-in kiosk or shows QR in app to staff, system validates token (time-limited, one-time use), marks patient checked-in, and patient is added to queue.

**Why this priority**: QR check-in is critical for security, fraud prevention, and workflow tracking; it ensures only booked patients can check in.

**Independent Test**: Can be fully tested by: generating booking QR → validating QR at check-in → verifying patient marked in queue. Delivers independent value of secure check-in.

**Acceptance Scenarios**:

1. **Given** Patient has valid booking, **When** QR code is generated, **Then** QR is time-limited (valid for 2 hours before appointment to 5 minutes after), one-time use only, and encrypted
2. **Given** Patient scans QR at clinic, **When** QR is within validity window and booking exists, **Then** System marks patient checked-in, removes QR from circulation, and adds to queue
3. **Given** Patient scans QR outside validity window, **When** QR is expired or already used, **Then** System rejects scan and notifies staff to verify patient identity manually
4. **Given** Booking is cancelled, **When** System cancels appointment, **Then** QR code is invalidated immediately and cannot be reused

---

### User Story 4 - Patient Receives Multi-Channel Notifications (Priority: P2)

System sends booking confirmations, appointment reminders (24h before), queue position updates, and results via SMS, push notification, and email based on patient preference.

**Why this priority**: Essential for user engagement and reducing no-shows; increases trust in system. Secondary to core booking/queue but critical for UX.

**Independent Test**: Can be fully tested by: creating booking → verifying SMS/email sent → receiving push notification. Delivers independent value of keeping users informed.

**Acceptance Scenarios**:

1. **Given** Booking is confirmed, **When** System completes booking transaction, **Then** System sends SMS + email + push with booking details (clinic, time, QR code)
2. **Given** Appointment is 24 hours away, **When** Scheduled reminder time arrives, **Then** System sends SMS reminder (for elderly/rural accessibility)
3. **Given** Patient completes consultation, **When** Results/prescription are ready, **Then** System sends notification and patient can view in app
4. **Given** Patient has notification settings in profile, **When** System sends message, **Then** System respects preferences (e.g., SMS only for elderly users, no emails for offline-first users)

---

### User Story 5 - Patient Views Medical Records Securely (Priority: P2)

Patient logs in to app, views past appointments, consultation notes (if doctor shared), test results, prescriptions, and allergies/medical history in a secure, encrypted format with audit trail.

**Why this priority**: Essential for healthcare quality and patient empowerment; enables continuity of care. Secondary to booking but required for medical record system.

**Independent Test**: Can be fully tested by: logging in → viewing past appointment → verifying encryption in transit/rest → checking audit log. Delivers independent value of secure record access.

**Acceptance Scenarios**:

1. **Given** Patient is logged in, **When** Patient navigates to "Medical Records", **Then** System displays past appointments, consultation notes (if shared by doctor), test results, and prescriptions
2. **Given** Patient views sensitive data (allergies, diagnoses), **When** System retrieves record, **Then** Data is encrypted at rest (AES-256), in transit (TLS 1.3), and accessed via secure session only
3. **Given** Doctor updates patient record, **When** Update occurs, **Then** System logs who (doctor ID), what (field changed), when (timestamp), and this audit log is immutable and available to patient
4. **Given** Patient's role is "Elderly" (low tech), **When** Patient accesses medical records, **Then** Records display in large font (18pt+), high contrast (WCAG AA), with option to listen via voice

---

### User Story 6 - Real-Time Queue Shows Estimated Wait Time (Priority: P2)

Patient checks app or kiosk display, sees real-time queue position, estimated wait time based on doctor's consultation speed and current queue, and receives updates as queue moves.

**Why this priority**: Improves patient experience and reduces anxiety; enables better clinic operations. Secondary but valuable.

**Independent Test**: Can be fully tested by: checking in patient → viewing queue dashboard → verifying estimated time → completing consultation → seeing queue update. Delivers independent value of visibility.

**Acceptance Scenarios**:

1. **Given** Patient is checked-in, **When** Patient views queue status on app, **Then** System displays queue position, estimated wait time (calculated from avg consultation time × patients ahead)
2. **Given** Queue updates (patient completed, new patient added), **When** System recalculates, **Then** Patient receives push update with new estimated time every 5 minutes or when their position changes by ≥5 min
3. **Given** Estimated wait time changes materially, **When** Wait time increases by >30 minutes (e.g., doctor running behind), **Then** System alerts patient and offers to reschedule or go offline
4. **Given** Kiosk display is showing queue, **When** System updates queue, **Then** Display refreshes every 10 seconds; patient can see queue visually without logging in (privacy-preserving: shows position numbers, not names)

---

### User Story 7 - AI Voice Assistant Helps Booking and Symptom Triage (Priority: P3)

Elderly/rural patient (who may not use app interface) calls voice number, speaks appointment request or symptoms, AI assistant guides through booking, triage questions, and confirms details. System book appointment and sends SMS confirmation.

**Why this priority**: Dramatically improves accessibility for elderly and low-tech rural users; addon that can run parallel to app-based booking. Advanced feature but essential for inclusion.

**Independent Test**: Can be fully tested by: calling voice line → speaking request → AI booking appointment → verifying SMS sent. Delivers independent value of voice accessibility.

**Acceptance Scenarios**:

1. **Given** Patient calls voice line, **When** AI answers, **Then** AI greets in patient's language and asks "What would you like to do? Press 1 for booking, 2 for symptoms, 3 to hear results"
2. **Given** Patient selects booking, **When** AI guides through clinic/department/time selection, **Then** AI confirms availability, processes payment (voice confirmation of MoMo/VNPay OTP), and books appointment
3. **Given** Patient reports symptoms (e.g., "fever and cough"), **When** AI asks triage questions, **Then** AI recommends department (e.g., "I suggest Respiratory/Pulmonology") and offers to book
4. **Given** Booking is confirmed via voice, **When** AI ends call, **Then** System sends SMS with booking details including QR code (as QR link or printed at clinic)

---

### User Story 8 - Offline-First Mobile with Automatic Sync (Priority: P3)

Patient uses app offline (no internet), can view bookings, past appointments, and prescriptions locally; when connectivity returns, app automatically syncs any local changes with server without data loss.

**Why this priority**: Essential for rural areas with spotty connectivity; enables continuous access. Advanced but valuable for target demographic.

**Independent Test**: Can be fully tested by: enabling offline mode → viewing bookings → reconnecting → verifying sync completed. Delivers independent value of offline resilience.

**Acceptance Scenarios**:

1. **Given** App is offline, **When** Patient opens app, **Then** Patient can view cached bookings, past appointments, and prescriptions without internet
2. **Given** Patient is offline and reschedule is attempted, **When** Patient taps "Reschedule", **Then** App shows local change pending sync (UI indicates "Pending sync") and stores change locally
3. **Given** Network connectivity returns, **When** App detects connectivity, **Then** App automatically syncs pending changes; if conflict (e.g., doctor cancelled while patient offline), app shows both versions and asks user to choose
4. **Given** Sync fails (e.g., Wi-Fi lost mid-sync), **When** Sync is interrupted, **Then** App retries every 30 seconds with exponential backoff; user can manually retry or continue offline

---

### User Story 9 - Waitlist, Reschedule, and No-Show Handling (Priority: P3)

Patient on waitlist receives automatic notification when slot opens. Patient can reschedule appointment (system checks availability, blocks double-booking). System tracks no-shows and auto-cancels unpaid bookings after 1 hour of no-show to free slot.

**Why this priority**: Improves clinic utilization and fairness; manages realistic scenarios. Advanced but operational necessity.

**Independent Test**: Can be fully tested by: patient joining waitlist → slot opening → booking created → rescheduling → no-show auto-cancel. Delivers independent value of intelligent scheduling.

**Acceptance Scenarios**:

1. **Given** Patient requests appointment but no slots available, **When** Patient joins waitlist, **Then** System stores patient in queue, sends SMS confirmation, and notifies if slot opens
2. **Given** Doctor cancels appointment, **When** Slot becomes available, **Then** System offers slot to oldest waitlist patient via SMS + app notification; patient has 1 hour to accept or slot goes to next patient
3. **Given** Patient has booking and wants to reschedule, **When** Patient selects new time, **Then** System checks availability (prevents double-booking), processes refund if needed, and updates booking atomically
4. **Given** Patient doesn't check-in by 1 hour after appointment time, **When** No-show timeout expires, **Then** System auto-cancels unpaid booking, frees slot, and notifies patient of cancellation via SMS

---

### User Story 10 - Real-World Hospital Workflow with Queue Numbers and Waiting (Priority: P1)

Patient arrives at clinic with booking, receives unique queue number at check-in, waits in designated queue, monitor displays real-time queue progress, system auto-calls patients to consultation room via notification/voice, doctor completes consultation, then patient proceeds through test/imaging/follow-up/payment/prescription stages based on clinical protocols.

**Why this priority**: Reflects actual hospital operations; critical for operational efficiency and patient experience. Queue numbers provide transparency and reduce confusion; auto-calling ensures workflow continuity.

**Independent Test**: Can be fully tested by: checking in → receiving queue number → queue display updated → auto-called to consultation → completing consultation → proceeding to next stage. Delivers independent value of operational workflow management.

**Acceptance Scenarios**:

1. **Given** Patient checks in successfully, **When** QR is validated, **Then** System assigns unique queue number (e.g., "K-45"), displays number to patient, and shows on clinic kiosk displays
2. **Given** Patient is waiting with queue number, **When** Queue position changes, **Then** System displays new position on kiosk/app every 10 seconds; elder patients receive visual + audible notifications
3. **Given** Consultation is ready for next patient, **When** Doctor signals ready, **Then** System auto-calls patient by queue number via push notification and SMS; for elderly/offline patients, staff calls by queue number
4. **Given** Patient enters consultation room, **When** Doctor marks consultation started, **Then** System updates queue status and displays next patient's queue number on kiosk
5. **Given** Consultation is complete, **When** Doctor marks completion, **Then** System moves patient to post-consultation stage (test/imaging/follow-up) based on clinic protocol and displays expected next steps
6. **Given** Patient is in post-consultation stage, **When** Results become available, **Then** System notifies patient to proceed to payment/prescription collection; staff can also manually call via queue number
7. **Given** Multiple doctors are working, **When** Patient's queue number is called, **Then** System displays which consultation room/stage (e.g., "Room 3 - Consultation", "Lab A - Blood Test") to guide patient

---

### Edge Cases

- **Double booking**: What happens if patient books while simultaneously checking-in via QR? → System uses database transaction to ensure only one succeeds
- **Payment failure mid-flow**: If payment fails after booking is created, what happens? → System rolls back booking and notifies patient
- **Network partition during sync**: If sync partially completes (e.g., uploads data but can't download confirmation), what happens? → App marks as "sync uncertain" and retries on next connectivity
- **QR expiry before arrival**: Patient has booking but QR expires before appointment time (e.g., 2-hour window), what happens? → System regenerates QR on demand when patient taps "Check-in" in app
- **Timezone ambiguity**: Patient books in different timezone, appointment shows wrong time, what happens? → App displays both clinic timezone and patient's local time; SMS uses clinic timezone
- **Language barrier**: Elderly patient doesn't speak system language, what happens? → App defaults to device language; voice assistant supports regional languages (Vietnamese, English, Khmer for Southeast Asia)
- **Queue collision**: Two patients called simultaneously while doctor is between consultations, what happens? → System queues notifications sequentially; staff receives alert to prioritize one patient
- **No-show recovery**: Patient no-shows from waiting queue; when do they get opportunity to check in? → System keeps appointment state "checked-in pending" for 30 min; patient can still check in via QR within this window or staff can manually check in
- **Doctor goes offline**: Doctor's queue dashboard connection drops mid-consultation, what happens? → Last known queue state persists; doctor can resume from app; any pending status changes are queued and applied when reconnected
- **Appointment lifecycle break**: Consultation complete but patient refuses test/payment stages, what happens? → System pauses entire appointment in "post-consultation hold" state; staff must either proceed or cancel; appointment doesn't auto-complete
- **Audit log tampering attempt**: Someone tries to delete or modify audit log, what happens? → System rejects changes and logs tamper attempt; immutable copy verified; incident escalated to admin
- **Queue number collision**: System assigns same queue number to two different patients, what happens? → System uses UUID + timestamp as secondary key; prevents duplicate display; if occurs, audit log captures incident and system fixes automatically

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: System MUST allow patients to search and browse clinics, departments, and available appointment slots in real-time
- **FR-002**: System MUST validate booking and prevent double-booking (same patient, same time, same doctor MUST NOT be allowed)
- **FR-003**: System MUST process payments (VNPay, MoMo, Stripe) atomically (charge succeeds if and only if booking succeeds)
- **FR-004**: System MUST generate time-limited (2-hour validity), one-time-use QR codes for secure check-in
- **FR-005**: System MUST track check-in status and update queue position in real-time
- **FR-006**: System MUST calculate estimated wait time for each patient based on doctor's historical consultation duration and current queue
- **FR-007**: System MUST send notifications via SMS, email, and push notification based on patient preference
- **FR-008**: System MUST store and display medical records (appointments, notes, test results, prescriptions) with encryption
- **FR-009**: System MUST maintain immutable audit logs for all data access and modifications (who, what, when)
- **FR-010**: System MUST enforce role-based access control (RBAC) where Patient sees only own data, Doctor sees own patients, Admin sees clinic data
- **FR-011**: System MUST support multi-hospital and multi-department organization with department-specific doctors and schedules
- **FR-012**: System MUST handle appointment lifecycle: booking → payment → check-in → queue → consultation → test → result → payment (if needed) → prescription
- **FR-013**: System MUST auto-cancel unpaid bookings 1 hour after no-show to free clinic slots
- **FR-014**: System MUST offer waitlist feature when slots are full; notify patient and book automatically if slot opens
- **FR-015**: System MUST support offline-first: cache critical data locally; sync when connectivity returns; handle conflicts via last-write-wins or user choice
- **FR-016**: System MUST retry failed API calls with exponential backoff (max 3 retries, configurable)
- **FR-017**: System MUST achieve data consistency: strong consistency for bookings (no duplicates), eventual consistency for queue positions (acceptable to be seconds stale)
- **FR-018**: System MUST use event-driven architecture: emit domain events (BookingCreated, PaymentProcessed, CheckedIn, ConsultationCompleted) for pub/sub integration

- **FR-019**: System MUST support multi-language interface: Vietnamese (primary), English, Chinese (Simplified), French with medical terminology verified by healthcare professionals
- **FR-020**: System MUST provide support ticket system: patients can submit issues (e.g., payment failed, lost booking) and receive status updates via SMS/email
- **FR-021**: System MUST implement doctor workload balancing: admin can view doctor utilization and manually reassign patients to less-busy doctors if needed; algorithmic auto-balancing deferred to v2
- **FR-022**: System MUST handle partial payments: support split payment patterns (e.g., 50% advance during booking, 50% after consultation) with clear balance-due indicators
- **FR-023**: System MUST include backup and disaster recovery: daily encrypted backups to separate geographic region; RTO ≤ 4 hours, RPO ≤ 1 hour
- **FR-024**: System MUST provide monitoring and alerting: structured JSON logs for all operations; dashboards tracking bookings/minute, payment success rate, queue depth, error rates; alerts on >1% failure rate

### Queue Management System Requirements

- **FR-025**: System MUST assign unique queue number to each checked-in patient within 5 seconds of successful check-in (format: department-code + sequential number, e.g., "K-045" for Cardiology)
- **FR-026**: System MUST maintain real-time queue state including: queue number, patient name, check-in time, estimated consultation start time, current position, priority level (normal/elderly/emergency)
- **FR-027**: System MUST automatically calculate and update priority queue order: emergency patients first, elderly patients (60+) second, general patients third; within same priority, FIFO (first checked-in, first served)
- **FR-028**: System MUST update queue displays (app, kiosk, staff dashboard) every 10 seconds or immediately when patient's position changes by ≥2 positions
- **FR-029**: System MUST send auto-call notification when patient is ≤2 positions from consultation: push notification + SMS for primary, voice call or staff manual call for patients preferring voice
- **FR-030**: System MUST display privacy-safe kiosk displays showing: current queue number being called, next 3 queue numbers waiting, average wait time per doctor, no patient names or identifiable data
- **FR-031**: System MUST support multiple concurrent queue tracking: separate queues per doctor, per department, per clinic; real-time aggregation of clinic-wide queue state

### Appointment Lifecycle and Status Requirements

- **FR-032**: System MUST enforce strict appointment state machine with valid transitions only: Pending-Booking → Booked → Confirmed → Checked-in → In-Queue → In-Consultation → Post-Consultation (Test/Result/Payment) → Completed OR Cancelled (at any stage) OR No-Show (if expired without check-in)
- **FR-033**: System MUST track timestamp and reason for every appointment status transition; immutable record for audit trail
- **FR-034**: System MUST prevent backwards state transitions (e.g., cannot transition from Completed back to Checked-in); state corrections require admin action with audit logging
- **FR-035**: System MUST manage post-consultation workflow: after consultation marks complete, appointment transitions to "Post-Consultation" with sub-stages (Test/Imaging → Results Review → Payment → Prescription) based on doctor's prescription; each sub-stage has independent tracking

### No-Show Detection and Handling

- **FR-036**: System MUST detect no-show automatically: if patient not checked-in by appointment time + 30 minutes grace period, mark as "No-Show-Pending"; notify patient of impending auto-cancel
- **FR-037**: System MUST auto-cancel unpaid bookings 1 hour after no-show detection; immediately notify patient and free clinic slot for rebooking
- **FR-038**: System MUST track no-show history per patient: count of no-shows, dates, clinics; display warning when patient books (e.g., "You have 2 previous no-shows")
- **FR-039**: System MUST allow admin to set no-show penalties: after N no-shows (configurable, default 3), require advance payment or limit rebooking within same clinic
- **FR-040**: System MUST provide no-show recovery: if patient arrives within 2 hours after no-show auto-cancel, staff can manually reinstate appointment or offer same-day walk-in consultation if available

### Doctor Workload and Scheduling

- **FR-041**: System MUST enforce doctor maximum patients per day: admin sets max capacity (e.g., 30 patients/day); booking prevented if doctor reaches max for that day
- **FR-042**: System MUST display doctor workload in real-time: admin dashboard shows each doctor's scheduled vs. checked-in vs. completed vs. in-queue for current day
- **FR-043**: System MUST support doctor break time: admin assigns break periods (e.g., 1-2 PM for lunch); no new patients can be assigned during break, queue is paused
- **FR-044**: System MUST allow admin to manually reassign waiting patients to less-busy doctors: drag-drop UI, confirmation dialog, patient receives notification of doctor change
- **FR-045**: System MUST track average consultation duration per doctor per department; use historical data to calculate estimated wait times and flag if doctor is running significantly behind schedule (>20% over average)

### Audit and Compliance Requirements

- **FR-046**: System MUST log every action with: actor (user ID + role), action (read/write/delete/modify), entity (type + ID), timestamp, reason/context, result (success/failure + error code)
- **FR-047**: System MUST make audit logs immutable: prevent deletion, modification, or export without proper authorization; tamper detection via checksums
- **FR-048**: System MUST provide patient-visible audit trail: patients can view all accesses to their medical records (who accessed what when) with configurable privacy settings
- **FR-049**: System MUST retain audit logs per compliance requirements: medical records ≥7 years, transactional logs ≥3 years, access logs ≥1 year minimum
- **FR-050**: System MUST support audit log export for compliance: generate reports for data subject access requests (DSARs), regulatory audits, incident investigation

### Reliability and Data Consistency

- **FR-051**: System MUST ensure idempotent booking operations: same booking request submitted twice with identical parameters results in single booking (no duplicates)
- **FR-052**: System MUST ensure idempotent payment operations: same payment request submitted twice results in single charge; automatic deduplication using payment request ID
- **FR-053**: System MUST implement retry logic for failed operations: transient failures (network timeout, temporary service unavailable) retry with exponential backoff (base 2s, max 32s, max 3 retries)
- **FR-054**: System MUST handle eventual consistency for queue: queue position updates may lag booking/check-in by up to 5 seconds; system converges to consistent state automatically; real-time updates optimized for user notification rather than absolute accuracy
- **FR-055**: System MUST track pending operations: if sync/retry is interrupted, system maintains queue of pending operations and resumes automatically when connectivity restored
- **FR-056**: System MUST implement conflict resolution for offline sync: if same data modified offline and on server, system uses last-write-wins strategy for transactional data (appointments), or presents user choice for non-transactional data (medical notes)

### Disaster Recovery and Business Continuity

- **FR-057**: System MUST perform encrypted daily backups to geographically separate region: all data (bookings, medical records, payment history, audit logs) backed up daily; backup verified for integrity
- **FR-058**: System MUST achieve Recovery Time Objective (RTO) ≤ 4 hours: full system restoration from backup within 4 hours of disaster declaration
- **FR-059**: System MUST achieve Recovery Point Objective (RPO) ≤ 1 hour: data loss window limited to 1 hour of operations; incremental backups every 15 minutes
- **FR-060**: System MUST maintain standby infrastructure: read-only replicas in separate regions for failover; automatic failover triggered if primary region unavailable
- **FR-061**: System MUST support graceful degradation: if non-critical services fail (notifications, analytics), core services (booking, queue, check-in) remain operational
- **FR-062**: System MUST provide disaster recovery playbooks: documented procedures for common failure scenarios (database corruption, payment processor down, SMS provider down) with runbooks for recovery

### Monitoring and Operations

- **FR-063**: System MUST emit structured JSON logs for all operations: every booking, payment, check-in, notification includes context (user, clinic, appointment, error details)
- **FR-064**: System MUST track operational metrics: bookings per minute, payment success rate, queue depth per clinic, average wait time, error rates per operation
- **FR-065**: System MUST generate dashboards for operations team: real-time view of system health, queue status per clinic, payment/notification delivery rates, error trends
- **FR-066**: System MUST alert on critical thresholds: >1% operation failure rate, payment processor unavailable, SMS provider down, queue backlog >50 patients, average wait time >2 hours
- **FR-067**: System MUST track SLA metrics: 99.5% uptime for booking/payment/queue operations, <5s queue update latency, <2 min SMS delivery
- **FR-068**: System MUST provide detailed error tracking: every error logged with stack trace, user impact, severity level, automatic grouping of similar errors for trend analysis
- **FR-069**: System MUST support on-call escalation: alerts automatically escalate if not acknowledged within 15 minutes; escalation policy configurable per service/clinic

### Accessibility Enhancements

- **FR-070**: System MUST support large font mode: option to increase all UI text to 18pt, 20pt, 24pt; persistent setting saved in user profile
- **FR-071**: System MUST support high contrast mode: WCAG 2.1 AA compliant color themes; dark mode with high luminance contrast (≥4.5:1 for text)
- **FR-072**: System MUST provide voice-first navigation for elderly users: option to navigate entire app via voice commands and voice responses; screen reader compatible
- **FR-073**: System MUST support one-tap/one-click operations where possible: minimize multi-step flows; provide shortcut buttons for common actions (book appointment, check status, reschedule)
- **FR-074**: System MUST use icon-first UI design: primary actions use large, universally understood icons (phone, calendar, medical cross) supplemented with text; icons tested with target demographic
- **FR-075**: System MUST simplify elderly user interface: different UI theme for elderly users with: larger buttons (min 48x48dp), minimal color palette, simpler language (short sentences, common words), guided workflows with confirmation at each step
- **FR-076**: System MUST provide accessible offline mode: offline version of app optimized for elderly users; supports viewing bookings, medical records, prescriptions; sync simplified when connectivity returns
- **FR-077**: System MUST support multiple input methods: touch, voice, physical buttons; accommodate users with limited dexterity or motor control

### Cost Optimization

- **FR-078**: System MUST optimize database reads: cache frequently accessed data (clinic info, doctor schedules, availability slots) with 5-minute TTL; invalidate cache on data changes
- **FR-079**: System MUST minimize real-time listeners: use polling for non-critical updates (every 30-60s) instead of continuous WebSocket connections to reduce server load and bandwidth
- **FR-080**: System MUST batch notification delivery: group SMS/email notifications sent within 30-second window to same recipient to reduce API call volume
- **FR-081**: System MUST implement efficient queue state distribution: summary queue state pushed to kiosk displays every 10 seconds instead of per-patient updates; reduces network traffic

### Key Entities _(include if feature involves data)_

- **Patient**: User booking appointments; attributes: ID, phone, email, name, language preference, accessibility settings (large font, voice), allergies, medical history, no-show count, preferred contact method
- **Clinic**: Healthcare facility; attributes: ID, name, address, phone, hours, multi-department support, max patient capacity per day, kiosk display settings
- **Department**: Specialized clinical unit (Cardiology, Respiratory, etc.); attributes: ID, clinic-ID, name, description, average consultation duration, priority handling (emergency/elderly)
- **Doctor**: Clinic staff; attributes: ID, name, clinic-ID, department-ID, schedule (availability), avg consultation time per department, max patients per day, credentials, break times, workload status
- **Appointment**: Booking record; attributes: ID, patient-ID, doctor-ID, clinic-ID, time slot, status (pending/booked/confirmed/checked-in/in-queue/in-consultation/post-consultation/completed/cancelled/no-show), QR code, created-at, paid (boolean), queue number (assigned at check-in), priority level
- **Payment**: Transaction record; attributes: ID, appointment-ID, amount, currency, method (VNPay/MoMo/Stripe), status (pending/completed/failed), timestamp, payment-request-ID (for idempotency), retry count
- **MedicalRecord**: Patient health data; attributes: ID, patient-ID, appointment-ID, notes (from doctor), test results, prescription, allergies, encrypted at-rest, access timestamp (for audit trail)
- **QueuePosition**: Real-time queue state; attributes: appointment-ID, queue-number, doctor-ID, clinic-ID, position, estimated-wait-time (minutes), status (waiting/in-consultation/post-consultation/completed), auto-call notification sent (timestamp)
- **Notification**: Message sent to patient; attributes: ID, patient-ID, type (SMS/email/push/voice-call), content, status (sent/delivered/failed/retry-pending), timestamp, channel used, retry count
- **AuditLog**: Immutable record of data access/modification; attributes: ID, user-ID, action (read/write/delete/modify), entity-type, entity-ID, timestamp, reason/context, result (success/failure + error code), checksum (for tamper detection)
- **NoShowHistory**: Tracking repeated no-shows; attributes: ID, patient-ID, appointment-ID, clinic-ID, date-of-occurrence, penalty-status (none/warning/suspension/advance-payment-required)
- **DoctorWorkload**: Current workload state; attributes: doctor-ID, date, max-capacity, scheduled-count, checked-in-count, completed-count, in-consultation-count, estimated-finish-time, break-periods
- **QueueDisplay**: Configuration for kiosk displays; attributes: ID, clinic-ID, display-location (reception/waiting-room-1/lab), refresh-rate-seconds, show-next-n-numbers, language-preference

## Success Criteria _(mandatory)_

### Measurable Outcomes

#### Core Booking & Queue

- **SC-001**: Patient can complete appointment booking in under 3 minutes (from app open to payment confirmation) using mobile interface
- **SC-002**: System supports concurrent bookings of 1,000 patients without errors or data loss (strong consistency for bookings)
- **SC-003**: Real-time queue updates reflect status changes (check-in, completion) within 5 seconds; 95% of updates within 2 seconds
- **SC-004**: Mobile app loads in under 2 seconds on 3G network (< 1 Mbps); first meaningful paint under 1.5 seconds
- **SC-005**: Offline-first mobile app works without internet; core features (view bookings, medical records) remain accessible
- **SC-006**: System auto-syncs pending changes within 30 seconds of connectivity return (no data loss)
- **SC-007**: 95% of SMS/email notifications delivered within 2 minutes of event (booking, status change)
- **SC-008**: System detects and prevents double bookings 100% of the time (zero duplicate bookings in production)
- **SC-009**: QR codes are one-time use; invalid QR cannot be scanned twice (100% enforcement)

#### No-Show Handling & Prevention

- **SC-010**: Patient no-show rate decreases by 30% compared to baseline (post-SMS reminder implementation)
- **SC-011**: No-show auto-detection accuracy ≥99%: system correctly identifies no-show patients within 30-minute grace period, false positives <1%
- **SC-012**: Unpaid booking auto-cancellation executes within 60 ± 5 minutes of no-show timeout
- **SC-013**: No-show recovery window allows patients to check in via QR within 2 hours after auto-cancel; 80% recovery rate for patients with legitimate delays

#### Queue Management

- **SC-014**: Queue number assignment latency ≤5 seconds from successful check-in; 99% of assignments within 5s
- **SC-015**: Queue position accuracy on kiosk displays ±1 patient at any time; 95% of displays synchronized within 10 seconds
- **SC-016**: Auto-call notification delivery ≥95% success rate for push + SMS combined; voice calls reach 90% of elderly users
- **SC-017**: Priority queue enforcement: elderly and emergency patients wait ≤50% of average wait time compared to general queue
- **SC-018**: Queue average wait time prediction accuracy: estimated wait time within ±15% of actual wait time 90% of the time

#### Voice & Accessibility

- **SC-019**: Patient can perform booking without app on voice interface (100% of voice booking requests successfully create appointments)
- **SC-020**: 90% of elderly patients (age 60+) successfully navigate app without assistance on first attempt (accessibility measure)
- **SC-021**: Voice interface call completion rate ≥85%: elderly users successfully complete booking or view appointment info without hanging up
- **SC-022**: Accessibility compliance: app meets WCAG 2.1 AA standards (verified by automated scan + manual testing with elderly users)
- **SC-023**: Large font mode adoption: ≥40% of elderly users enable large font 18pt+ within first session

#### System Reliability & Data Consistency

- **SC-024**: System uptime: 99.5% across payment, booking, and queue operations (target SLA); planned maintenance windows excluded
- **SC-025**: Zero unauthorized data access; audit logs capture 100% of data read/write operations; audit log integrity verified daily
- **SC-026**: Idempotent booking operations: duplicate booking requests with same parameters result in single booking (zero duplicates across retry scenarios)
- **SC-027**: Idempotent payment operations: duplicate payment requests result in single charge; zero double-charges across retry scenarios
- **SC-028**: Booking consistency verification: on-demand audit confirms 100% consistency between booking status in database and user-visible status
- **SC-029**: Queue consistency: queue state converges to consistent view within 5 seconds of any state change

#### Doctor Workload & Operations

- **SC-030**: Doctor workload balancing effectiveness: maximum variance in patients served between doctors ≤20% on any given day (within same department/clinic)
- **SC-031**: Doctor break time enforcement: 100% adherence to scheduled breaks; no new patients assigned during break periods
- **SC-032**: Consultation time tracking accuracy: actual vs. scheduled consultation duration variance <15% for 90% of consultations
- **SC-033**: Doctor utilization visibility: admin dashboard shows real-time workload within 10-second latency

#### Audit & Compliance

- **SC-034**: Audit log completeness: 100% of system actions logged with full context (actor, action, entity, timestamp, result)
- **SC-035**: Audit log immutability: zero successful audit log modifications/deletions; tamper attempts logged and escalated
- **SC-036**: Patient audit trail visibility: patients can view complete access history to their medical records; ≥80% of patients review audit trail monthly
- **SC-037**: Compliance data retention: medical records retained ≥7 years, audit logs ≥3 years minimum; automated enforcement of retention policies

#### Disaster Recovery

- **SC-038**: Backup integrity verification: daily backup verification confirms 100% data recoverability; test restore annually
- **SC-039**: Recovery Time Objective (RTO): full system restoration from backup within 4 hours; tested quarterly
- **SC-040**: Recovery Point Objective (RPO): data loss limited to <1 hour of operations; incremental backups verified every 15 minutes
- **SC-041**: Failover time: automatic failover to standby region within 15 minutes of primary region failure; zero booking/transaction data loss

#### Monitoring & Operations

- **SC-042**: Operational metric completeness: dashboards track 95% of relevant metrics (bookings/min, payment success rate, queue depth, error rates, SLA compliance)
- **SC-043**: Alert accuracy: >95% of alerts are actionable; false positive rate <5%
- **SC-044**: Alert response SLA: critical alerts (payment processor down, SMS provider down) detected within 2 minutes; response team engaged within 5 minutes
- **SC-045**: Error tracking effectiveness: 90% of errors grouped into categories; trends identified within 1 hour of 5+ occurrences

## Assumptions

- **Target users**: Elderly (55+) and rural patients with low technical literacy; also professionals and international users. System MUST prioritize accessibility for elderly while maintaining modernity for professionals.
- **Mobile-first**: Majority of users access via mobile app on 3G/4G networks; desktop is secondary.
- **Geographic scope**: Initially Vietnam (VNPay, MoMo, +84 phone format), expandable to other countries.
- **Clinic operations**: Standard workflow assumed: appointment → payment → check-in → queue → consultation → test/result → payment (if applicable) → prescription. Variations per clinic handled by admin config.
- **Payment**: Payments integrated via VNPay, MoMo (Vietnam), Stripe (international); assume PCI-DSS compliance delegated to payment providers (no direct card handling in app).
- **Data retention**: Medical records retained per HIPAA/GDPR (7+ years); audit logs retained for compliance (3+ years minimum).
- **Networking**: Users may have intermittent connectivity (rural areas); offline-first design essential. SMS delivery preferred for reliability (more reliable than email/push in low-connectivity areas).
- **SMS/Voice**: Use regional SMS providers (Twilio, AWS SNS) and voice providers (Twilio, VoIP services) for reliability.
- **Multi-language**: Initial support for Vietnamese and English; extensible for Khmer, Lao, Thai, Chinese in v2+
- **Infrastructure**: Cloud-ready (AWS, GCP, Azure); microservices architecture readiness (event-driven, CQRS-ready) for future scalability
- **AI voice assistant**: Defer detailed NLP requirements to v2; v1 supports basic IVR (press 1, 2, 3) and simple speech-to-text transcription
- **Doctor workload balancing**: v1 assumes manual admin assignment where admin can view doctor utilization and reassign patients; v2 implements algorithmic auto-distribution
- **Support system**: v1 provides support ticket system for issue tracking plus email/phone support; AI chatbot deferred to v2 for post-launch optimization
- **Medical standards**: HL7/FHIR compatibility planned for future EHR integration; v1 uses proprietary schema with FHIR export capability

## Cost Optimization _(optional but recommended for production scalability)_

### Database and Read/Write Optimization

- **Caching Strategy**: Frequently accessed, slow-changing data (clinic info, doctor schedules, available slots) cached with 5-minute TTL; cache invalidation triggered on data changes to maintain consistency
- **Query Optimization**: Database indexes on appointment status, patient ID, doctor ID, check-in time to ensure O(log n) lookups; avoid full table scans for queue queries
- **Connection Pooling**: Reuse database connections across requests; idle connection timeout 30 minutes to reduce connection overhead
- **Batch Operations**: Combine multiple pending operations into single database transaction where possible (e.g., bulk appointment status updates, batch notification delivery)

### Real-Time Communication Optimization

- **Polling vs. WebSocket**: Use polling for non-critical updates (UI refresh rate 30-60 seconds) instead of continuous WebSocket connections; reserve WebSocket for critical operations (queue position, doctor dashboard) to reduce server load and bandwidth
- **Summary Updates**: Queue state pushed as summary every 10 seconds instead of per-patient updates; clients subscribe to summary topic, reducing message volume
- **Delta Updates**: For queue updates, send only changed positions rather than entire queue state; typical delta is 2-3 position changes per update vs. 50+ patients in full state

### Notification Delivery Optimization

- **Batch SMS/Email**: Group notifications to same recipient within 30-second window into single message; reduces API calls to SMS/email providers by 70-90%
- **Smart Retry**: Failed notifications retry with exponential backoff; maximum retry window 24 hours; delivered as "best effort" rather than guaranteed delivery for non-critical notifications
- **Channel Prioritization**: Attempt push notification first (instant, free), fallback to SMS if no response within 5 minutes, email as final fallback; reduces SMS cost by prioritizing free channels

### Display and Distribution Optimization

- **Kiosk Display Traffic**: Summary queue state pushed every 10 seconds; reduce per-patient position updates to once per minute to minimize network traffic to kiosk devices
- **Mobile App Delta Sync**: When syncing medical records and appointment history, transfer only changed data; typical sync size <50KB vs. 500KB+ for full history
- **Image Compression**: All images (prescription photos, lab reports) compressed to 80% quality; typical file size reduced from 1-2MB to 200-400KB per image

### Infrastructure Cost Reduction

- **Auto-Scaling**: Scale servers based on booking volume; scale down after peak hours (e.g., scale up during 7-11am, scale down by 6pm); reduce idle capacity cost
- **Regional Deployment**: Deploy to region closest to majority of patients to reduce network latency and bandwidth cost
- **CDN for Static Content**: Clinic logos, imagery, medical information cached on CDN; reduce origin server bandwidth cost
- **Serverless Functions**: Use serverless (AWS Lambda, Google Cloud Functions) for sporadic workloads (error log processing, backup generation, report generation) to pay per invocation rather than idle server cost

### Monitoring and Audit Log Optimization

- **Log Sampling**: Sample audit logs for non-critical operations (read-only accesses): log 100% of writes/deletes, 10% of reads to reduce storage cost while maintaining compliance
- **Log Archival**: Move audit logs older than 30 days to cold storage (reduced-cost tier); maintain 3-year retention while reducing active storage cost
- **Metrics Aggregation**: Aggregate operational metrics at 1-minute intervals rather than per-operation granularity; store raw metrics for 24 hours, aggregated metrics for 1 year
- **Error Log Compression**: Compress error logs; group duplicate errors into single log entry with count; reduce storage by 80% for error-heavy incidents
