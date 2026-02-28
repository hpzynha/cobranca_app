import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/auth_user.dart';
import 'package:app_cobranca/features/auth/domain/entities/signup_result.dart';

abstract class AuthRepository {
  Future<Result<SignUpResult>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Result<void>> resendVerificationEmail(String email);

  Future<Result<AuthUser?>> refreshAndGetCurrentUser();

  Future<Result<void>> signOut();
}
