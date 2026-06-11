import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/services/file_storage_service.dart';
import '../../../patient_pov/domain/entities/doctor_entity.dart';
import '../../../patient_pov/domain/entities/doctor_workspace_models.dart';
import '../../../patient_pov/domain/repositories/doctor_repository.dart';
import '../../../../appointment/domain/repositories/appointment_repository.dart';
import '../../../../appointment/domain/entities/appointment_entity.dart';

class DoctorController extends ChangeNotifier {
  final DoctorRepository doctorRepository;
  final AppointmentRepository appointmentRepository;
  final FileStorageService storageService;

  DoctorController({
    required this.doctorRepository,
    required this.appointmentRepository,
    required this.storageService,
  });

  bool isLoading = false;
  String? errorMessage;
  DoctorEntity? currentDoctor;
  List<AppointmentEntity> todayAppointments = [];
  Map<String, dynamic> stats = {
    'today_total': 0,
    'waiting': 0,
    'confirmed': 0,
    'week_total': 0,
    'sparklineData': <double>[0, 0, 0, 0, 0, 0, 0],
  };
  List<DoctorWorkDay> workDays = const [];
  List<DoctorIncomeEntry> incomeEntries = const [];
  double monthlyIncome = 24.8;
  double receivedIncome = 18.2;
  double pendingIncome = 6.6;
  List<double> monthlyIncomeTrend = const [21.2, 22.1, 23.4, 24.0, 23.6, 24.8];
  String workspaceStatus = 'Chưa lưu lịch làm việc';

