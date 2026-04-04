import 'package:app_cobranca/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:app_cobranca/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:app_cobranca/features/onboarding/domain/usecases/check_onboarding_usecase.dart';
import 'package:app_cobranca/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onboardingRemoteDataSourceProvider =
    Provider<OnboardingRemoteDataSource>((ref) {
  return OnboardingRemoteDataSource(Supabase.instance.client);
});

final onboardingRepositoryProvider =
    Provider<OnboardingRepositoryImpl>((ref) {
  return OnboardingRepositoryImpl(
    ref.watch(onboardingRemoteDataSourceProvider),
  );
});

final checkOnboardingUseCaseProvider =
    Provider<CheckOnboardingUseCase>((ref) {
  return CheckOnboardingUseCase(ref.watch(onboardingRepositoryProvider));
});

final completeOnboardingUseCaseProvider =
    Provider<CompleteOnboardingUseCase>((ref) {
  return CompleteOnboardingUseCase(ref.watch(onboardingRepositoryProvider));
});

/// Verifica se o onboarding já foi concluído para o usuário atual.
/// Usado pelos widgets para leitura de estado (o roteador usa
/// OnboardingStatusNotifier diretamente para cache síncrono).
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return false;
  return ref.watch(checkOnboardingUseCaseProvider).call(userId);
});
