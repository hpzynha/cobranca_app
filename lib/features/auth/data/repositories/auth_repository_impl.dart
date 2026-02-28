import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/models/auth_user_model.dart';
import 'package:app_cobranca/features/auth/domain/entities/auth_user.dart';
import 'package:app_cobranca/features/auth/domain/entities/signup_result.dart';
import 'package:app_cobranca/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<SignUpResult>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      final user = response.user;
      final emailConfirmed = user?.emailConfirmedAt != null;

      if (user == null) {
        return Result.success(
          SignUpResult(
            email: email,
            status: SignUpStatus.requiresEmailVerification,
          ),
        );
      }

      if (emailConfirmed) {
        return Result.success(
          SignUpResult(email: email, status: SignUpStatus.alreadyConfirmed),
        );
      }

      return Result.success(
        SignUpResult(
          email: user.email ?? email,
          status: SignUpStatus.requiresEmailVerification,
        ),
      );
    } on AuthException catch (e) {
      if (_isAlreadyRegisteredError(e)) {
        return Result.success(
          SignUpResult(email: email, status: SignUpStatus.alreadyConfirmed),
        );
      }
      return Result.error(_mapSupabaseError(e));
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Não foi possível concluir o cadastro. Tente novamente.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> resendVerificationEmail(String email) async {
    try {
      await _remoteDataSource.resendSignUpEmail(email);
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.error(_mapSupabaseError(e));
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Não foi possível reenviar o e-mail de verificação.',
        ),
      );
    }
  }

  @override
  Future<Result<AuthUser?>> refreshAndGetCurrentUser() async {
    try {
      await _remoteDataSource.refreshSession();
      final user = _remoteDataSource.getCurrentUser();
      if (user == null) {
        return Result.success(null);
      }
      return Result.success(AuthUserModel.fromSupabase(user));
    } on AuthException catch (e) {
      return Result.error(_mapSupabaseError(e));
    } catch (_) {
      return Result.error(
        const Failure(message: 'Falha ao atualizar status de verificação.'),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return Result.success(null);
    } on AuthException catch (e) {
      return Result.error(_mapSupabaseError(e));
    } catch (_) {
      return Result.error(
        const Failure(message: 'Não foi possível encerrar a sessão.'),
      );
    }
  }

  Failure _mapSupabaseError(AuthException exception) {
    switch (exception.statusCode) {
      case '400':
        return Failure(message: 'Dados inválidos. Revise as informações.');
      case '422':
        return Failure(message: 'E-mail inválido ou senha fraca.');
      case '429':
        return Failure(
          message: 'Muitas tentativas. Aguarde e tente novamente.',
        );
      default:
        return Failure(message: exception.message, code: exception.statusCode);
    }
  }

  bool _isAlreadyRegisteredError(AuthException exception) {
    final message = exception.message.toLowerCase();
    return message.contains('already') && message.contains('registered');
  }
}
