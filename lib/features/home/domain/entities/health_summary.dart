import 'package:equatable/equatable.dart';

/// Represents a health metric data point.
class HealthMetric extends Equatable {
  final String label;
  final String value;
  final String unit;
  final HealthStatus status;
  final DateTime recordedAt;

  const HealthMetric({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.recordedAt,
  });

  @override
  List<Object?> get props => [label, value, unit, status, recordedAt];
}

/// Represents the full health summary for a user.
class HealthSummary extends Equatable {
  final String userId;
  final HealthMetric heartRate;
  final HealthMetric bloodPressure;
  final HealthMetric bloodSugar;
  final HealthMetric bmi;
  final DateTime lastUpdated;

  const HealthSummary({
    required this.userId,
    required this.heartRate,
    required this.bloodPressure,
    required this.bloodSugar,
    required this.bmi,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [userId, heartRate, bloodPressure, bloodSugar, bmi, lastUpdated];
}

enum HealthStatus { normal, warning, critical, unknown }
