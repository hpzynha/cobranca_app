import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';

class StudentRegistrationPayload {
  const StudentRegistrationPayload({
    required this.name,
    required this.monthlyFeeCents,
    required this.dueDay,
    this.photoUrl,
  });

  final String name;
  final int monthlyFeeCents;
  final int dueDay;
  final String? photoUrl;

  factory StudentRegistrationPayload.fromInput(StudentRegistrationInput input) {
    return StudentRegistrationPayload(
      name: input.name.trim(),
      monthlyFeeCents: input.monthlyFeeCents,
      dueDay: input.dueDay,
      photoUrl: input.photoUrl,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'name': name,
      'monthly_fee_cents': monthlyFeeCents,
      'due_day': dueDay,
      'photo_url': photoUrl,
    };
  }
}
