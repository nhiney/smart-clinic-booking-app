# ICare - Roadmap Update Theo Specs

Tai lieu nay duoc cap nhat dua tren:
- `specs/001-clinic-booking-system/spec.md`
- `specs/001-clinic-booking-system/plan.md`
- `specs/001-clinic-booking-system/tasks.md`

Muc tieu:
- Dong bo roadmap chuc nang theo spec moi
- Ap dung vao cau truc repo Flutter hien tai trong `lib/`
- Tao danh sach viec uu tien de tiep tuc code tung phan, khong ghi de cac thay doi dang co ngoai pham vi can thiet

## 1. Nguyen tac trien khai

- Clean Architecture: `presentation -> domain -> data`
- Uu tien P1 truoc: dat lich, thanh toan, QR check-in, queue workflow
- Ho tro nguoi gia va nguoi it ranh cong nghe: chu lon, contrast cao, luong thao tac ngan
- Booking va payment phai idempotent, tranh double-booking va double-charge
- Medical record, thong bao va offline sync duoc bo sung theo phase, khong chen vao core flow khi chua on dinh

## 2. Mapping spec vao repo hien tai

### Core app
- App shell va route: `lib/app/`, `lib/app/router/`
- Dependency injection: `lib/app/di/`
- Theme, localization, widgets dung chung: `lib/core/`, `lib/shared/`

### Feature modules da co
- Dat lich: `lib/features/appointment/`
- Check-in: `lib/features/checkin/`
- Thanh toan: `lib/features/payment/`
- Thong bao: `lib/features/notification/`
- Ho so benh an: `lib/features/medical_record/`
- Bac si: `lib/features/doctor/`
- Xac thuc: `lib/features/auth/`
- Man hinh vai tro quan tri / nghiep vu: `lib/features/admin/`, `lib/features/admission/`, `lib/features/invoice/`

## 3. Uu tien thuc hien

### P1 - Booking, payment, queue, QR workflow
1. Chuan hoa lifecycle lich hen:
   `pending_booking -> booked -> confirmed -> checked_in -> in_queue -> in_consultation -> post_consultation -> completed/cancelled/no_show`
2. Dong bo entity/model/repository cho appointment va payment
3. Hoan thien QR check-in co expiry, one-time use
4. Bo sung queue number va trang thai waiting/co goi vao phong
5. Ket noi thong bao xac nhan dat lich, nhac lich, goi benh nhan

### P2 - Medical records, notifications, accessibility
1. Ho so kham benh, file dinh kem, lich su toa thuoc
2. Notification settings theo kenh SMS/push/email
3. UI accessibility: chu lon, tuong phan cao, icon ro rang, copy de hieu
4. Offline-first cho du lieu quan trong

### P3 - Reliability, audit, AI support
1. Audit log va RBAC
2. Retry/backoff, connectivity sync, local cache
3. Voice assistant, AI symptom suggestion
4. FHIR/HL7 compatibility va chia se ho so

## 4. Danh sach update chuc nang theo module

### A. Appointment
Files hien co:
- `lib/features/appointment/domain/entities/appointment_entity.dart`
- `lib/features/appointment/data/models/appointment_model.dart`
- `lib/features/appointment/data/repositories/appointment_repository_impl.dart`
- `lib/features/appointment/domain/usecases/create_appointment_usecase.dart`
- `lib/features/appointment/domain/usecases/get_appointments_usecase.dart`
- `lib/features/appointment/domain/usecases/cancel_appointment_usecase.dart`
- `lib/features/appointment/presentation/controllers/appointment_controller.dart`
- `lib/features/appointment/presentation/screens/booking_screen.dart`
- `lib/features/appointment/presentation/screens/appointment_history_screen.dart`

Can update:
- Them day du appointment status theo spec
- Them `queueNumber`, `estimatedWaitTime`, `checkInToken`, `paymentStatus`, `priorityLevel`
- Validate tranh trung lich cung benh nhan, cung bac si, cung timeslot
- Ho tro doi lich, huy lich, auto-cancel no-show
- Luu audit metadata cho moi transition

### B. Payment
Files hien co:
- `lib/features/payment/data/repositories/payment_repository_impl.dart`
- `lib/features/payment/data/repositories/payment_service.dart`
- `lib/features/payment/domain/entities/transaction_entity.dart`
- `lib/features/payment/presentation/controllers/payment_controller.dart`
- `lib/features/payment/presentation/screens/payment_screen.dart`
- `lib/features/payment/presentation/screens/payment_processing_screen.dart`
- `lib/features/payment/presentation/screens/payment_result_screen.dart`
- `lib/features/payment/presentation/screens/transaction_screen.dart`

Can update:
- Ho tro workflow idempotent cho VNPay, MoMo, Stripe
- Tach ro `pending/success/failed/refunded`
- Gan transaction voi appointment lifecycle
- Neu payment fail thi rollback booking hoac dua ve trang thai cho xu ly lai

### C. Check-in va Queue
Files hien co:
- `lib/features/checkin/presentation/controllers/checkin_controller.dart`
- `lib/features/checkin/presentation/screens/checkin_screen.dart`

Can update:
- Tao QR validation flow co han su dung
- Dan queue number theo format nghiep vu, vi du `K-045`
- Cap nhat check-in sang `checked_in` va dua vao queue
- Hien estimated wait time, room, next action
- Chuan bi duong dan de doctor/admin goi benh nhan tiep theo

