import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';

class StudentRegistrationPayload {
  const StudentRegistrationPayload({
    required this.ownerId,
    required this.name,
    required this.monthlyFeeCents,
    required this.dueDay,
    this.photoUrl,
  });

  final String ownerId;
  final String name;
  final int monthlyFeeCents;
  final int dueDay;
  final String? photoUrl;

  factory StudentRegistrationPayload.fromInput({
    required StudentRegistrationInput input,
    required String ownerId,
  }) {
    return StudentRegistrationPayload(
      ownerId: ownerId,
      name: input.name.trim(),
      monthlyFeeCents: input.monthlyFeeCents,
      dueDay: input.dueDay,
      photoUrl: input.photoUrl,
    );
  }

  Map<String, dynamic> toSupabaseMap() {
    return {
      'owner_id': ownerId,
      'name': name,
      'monthly_fee_cents': monthlyFeeCents,
      'due_day': dueDay,
      'photo_url': photoUrl,
    };
  }
}
