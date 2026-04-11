import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesRemoteDataSource {
  MessagesRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> listMessageLogs() async {
    final response = await _client
        .from('message_logs')
        .select()
        .order('sent_at', ascending: false)
        .limit(100);
    return (response as List).cast<Map<String, dynamic>>();
  }
}
