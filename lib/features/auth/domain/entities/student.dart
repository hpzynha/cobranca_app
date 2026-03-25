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
    this.paymentStatusCode,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String whatsapp;
  final int monthlyFeeCents;
  final int dueDay;
  final DateTime? nextDueDate;
  final DateTime? lastPaymentDate;
  final String? photoUrl;
  final String? paymentStatusCode;
  final bool isActive;

  Student copyWith({
    String? id,
    String? name,
    String? whatsapp,
    int? monthlyFeeCents,
    int? dueDay,
    DateTime? nextDueDate,
    DateTime? lastPaymentDate,
    String? photoUrl,
    String? paymentStatusCode,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      whatsapp: whatsapp ?? this.whatsapp,
      monthlyFeeCents: monthlyFeeCents ?? this.monthlyFeeCents,
      dueDay: dueDay ?? this.dueDay,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      photoUrl: photoUrl ?? this.photoUrl,
      paymentStatusCode: paymentStatusCode ?? this.paymentStatusCode,
      isActive: isActive ?? this.isActive,
    );
  }
}
