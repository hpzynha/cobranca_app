import 'package:app_cobranca/features/auth/data/datasources/messages_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/repositories/messages_repository_impl.dart';
import 'package:app_cobranca/features/auth/domain/entities/message_log.dart';
import 'package:app_cobranca/features/auth/domain/repositories/messages_repository.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messagesRemoteDataSourceProvider = Provider<MessagesRemoteDataSource>((ref) {
  return MessagesRemoteDataSource(ref.watch(supabaseClientProvider));
});

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepositoryImpl(ref.watch(messagesRemoteDataSourceProvider));
});

final messageLogsProvider = FutureProvider<List<MessageLog>>((ref) async {
  final result = await ref.watch(messagesRepositoryProvider).listMessageLogs();
  if (result.isSuccess) return result.data ?? [];
  throw Exception(result.failure?.message ?? 'Erro ao carregar mensagens.');
});
