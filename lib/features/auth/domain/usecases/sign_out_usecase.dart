import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<void>> call() {
    return _authRepository.signOut();
  }
}
