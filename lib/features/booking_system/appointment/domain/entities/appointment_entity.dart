class AppointmentStatuses {
  static const pendingBooking = 'pending_booking';
  static const booked = 'booked';
  static const confirmed = 'confirmed';
  static const checkedIn = 'checked_in';
  static const inQueue = 'in_queue';
  static const inConsultation = 'in_consultation';
  static const postConsultation = 'post_consultation';
  static const completed = 'completed';
  static const cancelled = 'cancelled';
  static const noShow = 'no_show';
  static const noShowPending = 'no_show_pending';
  static const rescheduled = 'rescheduled';

  static const active = {
    pendingBooking,
    booked,
    confirmed,
    checkedIn,
    inQueue,
    inConsultation,
    postConsultation,
    rescheduled,
    noShowPending,
  };

  static const cancellable = {
    pendingBooking,
    booked,
    confirmed,
    checkedIn,
    inQueue,
    rescheduled,
    noShowPending,
  };

  static String normalize(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return pendingBooking;
      case 'pending_payment':
        return booked;
      default:
        return value.trim().toLowerCase();
    }
  }
}

class AppointmentPaymentStatuses {
  static const unpaid = 'unpaid';
  static const pending = 'pending';
  static const paid = 'paid';
  static const refunded = 'refunded';
  static const failed = 'failed';
}

class AppointmentPriorityLevels {
  static const normal = 'normal';
  static const elderly = 'elderly';
  static const emergency = 'emergency';
}

class AppointmentEntity {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;
  final String notes;
  final DateTime? createdAt;
  final String? queueNumber;
  final int? estimatedWaitTimeMinutes;
  final String? checkInToken;
  final String paymentStatus;
  final String priorityLevel;
  final DateTime? statusUpdatedAt;
  final DateTime? checkedInAt;
  final DateTime? completedAt;

  const AppointmentEntity({
    required this.id,
    required this.patientId,
    this.patientName = '',
    required this.doctorId,
    this.doctorName = '',
    this.specialty = '',
    required this.dateTime,
    this.status = AppointmentStatuses.pendingBooking,
    this.notes = '',
    this.createdAt,
    this.queueNumber,
    this.estimatedWaitTimeMinutes,
    this.checkInToken,
    this.paymentStatus = AppointmentPaymentStatuses.unpaid,
    this.priorityLevel = AppointmentPriorityLevels.normal,
    this.statusUpdatedAt,
    this.checkedInAt,
    this.completedAt,
  });

  AppointmentEntity copyWith({
    String? status,
    DateTime? dateTime,
    String? notes,
    String? queueNumber,
    int? estimatedWaitTimeMinutes,
    String? checkInToken,
    String? paymentStatus,
    String? priorityLevel,
    DateTime? statusUpdatedAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
  }) {
    return AppointmentEntity(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      specialty: specialty,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      queueNumber: queueNumber ?? this.queueNumber,
      estimatedWaitTimeMinutes:
          estimatedWaitTimeMinutes ?? this.estimatedWaitTimeMinutes,
      checkInToken: checkInToken ?? this.checkInToken,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get normalizedStatus => AppointmentStatuses.normalize(status);

  bool get isUpcoming => AppointmentStatuses.active.contains(normalizedStatus);

  bool get isCancellable =>
      AppointmentStatuses.cancellable.contains(normalizedStatus);
}
