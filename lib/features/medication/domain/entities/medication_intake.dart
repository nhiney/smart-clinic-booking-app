class MedicationIntake {
  final String id;
  final String medicationId;
  final String patientId;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final bool wasTaken;
  final String? note;

  const MedicationIntake({
    required this.id,
    required this.medicationId,
    required this.patientId,
    required this.scheduledAt,
    this.takenAt,
    this.wasTaken = false,
    this.note,
  });

  factory MedicationIntake.fromJson(Map<String, dynamic> json) {
    return MedicationIntake(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      patientId: json['patientId'] as String,
      scheduledAt: json['scheduledAt'] is String
          ? DateTime.parse(json['scheduledAt'])
          : (json['scheduledAt'] as dynamic).toDate(),
      takenAt: json['takenAt'] == null
          ? null
          : json['takenAt'] is String
              ? DateTime.parse(json['takenAt'])
              : (json['takenAt'] as dynamic).toDate(),
      wasTaken: json['wasTaken'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicationId': medicationId,
        'patientId': patientId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'takenAt': takenAt?.toIso8601String(),
        'wasTaken': wasTaken,
        'note': note,
      };
}
