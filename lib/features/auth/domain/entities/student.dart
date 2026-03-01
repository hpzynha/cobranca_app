class Student {
  const Student({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.monthlyFeeCents,
    required this.dueDay,
    this.nextDueDate,
    this.lastPaymentDate,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String whatsapp;
  final int monthlyFeeCents;
  final int dueDay;
  final DateTime? nextDueDate;
  final DateTime? lastPaymentDate;
  final String? photoUrl;
}
