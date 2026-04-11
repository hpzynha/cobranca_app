import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/message_log.dart';

abstract class MessagesRepository {
  Future<Result<List<MessageLog>>> listMessageLogs();
}
