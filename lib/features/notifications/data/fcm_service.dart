import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FcmService {
  final SupabaseClient _supabase;

  FcmService(this._supabase);

  Future<void> registerToken() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // iOS exige APNs token antes de gerar o FCM token
    if (Platform.isIOS) {
      String? apnsToken;
      for (var i = 0; i < 5; i++) {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) break;
        await Future.delayed(const Duration(seconds: 1));
      }
      if (apnsToken == null) {
        debugPrint('[FCM] APNs token não disponível (simulador?)');
        return;
      }
      debugPrint('[FCM] APNs token OK');
    }

    final token = await messaging.getToken();
    if (token == null) {
      debugPrint('[FCM] FCM token nulo');
      return;
    }
    debugPrint('[FCM] Token obtido: ${token.substring(0, 20)}...');

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('[FCM] Usuário não autenticado');
      return;
    }

    await _supabase.from('fcm_tokens').upsert(
      {'owner_id': userId, 'token': token, 'updated_at': DateTime.now().toIso8601String()},
      onConflict: 'owner_id, token',
    );
    debugPrint('[FCM] Token salvo com sucesso');
  }
}
