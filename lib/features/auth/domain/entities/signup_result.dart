enum SignUpStatus { requiresEmailVerification, alreadyConfirmed }

class SignUpResult {
  const SignUpResult({
    required this.email,
    required this.status,
  });

  final String email;
  final SignUpStatus status;
}
