import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailVerificationState {
  const EmailVerificationState({
    this.infoMessage,
    this.errorMessage,
    this.isVerified = false,
  });

  final String? infoMessage;
  final String? errorMessage;
  final bool isVerified;

  EmailVerificationState copyWith({
    String? infoMessage,
    String? errorMessage,
    bool? isVerified,
  }) {
    return EmailVerificationState(
      infoMessage: infoMessage,
      errorMessage: errorMessage,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

final emailVerificationNotifierProvider =
    AsyncNotifierProvider<EmailVerificationNotifier, EmailVerificationState>(
      EmailVerificationNotifier.new,
    );

class EmailVerificationNotifier extends AsyncNotifier<EmailVerificationState> {
  @override
  Future<EmailVerificationState> build() async {
    return const EmailVerificationState();
  }

  Future<void> checkEmailVerification() async {
    state = const AsyncLoading();

    final checkResult = await ref.read(checkEmailVerificationUseCaseProvider)();
    if (!checkResult.isSuccess) {
      state = AsyncData(
        EmailVerificationState(
          errorMessage:
              checkResult.failure?.message ??
              'Não foi possível verificar o e-mail.',
        ),
      );
      return;
    }

    final user = checkResult.data;
    if (user == null || !user.emailConfirmed) {
      state = const AsyncData(
        EmailVerificationState(
          errorMessage:
              'Seu e-mail ainda não foi confirmado. Verifique sua caixa de entrada.',
        ),
      );
      return;
    }

    final signOutResult = await ref.read(signOutUseCaseProvider)();
    if (!signOutResult.isSuccess) {
      state = AsyncData(
        EmailVerificationState(
          errorMessage:
              signOutResult.failure?.message ??
              'E-mail confirmado, mas não foi possível sair da sessão.',
        ),
      );
      return;
    }

    state = const AsyncData(
      EmailVerificationState(
        isVerified: true,
        infoMessage: 'E-mail confirmado com sucesso. Faça login para continuar.',
      ),
    );
  }

  Future<void> resendEmail(String email) async {
    state = const AsyncLoading();

    final result = await ref
        .read(resendVerificationEmailUseCaseProvider)
        .call(email);

    if (!result.isSuccess) {
      state = AsyncData(
        EmailVerificationState(
          errorMessage:
              result.failure?.message ??
              'Não foi possível reenviar o e-mail de verificação.',
        ),
      );
      return;
    }

    state = AsyncData(
      const EmailVerificationState(
        infoMessage: 'E-mail de verificação reenviado com sucesso.',
      ),
    );
  }
}
