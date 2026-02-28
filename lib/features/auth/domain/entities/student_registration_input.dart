class StudentRegistrationInput {
  const StudentRegistrationInput({
    required this.name,
    required this.monthlyFeeCents,
    required this.dueDay,
    this.photoUrl,
  });

  final String name;
  final int monthlyFeeCents;
  final int dueDay;
  final String? photoUrl;
}
