import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/data/datasources/messages_remote_datasource.dart';
import 'package:app_cobranca/features/auth/domain/entities/message_log.dart';
import 'package:app_cobranca/features/auth/domain/repositories/messages_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesRepositoryImpl implements MessagesRepository {
  MessagesRepositoryImpl(this._dataSource);

  final MessagesRemoteDataSource _dataSource;

  @override
  Future<Result<List<MessageLog>>> listMessageLogs() async {
    try {
      final rows = await _dataSource.listMessageLogs();
      final logs = rows.map((row) {
        return MessageLog(
          id: row['id'] as String,
          studentName: row['student_name'] as String,
          template: row['template'] as String,
          status: row['status'] as String,
          errorMsg: row['error_msg'] as String?,
          sentAt: DateTime.parse(row['sent_at'] as String).toLocal(),
        );
      }).toList();
      return Result.success(logs);
    } on AuthException {
      return Result.error(
        const Failure(
          message: 'Sessão expirada. Faça login novamente.',
          code: 'auth_error',
        ),
      );
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Não foi possível carregar as mensagens.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(message: 'Sem conexão ou erro inesperado. Tente novamente.'),
      );
    }
  }
}
