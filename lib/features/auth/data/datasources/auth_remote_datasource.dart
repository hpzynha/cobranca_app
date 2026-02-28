import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<AuthResponse> signUp({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> resendSignUpEmail(String email) {
    return _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<AuthResponse> refreshSession() {
    return _client.auth.refreshSession();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
