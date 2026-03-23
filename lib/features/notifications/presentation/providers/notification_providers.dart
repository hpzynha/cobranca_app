import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:app_cobranca/features/notifications/data/fcm_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref.watch(supabaseClientProvider));
});
