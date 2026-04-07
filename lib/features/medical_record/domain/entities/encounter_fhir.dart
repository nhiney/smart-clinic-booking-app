import 'package:equatable/equatable.dart';

class EncounterFhir extends Equatable {
  final String id;
  final String status;
  final Map<String, String> subject;
  final List<Map<String, dynamic>> participant;
  final Map<String, DateTime> period;
  final List<Map<String, String>> reasonCode;

  const EncounterFhir({
    required this.id,
    required this.status,
    required this.subject,
    required this.participant,
    required this.period,
    required this.reasonCode,
  });

  @override
  List<Object?> get props => [id, status, subject, participant, period, reasonCode];

  factory EncounterFhir.fromJson(Map<String, dynamic> json) {
    return EncounterFhir(
      id: json['id'] as String,
      status: json['status'] as String,
      subject: Map<String, String>.from(json['subject'] as Map),
      participant: List<Map<String, dynamic>>.from(
        (json['participant'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      period: {
        'start': DateTime.parse(json['period']['start'] as String),
        if (json['period']['end'] != null)
          'end': DateTime.parse(json['period']['end'] as String),
      },
      reasonCode: List<Map<String, String>>.from(
        (json['reasonCode'] as List).map((e) => Map<String, String>.from(e as Map)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Encounter',
      'id': id,
      'status': status,
      'subject': subject,
      'participant': participant,
      'period': {
        'start': period['start']?.toIso8601String(),
        if (period['end'] != null) 'end': period['end']?.toIso8601String(),
      },
      'reasonCode': reasonCode,
    };
  }
}
