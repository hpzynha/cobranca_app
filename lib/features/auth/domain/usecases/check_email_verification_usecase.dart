import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/auth_user.dart';
import 'package:app_cobranca/features/auth/domain/repositories/auth_repository.dart';

class CheckEmailVerificationUseCase {
  CheckEmailVerificationUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<AuthUser?>> call() {
    return _authRepository.refreshAndGetCurrentUser();
  }
}
