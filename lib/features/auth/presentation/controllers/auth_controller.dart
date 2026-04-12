import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final _supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    const callbackScheme = 'io.supabase.flutter';
    const redirectUrl = '$callbackScheme://login-callback/';

    // Gera URL OAuth com PKCE (code verifier é salvo internamente pelo gotrue)
    final oauthResponse = await _supabase.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: redirectUrl,
    );

    // ASWebAuthenticationSession: modal seguro do iOS para OAuth
    // Suporta redirect para custom URL scheme e fecha automaticamente
    final String result;
    try {
      result = await FlutterWebAuth2.authenticate(
        url: oauthResponse.url,
        callbackUrlScheme: callbackScheme,
      );
    } on Exception catch (e) {
      // Usuário cancelou explicitamente — não mostra erro
      if (e.toString().contains('CANCELED')) return;
      rethrow;
    }

    // Extrai o código de autorização do callback e troca pela sessão
    final uri = Uri.parse(result);
    final code = uri.queryParameters['code'];
    if (code == null) {
      throw Exception('Código de autorização não encontrado na resposta.');
    }

    await _supabase.auth.exchangeCodeForSession(code);
  }

  Future<void> signInWithApple() async {
    const callbackScheme = 'io.supabase.flutter';
    const redirectUrl = '$callbackScheme://login-callback/';

    final oauthResponse = await _supabase.auth.getOAuthSignInUrl(
      provider: OAuthProvider.apple,
      redirectTo: redirectUrl,
    );

    final String result;
    try {
      result = await FlutterWebAuth2.authenticate(
        url: oauthResponse.url,
        callbackUrlScheme: callbackScheme,
      );
    } on Exception catch (e) {
      if (e.toString().contains('CANCELED')) return;
      rethrow;
    }

    final uri = Uri.parse(result);
    final code = uri.queryParameters['code'];
    if (code == null) {
      throw Exception('Código de autorização não encontrado na resposta.');
    }

    await _supabase.auth.exchangeCodeForSession(code);
  }
}
