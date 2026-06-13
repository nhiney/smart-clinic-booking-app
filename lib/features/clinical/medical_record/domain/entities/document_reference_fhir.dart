import 'package:equatable/equatable.dart';

class DocumentReferenceFhir extends Equatable {
  final String id;
  final String status;
  final String? docStatus;
  final Map<String, dynamic> type;
  final Map<String, String> subject;
  final String date;
  final List<Map<String, dynamic>> content;

  const DocumentReferenceFhir({
    required this.id,
    required this.status,
    this.docStatus,
    required this.type,
    required this.subject,
    required this.date,
    required this.content,
  });

  @override
  List<Object?> get props => [id, status, docStatus, type, subject, date, content];

  factory DocumentReferenceFhir.fromJson(Map<String, dynamic> json) {
    return DocumentReferenceFhir(
      id: json['id'] as String,
      status: json['status'] as String,
      docStatus: json['docStatus'] as String?,
      type: Map<String, dynamic>.from(json['type'] as Map),
      subject: Map<String, String>.from(json['subject'] as Map),
      date: json['date'] as String,
      content: List<Map<String, dynamic>>.from(
        (json['content'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': 'DocumentReference',
      'id': id,
      'status': status,
      if (docStatus != null) 'docStatus': docStatus,
      'type': type,
      'subject': subject,
      'date': date,
      'content': content,
    };
  }
}
