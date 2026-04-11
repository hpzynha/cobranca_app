class MessageLog {
  const MessageLog({
    required this.id,
    required this.studentName,
    required this.template,
    required this.status,
    required this.sentAt,
    this.errorMsg,
  });

  final String id;
  final String studentName;
  final String template;
  final String status; // 'sent' | 'failed'
  final String? errorMsg;
  final DateTime sentAt;
}
