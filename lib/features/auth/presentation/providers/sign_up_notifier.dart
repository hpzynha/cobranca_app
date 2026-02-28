import 'package:app_cobranca/features/auth/domain/entities/signup_result.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signUpNotifierProvider =
    AsyncNotifierProvider<SignUpNotifier, SignUpResult?>(SignUpNotifier.new);

class SignUpNotifier extends AsyncNotifier<SignUpResult?> {
  @override
  Future<SignUpResult?> build() async => null;

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    final result = await ref
        .read(signUpUseCaseProvider)
        .call(fullName: fullName, email: email, password: password);

    if (!result.isSuccess || result.data == null) {
      state = AsyncError(
        result.failure?.message ?? 'Não foi possível criar a conta.',
        StackTrace.current,
      );
      return;
    }

    state = AsyncData(result.data);
  }
}
