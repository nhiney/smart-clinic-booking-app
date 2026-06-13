import 'package:equatable/equatable.dart';

class MedicationRequestFhir extends Equatable {
  final String id;
  final String status;
  final String intent;
  final Map<String, dynamic> medicationCodeableConcept;
  final Map<String, String> subject;
  final Map<String, String>? encounter;
  final String? authoredOn;
  final Map<String, String>? requester;

  const MedicationRequestFhir({
    required this.id,
    required this.status,
    required this.intent,
    required this.medicationCodeableConcept,
    required this.subject,
    this.encounter,
    this.authoredOn,
    this.requester,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        intent,
        medicationCodeableConcept,
        subject,
        encounter,
        authoredOn,
        requester,
      ];

  factory MedicationRequestFhir.fromJson(Map<String, dynamic> json) {
    return MedicationRequestFhir(
      id: json['id'] as String,
      status: json['status'] as String,
      intent: json['intent'] as String,
      medicationCodeableConcept:
          Map<String, dynamic>.from(json['medicationCodeableConcept'] as Map),
      subject: Map<String, String>.from(json['subject'] as Map),
      encounter: json['encounter'] != null
          ? Map<String, String>.from(json['encounter'] as Map)
          : null,
      authoredOn: json['authoredOn'] as String?,
      requester: json['requester'] != null
          ? Map<String, String>.from(json['requester'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'MedicationRequest',
      'id': id,
      'status': status,
      'intent': intent,
      'medicationCodeableConcept': medicationCodeableConcept,
      'subject': subject,
      if (encounter != null) 'encounter': encounter,
      if (authoredOn != null) 'authoredOn': authoredOn,
      if (requester != null) 'requester': requester,
    };
  }
}
