import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';

class StudentRegistrationPayload {
  const StudentRegistrationPayload({
    required this.ownerId,
    required this.name,
    required this.monthlyFeeCents,
    required this.dueDay,
    required this.nextDueDate,
    this.lastPaymentDate,
    this.photoUrl,
  });

  final String ownerId;
  final String name;
  final int monthlyFeeCents;
  final int dueDay;
  final DateTime nextDueDate;
  final DateTime? lastPaymentDate;
  final String? photoUrl;

  factory StudentRegistrationPayload.fromInput(
    StudentRegistrationInput input, {
    required String ownerId,
    required DateTime resolvedNextDueDate,
  }) {
    return StudentRegistrationPayload(
      ownerId: ownerId,
      name: input.name.trim(),
      monthlyFeeCents: input.monthlyFeeCents,
      dueDay: input.dueDay,
      nextDueDate: resolvedNextDueDate,
      lastPaymentDate: input.lastPaymentDate,
      photoUrl: input.photoUrl,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'owner_id': ownerId,
      'name': name,
      'monthly_fee_cents': monthlyFeeCents,
      'due_day': dueDay,
      'next_due_date': nextDueDate.toIso8601String(),
      'last_payment_date': lastPaymentDate?.toIso8601String(),
      'photo_url': photoUrl,
    };
  }
}
