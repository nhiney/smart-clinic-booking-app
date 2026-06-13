enum ClinicalChatSender { system, patient, doctor }

class ClinicalChatMessage {
  final String id;
  final String text;
  final ClinicalChatSender sender;
  final DateTime timestamp;
  final String? attachmentLabel;

  final bool isRead;

  const ClinicalChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.attachmentLabel,
    this.isRead = true,
  });
}
