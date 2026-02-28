import 'package:app_cobranca/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.emailConfirmed,
  });

  factory AuthUserModel.fromSupabase(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      emailConfirmed: user.emailConfirmedAt != null,
    );
  }
}