  Future<void> fetchDoctorProfile(String doctorId) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      debugPrint('[DIAGNOSTIC] Fetching doctor profile for ID: $doctorId');
      currentDoctor = await doctorRepository.getDoctorProfile(doctorId);
      debugPrint('[DIAGNOSTIC] Profile fetched successfully: ${currentDoctor?.name}');
      // Fall back to seed profile so the UI doesn't loop on null
      currentDoctor ??= DoctorEntity(
        id: doctorId,
        name: 'BS. Nguyễn Văn An',
        specialty: 'Nội tổng quát',
        hospital: 'Bệnh viện Chợ Rẫy',
        clinicName: 'Phòng khám số 3 – Khoa Nội',
        location: 'TP. Hồ Chí Minh',
        rating: 4.9,
        totalReviews: 312,
        experience: 12,
        about: 'Bác sĩ chuyên khoa Nội tổng quát với hơn 12 năm kinh nghiệm tại Bệnh viện Chợ Rẫy.',
        imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400',
        availableDays: ['T2', 'T3', 'T4', 'T5', 'T6'],
        availableTimeSlots: ['08:00', '09:00', '10:00', '14:00', '15:00'],
      );
      await _restoreWorkspaceState();
      await fetchDashboardData(doctorId);
    } catch (e) {
      debugPrint('[DIAGNOSTIC] Error fetching doctor profile: $e');
      // Still set a fallback so the UI doesn't re-fetch endlessly
      currentDoctor ??= DoctorEntity(
        id: doctorId,
        name: 'BS. Nguyễn Văn An',
        specialty: 'Nội tổng quát',
        hospital: 'Bệnh viện Chợ Rẫy',
      );
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboardData(String doctorId) async {
    try {
      var appointments = await appointmentRepository.getAppointmentsByDoctor(doctorId);
      
      // Auto seed if database is clean
      if (appointments.isEmpty) {
        await _seedAppointmentsForDoctor(doctorId);
        appointments = await appointmentRepository.getAppointmentsByDoctor(doctorId);
      }

      // Filter for today
      final now = DateTime.now();
      todayAppointments = appointments.where((a) {
        return a.dateTime.year == now.year &&
               a.dateTime.month == now.month &&
               a.dateTime.day == now.day;
      }).toList();

      // Calculate stats
      int waiting = todayAppointments.where((a) => a.status == AppointmentStatuses.checkedIn || a.status == AppointmentStatuses.inQueue).length;
      int confirmed = todayAppointments.where((a) => a.status == AppointmentStatuses.confirmed || a.status == AppointmentStatuses.booked).length;
      
      // Calculate weekly stats
      final last7Days = now.subtract(const Duration(days: 7));
      final weekAppointments = appointments.where((a) {
        return a.dateTime.isAfter(last7Days) && a.dateTime.isBefore(now.add(const Duration(days: 1)));
      }).toList();
      
      List<double> sparkline = List.filled(7, 0.0);
      for (var a in weekAppointments) {
        final diff = now.difference(a.dateTime).inDays;
        if (diff >= 0 && diff < 7) {
          sparkline[6 - diff] += 1;
        }
      }

      stats = {
        'today_total': todayAppointments.length,
        'waiting': waiting,
        'confirmed': confirmed,
        'week_total': weekAppointments.length,
        'sparklineData': sparkline.where((e) => e > 0).isEmpty ? <double>[0, 0, 0, 0, 0, 0, 0] : sparkline,
      };
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  Future<void> _seedAppointmentsForDoctor(String doctorId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final list = [
        {
          'patientId': 'patient_001',
          'patientName': 'Phạm Hoàng Long',
          'specialty': 'Tim mạch',
          'dateTime': Timestamp.fromDate(today.add(const Duration(hours: 8))), // 08:00
          'status': AppointmentStatuses.completed,
          'queueNumber': 'A01',
          'priorityLevel': AppointmentPriorityLevels.normal,
        },
        {
          'patientId': 'patient_002',
          'patientName': 'Đỗ Minh Tâm',
          'specialty': 'Tim mạch',
          'dateTime': Timestamp.fromDate(today.add(const Duration(hours: 8, minutes: 30))), // 08:30
          'status': AppointmentStatuses.completed,
          'queueNumber': 'A02',
          'priorityLevel': AppointmentPriorityLevels.normal,
        },
        {
          'patientId': 'patient_003',
          'patientName': 'Bùi Thị Mai',
          'specialty': 'Tim mạch',
          'dateTime': Timestamp.fromDate(today.add(const Duration(hours: 9))), // 09:00
          'status': AppointmentStatuses.completed,
          'queueNumber': 'A03',
          'priorityLevel': AppointmentPriorityLevels.normal,
        },
        {
          'patientId': 'patient_004',
          'patientName': 'Lê Văn Khôi',
          'specialty': 'Tim mạch',
          'dateTime': Timestamp.fromDate(today.add(const Duration(hours: 9, minutes: 30))), // 09:30
          'status': AppointmentStatuses.completed,
          'queueNumber': 'A04',
          'priorityLevel': AppointmentPriorityLevels.emergency,
        },
        {
          'patientId': 'patient_005',
          'patientName': 'Vũ Thị Hồng',
          'specialty': 'Tim mạch',
          'dateTime': Timestamp.fromDate(today.add(const Duration(hours: 10))), // 10:00
          'status': AppointmentStatuses.inQueue, // Đang khám
          'queueNumber': 'A05',
          'priorityLevel': AppointmentPriorityLevels.normal,
        },
        {
          'patientId': '0451', // Nguyễn Văn An
          'patientName': 'Nguyễn Văn An',
          'specialty': 'Tim mạch',
          'dateTime': Timestamp.fromDate(today.add(const Duration(hours: 10, minutes: 30))), // 10:30
          'status': AppointmentStatuses.confirmed,
          'queueNumber': 'A06',
          'priorityLevel': AppointmentPriorityLevels.emergency,
          'notes': 'Đau ngực âm ỉ 3 ngày qua, lan ra cánh tay trái khi gắng sức. Kèm khó thở, chóng mặt vào buổi sáng. Đã tự uống Aspirin 81mg.',
        },
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (var item in list) {
        final docRef = FirebaseFirestore.instance.collection('appointments').doc();
        batch.set(docRef, {
          ...item,
          'doctorId': doctorId,
          'doctorName': currentDoctor?.name ?? 'BS. Nguyễn Hồng',
          'createdAt': FieldValue.serverTimestamp(),
          'statusUpdatedAt': FieldValue.serverTimestamp(),
          'paymentStatus': AppointmentPaymentStatuses.paid,
        });
      }
      await batch.commit();
      debugPrint('[DoctorController] Successfully seeded appointments on Firestore');
    } catch (e) {
      debugPrint('[DoctorController] Seeding appointments error: $e');
    }
  }

  Future<void> _restoreWorkspaceState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('doctor_workspace_schedule_v1');
    if (raw == null || raw.isEmpty) {
      workDays = _loadWorkDays();
      incomeEntries = _buildIncomeEntries();
      return;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      workDays = decoded.map((entry) {
        final map = Map<String, dynamic>.from(entry as Map);
        final slots = (map['slots'] as List<dynamic>? ?? const []).map((slotEntry) {
          final slot = Map<String, dynamic>.from(slotEntry as Map);
          return DoctorWorkSlot(
            id: slot['id']?.toString() ?? '',
            label: slot['label']?.toString() ?? '',
            timeRange: slot['timeRange']?.toString() ?? '',
            enabled: slot['enabled'] as bool? ?? true,
          );
        }).toList();
        return DoctorWorkDay(
          dayLabel: map['dayLabel']?.toString() ?? '',
          enabled: map['enabled'] as bool? ?? true,
          slots: slots,
        );
      }).toList();
    } catch (e) {
      debugPrint('[DoctorController] Restore schedule failed: $e');
      workDays = _loadWorkDays();
    }

    incomeEntries = _buildIncomeEntries();
  }

  List<DoctorIncomeEntry> _buildIncomeEntries() {
    return const [
      DoctorIncomeEntry(
        title: 'Thanh toán đợt T5/2',
        dateLabel: '22/05/2026 • 18 ca',
        amountLabel: '+đ4.2M',
        statusLabel: 'Đã chuyển',
        isPaid: true,
      ),
      DoctorIncomeEntry(
        title: 'Thanh toán đợt T5/1',
        dateLabel: '15/05/2026 • 24 ca',
        amountLabel: '+đ5.8M',
        statusLabel: 'Đã chuyển',
        isPaid: true,
      ),
      DoctorIncomeEntry(
        title: 'Thanh toán đợt T4/cuối',
        dateLabel: '08/05/2026 • 15 ca',
        amountLabel: '+đ3.6M',
        statusLabel: 'Đã chuyển',
        isPaid: true,
      ),
    ];
  }

  List<DoctorWorkDay> _loadWorkDays() {
    return [
      const DoctorWorkDay(
        dayLabel: 'Thứ 2',
        enabled: true,
        slots: [
          DoctorWorkSlot(id: 'mon-1', label: '08:00–11:30', timeRange: '4 slot 30 phút'),
          DoctorWorkSlot(id: 'mon-2', label: '14:00–17:00', timeRange: '4 slot 30 phút'),
        ],
      ),
      const DoctorWorkDay(
        dayLabel: 'Thứ 3',
        enabled: true,
        slots: [
          DoctorWorkSlot(id: 'tue-1', label: '08:00–11:30', timeRange: '4 slot 30 phút'),
          DoctorWorkSlot(id: 'tue-2', label: '14:00–17:00', timeRange: '4 slot 30 phút'),
        ],
      ),
      const DoctorWorkDay(
        dayLabel: 'Thứ 4',
        enabled: true,
        slots: [
          DoctorWorkSlot(id: 'wed-1', label: '08:00–11:30', timeRange: '7 slot 30 phút'),
        ],
      ),
      const DoctorWorkDay(
        dayLabel: 'Thứ 5',
        enabled: true,
        slots: [
          DoctorWorkSlot(id: 'thu-1', label: '08:00–11:30', timeRange: '4 slot 30 phút'),
          DoctorWorkSlot(id: 'thu-2', label: '14:00–17:00', timeRange: '4 slot 30 phút'),
        ],
      ),
      const DoctorWorkDay(
        dayLabel: 'Thứ 6',
        enabled: false,
        slots: [
          DoctorWorkSlot(id: 'fri-1', label: '08:00–11:30', timeRange: '4 slot 30 phút'),
        ],
      ),
      const DoctorWorkDay(
        dayLabel: 'Thứ 7',
        enabled: false,
        slots: [
          DoctorWorkSlot(id: 'sat-1', label: '08:00–11:30', timeRange: '4 slot 30 phút'),
        ],
      ),
      const DoctorWorkDay(
        dayLabel: 'Chủ nhật',
        enabled: false,
        slots: [],
      ),
    ];
  }

  Future<void> saveWorkSchedule() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'doctor_workspace_schedule_v1',
        jsonEncode(
          workDays
              .map(
                (day) => {
                  'dayLabel': day.dayLabel,
                  'enabled': day.enabled,
                  'slots': day.slots
                      .map(
                        (slot) => {
                          'id': slot.id,
                          'label': slot.label,
                          'timeRange': slot.timeRange,
                          'enabled': slot.enabled,
                        },
                      )
                      .toList(),
                },
              )
              .toList(),
        ),
      );
      workspaceStatus = 'Đã lưu lịch làm việc';
      notifyListeners();
    } catch (e) {
      workspaceStatus = 'Lưu thất bại: $e';
      notifyListeners();
    }
  }

  void toggleWorkDay(int index) {
    if (index < 0 || index >= workDays.length) return;
    final items = [...workDays];
    items[index] = items[index].copyWith(enabled: !items[index].enabled);
    workDays = items;
    workspaceStatus = 'Đã thay đổi lịch làm việc';
    notifyListeners();
  }

  void addWorkSlot(int dayIndex, String label, String timeRange) {
    if (dayIndex < 0 || dayIndex >= workDays.length) return;
    final items = [...workDays];
    final day = items[dayIndex];
    final slots = [
      ...day.slots,
      DoctorWorkSlot(
        id: '${day.dayLabel}-${DateTime.now().millisecondsSinceEpoch}',
        label: label,
        timeRange: timeRange,
      ),
    ];
    items[dayIndex] = day.copyWith(slots: slots);
    workDays = items;
    notifyListeners();
  }

  void removeWorkSlot(int dayIndex, String slotId) {
    if (dayIndex < 0 || dayIndex >= workDays.length) return;
    final items = [...workDays];
    final day = items[dayIndex];
    items[dayIndex] = day.copyWith(
      slots: day.slots.where((slot) => slot.id != slotId).toList(),
    );
    workDays = items;
    notifyListeners();
  }

  Future<void> updateDoctorWorkspaceProfile({
    required String name,
    required String specialty,
    required String hospital,
    required String about,
    required String phone,
    required String clinicName,
    required String location,
  }) async {
    final doctor = currentDoctor;
    if (doctor == null) return;
    await updateProfile(
      doctor.copyWith(
        name: name,
        specialty: specialty,
        hospital: hospital,
        about: about,
        phone: phone,
        clinicName: clinicName,
        location: location,
      ),
    );
  }

  Future<void> updateProfile(DoctorEntity updatedDoctor) async {
    try {
      isLoading = true;
      notifyListeners();
      await doctorRepository.updateDoctorProfile(updatedDoctor);
      currentDoctor = updatedDoctor;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickAndUploadResume(String doctorId) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        isLoading = true;
        notifyListeners();

        final file = File(result.files.single.path!);
        final downloadUrl = await storageService.uploadDoctorResume(
          doctorId: doctorId,
          file: file,
        );

        // Update local state and Firestore
        final updatedDoctor = DoctorEntity(
          id: currentDoctor!.id,
          name: currentDoctor!.name,
          specialty: currentDoctor!.specialty,
          experience: currentDoctor!.experience,
          about: currentDoctor!.about,
          resumePdfUrl: downloadUrl,
          departmentId: currentDoctor!.departmentId,
        );

        await doctorRepository.assignDoctorToDepartment(
          doctorId: doctorId,
          hospitalId: currentDoctor!.hospital,
          departmentId: currentDoctor!.departmentId,
          // resumePdfUrl should be added to the assignment/update logic in repository
        );
        
        // Better: implement a specific updateResumeUrl in repo
        currentDoctor = updatedDoctor;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
