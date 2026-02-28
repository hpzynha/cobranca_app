import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/signup_result.dart';
import 'package:app_cobranca/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  SignUpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<SignUpResult>> call({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _authRepository.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
