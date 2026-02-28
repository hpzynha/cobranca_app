import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/repositories/auth_repository.dart';

class ResendVerificationEmailUseCase {
  ResendVerificationEmailUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<void>> call(String email) {
    return _authRepository.resendVerificationEmail(email);
  }
}
