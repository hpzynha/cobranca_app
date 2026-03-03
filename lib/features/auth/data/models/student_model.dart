import 'package:app_cobranca/features/auth/domain/entities/student.dart';

class StudentModel {
  const StudentModel({
    required this.id,
    required this.name,
    required this.whatsapp,
    required this.monthlyFeeCents,
    required this.dueDay,
    this.nextDueDate,
    this.lastPaymentDate,
    this.photoUrl,
    this.paymentStatusCode,
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

  factory StudentModel.fromSupabaseMap(Map<String, dynamic> map) {
    final nextDueDateRaw = map['next_due_date']?.toString();
    final lastPaymentDateRaw = map['last_payment_date']?.toString();

    return StudentModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      whatsapp: (map['whatsapp'] ?? '').toString(),
      monthlyFeeCents: (map['monthly_fee_cents'] as num?)?.toInt() ?? 0,
      dueDay: (map['due_day'] as num?)?.toInt() ?? 1,
      nextDueDate:
          nextDueDateRaw == null || nextDueDateRaw.isEmpty
              ? null
              : DateTime.parse(nextDueDateRaw),
      lastPaymentDate:
          lastPaymentDateRaw == null || lastPaymentDateRaw.isEmpty
              ? null
              : DateTime.parse(lastPaymentDateRaw),
      photoUrl: map['photo_url'] as String?,
      paymentStatusCode: map['payment_status']?.toString(),
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'name': name,
      'whatsapp': whatsapp,
      'monthly_fee_cents': monthlyFeeCents,
      'due_day': dueDay,
      'next_due_date': nextDueDate?.toIso8601String(),
      'last_payment_date': lastPaymentDate?.toIso8601String(),
      'photo_url': photoUrl,
    };
  }

  Student toEntity() {
    return Student(
      id: id,
      name: name,
      whatsapp: whatsapp,
      monthlyFeeCents: monthlyFeeCents,
      dueDay: dueDay,
      nextDueDate: nextDueDate,
      lastPaymentDate: lastPaymentDate,
      photoUrl: photoUrl,
      paymentStatusCode: paymentStatusCode,
    );
  }
}
