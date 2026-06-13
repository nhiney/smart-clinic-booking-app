import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String name;
  final String downloadUrl;
  final String fileType;
  final DateTime uploadedAt;

  const Attachment({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [id, name, downloadUrl, fileType, uploadedAt];
}
