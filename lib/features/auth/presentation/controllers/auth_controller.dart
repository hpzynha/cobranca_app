import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final _supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;

    await googleSignIn.initialize(
      serverClientId: '656300308953-99dm5r6gnuefrhh1s58ts0md5vjqeqld.apps.googleusercontent.com',
    );

    final googleUser = await googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) throw Exception('Google idToken não encontrado');

    await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }
}
