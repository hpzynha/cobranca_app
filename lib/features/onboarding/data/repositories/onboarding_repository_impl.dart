import 'package:app_cobranca/features/onboarding/data/datasources/onboarding_remote_datasource.dart';

class OnboardingRepositoryImpl {
  const OnboardingRepositoryImpl(this._dataSource);

  final OnboardingRemoteDataSource _dataSource;

  Future<bool> checkOnboardingCompleted(String userId) =>
      _dataSource.checkOnboardingCompleted(userId);

  Future<void> completeOnboarding({required String userId}) =>
      _dataSource.completeOnboarding(userId: userId);
}
