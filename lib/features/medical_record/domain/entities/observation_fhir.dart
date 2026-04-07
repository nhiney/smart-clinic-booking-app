import 'package:equatable/equatable.dart';

class ObservationFhir extends Equatable {
  final String id;
  final String status;
  final List<Map<String, dynamic>> category;
  final Map<String, dynamic> code;
  final Map<String, String> subject;
  final Map<String, String>? encounter;
  final Map<String, dynamic>? valueQuantity;
  final String? valueString;

  const ObservationFhir({
    required this.id,
    required this.status,
    required this.category,
    required this.code,
    required this.subject,
    this.encounter,
    this.valueQuantity,
    this.valueString,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        category,
        code,
        subject,
        encounter,
        valueQuantity,
        valueString,
      ];

  factory ObservationFhir.fromJson(Map<String, dynamic> json) {
    return ObservationFhir(
      id: json['id'] as String,
      status: json['status'] as String,
      category: List<Map<String, dynamic>>.from(
        (json['category'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      code: Map<String, dynamic>.from(json['code'] as Map),
      subject: Map<String, String>.from(json['subject'] as Map),
      encounter: json['encounter'] != null
          ? Map<String, String>.from(json['encounter'] as Map)
          : null,
      valueQuantity: json['valueQuantity'] != null
          ? Map<String, dynamic>.from(json['valueQuantity'] as Map)
          : null,
      valueString: json['valueString'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'Observation',
      'id': id,
      'status': status,
      'category': category,
      'code': code,
      'subject': subject,
      if (encounter != null) 'encounter': encounter,
      if (valueQuantity != null) 'valueQuantity': valueQuantity,
      if (valueString != null) 'valueString': valueString,
    };
  }
}
