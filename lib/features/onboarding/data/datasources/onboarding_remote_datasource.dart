import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingRemoteDataSource {
  const OnboardingRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<bool> checkOnboardingCompleted(String userId) async {
    final result = await _client
        .from('profiles')
        .select('onboarding_completed')
        .eq('id', userId)
        .maybeSingle();
    return result?['onboarding_completed'] == true;
  }

  Future<void> completeOnboarding({required String userId}) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'onboarding_completed': true,
    });
  }
}
