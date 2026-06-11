class DoctorWorkSlot {
  final String id;
  final String label;
  final String timeRange;
  final bool enabled;

  const DoctorWorkSlot({
    required this.id,
    required this.label,
    required this.timeRange,
    this.enabled = true,
  });

  DoctorWorkSlot copyWith({bool? enabled}) {
    return DoctorWorkSlot(
      id: id,
      label: label,
      timeRange: timeRange,
      enabled: enabled ?? this.enabled,
    );
  }
}

class DoctorWorkDay {
  final String dayLabel;
  final bool enabled;
  final List<DoctorWorkSlot> slots;

  const DoctorWorkDay({
    required this.dayLabel,
    required this.enabled,
    required this.slots,
  });

  DoctorWorkDay copyWith({bool? enabled, List<DoctorWorkSlot>? slots}) {
    return DoctorWorkDay(
      dayLabel: dayLabel,
      enabled: enabled ?? this.enabled,
      slots: slots ?? this.slots,
    );
  }
}

class DoctorIncomeEntry {
  final String title;
  final String dateLabel;
  final String amountLabel;
  final String statusLabel;
  final bool isPaid;

  const DoctorIncomeEntry({
    required this.title,
    required this.dateLabel,
    required this.amountLabel,
    required this.statusLabel,
    required this.isPaid,
  });
}
