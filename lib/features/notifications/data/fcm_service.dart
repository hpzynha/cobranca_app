import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  final SupabaseClient _supabase;

  FcmService(this._supabase);

  Future<void> registerToken() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await messaging.getToken();
    if (token == null) return;

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('fcm_tokens').upsert(
      {'owner_id': userId, 'token': token, 'updated_at': DateTime.now().toIso8601String()},
      onConflict: 'owner_id, token',
    );
  }
}
