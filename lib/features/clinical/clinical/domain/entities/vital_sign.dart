import 'package:equatable/equatable.dart';

class VitalSign extends Equatable {
  final int systolic;
  final int diastolic;
  final int heartRate;
  final double bmi;
  final DateTime measuredAt;

  const VitalSign({
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    required this.bmi,
    required this.measuredAt,
  });

  String get bloodPressureLabel => '$systolic/$diastolic';
  String get bloodPressureUnit => 'mmHg';

  bool get isBloodPressureHigh => systolic >= 140 || diastolic >= 90;
  bool get isHeartRateHigh => heartRate >= 100;
  bool get isBmiHigh => bmi >= 25;
  bool get hasAlert => isBloodPressureHigh || isHeartRateHigh || isBmiHigh;

  String get alertLabel {
    if (isBloodPressureHigh) {
      return 'Tăng HA';
    }
    if (isHeartRateHigh) {
      return 'Nhịp tim cao';
    }
    if (isBmiHigh) {
      return 'BMI cao';
    }
    return 'Ổn định';
  }

  @override
  List<Object?> get props => [systolic, diastolic, heartRate, bmi, measuredAt];
}
