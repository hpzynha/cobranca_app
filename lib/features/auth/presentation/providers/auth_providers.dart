import 'package:app_cobranca/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app_cobranca/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_cobranca/features/auth/domain/usecases/check_email_verification_usecase.dart';
import 'package:app_cobranca/features/auth/domain/usecases/resend_verification_email_usecase.dart';
import 'package:app_cobranca/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:app_cobranca/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final resendVerificationEmailUseCaseProvider =
    Provider<ResendVerificationEmailUseCase>((ref) {
      return ResendVerificationEmailUseCase(ref.watch(authRepositoryProvider));
    });

final checkEmailVerificationUseCaseProvider =
    Provider<CheckEmailVerificationUseCase>((ref) {
      return CheckEmailVerificationUseCase(ref.watch(authRepositoryProvider));
    });

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final currentUserNameProvider = Provider<String>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  final fullName = user?.userMetadata?['full_name'] as String?;
  if (fullName != null && fullName.trim().isNotEmpty) {
    return fullName.trim().split(' ').first;
  }
  final email = user?.email ?? '';
  return email.split('@').first;
});