### D. Notifications
Files hien co:
- `lib/features/notification/data/datasources/notification_remote_datasource.dart`
- `lib/features/notification/data/repositories/notification_repository_impl.dart`
- `lib/features/notification/domain/entities/notification_entity.dart`
- `lib/features/notification/presentation/controllers/notification_controller.dart`
- `lib/features/notification/presentation/screens/notification_screen.dart`
- `lib/features/notification/presentation/screens/reminder_settings_screen.dart`

Can update:
- Xac nhan dat lich sau payment thanh cong
- Nhac lich truoc 24h
- Thong bao check-in, thay doi queue, ket qua kham, toa thuoc
- Ton trong cau hinh kenh thong bao cua benh nhan

### E. Medical Record
Files hien co:
- `lib/features/medical_record/data/datasources/medical_record_local_datasource.dart`
- `lib/features/medical_record/data/datasources/medical_record_remote_datasource.dart`
- `lib/features/medical_record/data/repositories/medical_record_repository_impl.dart`
- `lib/features/medical_record/domain/entities/medical_record.dart`
- `lib/features/medical_record/domain/entities/attachment.dart`
- `lib/features/medical_record/domain/usecases/get_medical_records_usecase.dart`
- `lib/features/medical_record/domain/usecases/upload_medical_attachment_usecase.dart`
- `lib/features/medical_record/presentation/bloc/medical_record_bloc.dart`
- `lib/features/medical_record/presentation/screens/medical_record_screen.dart`
- `lib/features/medical_record/presentation/screens/medical_record_list_screen.dart`
- `lib/features/medical_record/presentation/screens/medical_record_detail_screen.dart`

Can update:
- Gom lich su kham, ket qua can lam sang, toa thuoc, di ung, ghi chu bac si
- Upload PDF, hinh X-ray, MRI, toa thuoc
- Co local cache va dong bo lai khi online
- Chuan bi metadata de audit va chia se co kiem soat

### F. Doctor/Admin workflow
Files hien co:
- `lib/features/doctor/`
- `lib/features/admin/`
- `lib/features/admission/`
- `lib/features/invoice/`

Can update:
- Queue dashboard cho doctor/admin
- Mark `consultation_started`, `consultation_completed`, `post_consultation`
- Dieu phoi room/stage sau kham: xet nghiem, thanh toan, lay thuoc
- Xu ly benh nhan uu tien: cap cuu, nguoi gia

## 5. Backlog theo thu tu nen lam ngay

### Phase 1 - Chuan hoa model va state
- [ ] Update `appointment_entity.dart` theo lifecycle 8 trang thai
- [ ] Update `appointment_model.dart` va mapping data
- [ ] Update `transaction_entity.dart` de gan idempotency key
- [ ] Ra soat `booking_screen.dart`, `payment_screen.dart`, `checkin_screen.dart` theo state moi

### Phase 2 - Core booking flow
- [ ] Hoan thien `create_appointment_usecase.dart`
- [ ] Bo sung validate slot conflict trong `appointment_repository_impl.dart`
- [ ] Cap nhat `payment_repository_impl.dart` va `payment_service.dart`
- [ ] Neu payment thanh cong thi set appointment `confirmed`
- [ ] Neu payment loi thi thong bao ro rang va cho retry an toan

### Phase 3 - QR + Queue
- [ ] Tao/check lai token QR trong flow check-in
- [ ] Them queue number vao appointment
- [ ] Tinh estimated wait time
- [ ] Hien thong tin phong kham va thu tu cho tren UI

### Phase 4 - Notifications
- [ ] Gui thong bao booking success
- [ ] Gui reminder truoc lich
- [ ] Gui thong bao khi den luot kham
- [ ] Dong bo setting thong bao cua nguoi dung

### Phase 5 - Medical records
- [ ] Chuan hoa entity `medical_record.dart`
- [ ] Hoan thien list/detail/upload attachment
- [ ] Local cache voi `medical_record_local_datasource.dart`
- [ ] Them cac truong phuc vu audit va chia se

### Phase 6 - Reliability va security
- [ ] Bo sung retry/backoff trong datasource network
- [ ] Them offline sync cho du lieu quan trong
- [ ] Bo sung RBAC theo role patient/doctor/admin
- [ ] Chuan bi audit log cho thao tac nhay cam

## 6. Lenh nen dung khi update

### Dong bo dependency va codegen
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Kiem tra format va loi co ban
```bash
dart format lib test
flutter analyze
```

### Chay test theo dot
```bash
flutter test
flutter test test/features/appointment
flutter test test/features/medical_record
```

### Truoc khi sua module lon
```bash
git status --short
rg "AppointmentStatus|paymentStatus|queueNumber" lib
```

## 7. Cach lam an toan trong repo dang co thay doi

- Khong revert cac file khong nam trong pham vi task dang lam
- Moi dot update nen bam theo module nho: `appointment`, `payment`, `checkin`, `notification`, `medical_record`
- Truoc khi refactor file lon nen tao backup logic hoac tach commit nho
- Neu co file moi tu spec ma chua ton tai trong repo, uu tien them vao module da co thay vi tao them cau truc `mobile/`

## 8. Dau ra mong muon sau moi dot cap nhat

- Booking flow chay thong: search -> book -> pay -> confirmed
- Check-in tao queue number, cap nhat wait time
- Doctor/admin nhin thay queue va xu ly duoc benh nhan tiep theo
- Benh nhan xem duoc notification va medical record co ban
- Code khong pha vo cac thay doi dang co san trong worktree
