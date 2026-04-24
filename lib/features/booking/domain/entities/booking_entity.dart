/// Firestore `bookings.type`
class MedicalBookingTypes {
  static const clinic = 'clinic';
  static const specialty = 'specialty';
  static const test = 'test';
  static const pharmacy = 'pharmacy';
  static const enterprise = 'enterprise';

  static const values = [
    clinic,
    specialty,
    test,
    pharmacy,
    enterprise,
  ];
}

/// Firestore `bookings.status`
class MedicalBookingStatuses {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const cancelled = 'cancelled';
  static const completed = 'completed';
  static const waiting = 'waiting';

  static bool isActive(String s) {
    switch (s) {
      case pending:
      case confirmed:
      case waiting:
        return true;
      default:
        return false;
    }
  }
}

/// Firestore `bookings.paymentStatus`
class MedicalBookingPaymentStatuses {
  static const unpaid = 'unpaid';
  static const paid = 'paid';
}

class BookingEntity {
  final String id;
  final String userId;
  final String doctorId;
  /// Stable key for `slots` doc (stored for reschedule / expiry release).
  final String slotId;
  final String type;
  final String specialty;
  final String symptoms;
  final DateTime date;
  final String timeSlot;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime expiresAt;
  /// Signed QR check-in token (generated at booking time).
  final String? checkInToken;
  /// Earliest time the QR token is valid (appointmentTime - 1h).
  final DateTime? qrValidFrom;
  /// Latest time the QR token is valid (appointmentTime + 30min).
  final DateTime? qrExpiresAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.slotId,
    required this.type,
    required this.specialty,
    required this.symptoms,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.expiresAt,
    this.checkInToken,
    this.qrValidFrom,
    this.qrExpiresAt,
  });
}

/// Result of checking a single slot document.
enum SlotAvailabilityKind {
  available,
  booked,
  lockedBySelf,
  lockedByOther,
  lockExpired,
}

class SlotAvailability {
  final SlotAvailabilityKind kind;
  final DateTime? lockExpiresAt;
  final String? lockedBy;

  const SlotAvailability({
    required this.kind,
    this.lockExpiresAt,
    this.lockedBy,
  });
}
