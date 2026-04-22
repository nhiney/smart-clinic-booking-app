import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/apps/bot_kiosk_device/domain/entities/slot_entity.dart';

abstract class KioskState {
  const KioskState();
}

class KioskIdle extends KioskState {
  const KioskIdle();
}

class KioskLoading extends KioskState {
  const KioskLoading();
}

class KioskSlotSelected extends KioskState {
  final SlotEntity slot;
  KioskSlotSelected(this.slot);
}

class KioskBookingSuccess extends KioskState {
  final String bookingId;
  KioskBookingSuccess(this.bookingId);
}

class KioskError extends KioskState {
  final String message;
  KioskError(this.message);
}

// Controller và Providers sẽ được triển khai tiếp theo...
