import 'package:app_cobranca/features/onboarding/data/repositories/onboarding_repository_impl.dart';

class CheckOnboardingUseCase {
  const CheckOnboardingUseCase(this._repository);

  final OnboardingRepositoryImpl _repository;

  Future<bool> call(String userId) => _repository.checkOnboardingCompleted(userId);
}
