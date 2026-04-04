import 'package:app_cobranca/features/onboarding/data/repositories/onboarding_repository_impl.dart';

class CompleteOnboardingUseCase {
  const CompleteOnboardingUseCase(this._repository);

  final OnboardingRepositoryImpl _repository;

  Future<void> call({required String userId}) =>
      _repository.completeOnboarding(userId: userId);
}
