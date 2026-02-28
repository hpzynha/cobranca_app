import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/data/datasources/student_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._remoteDataSource);

  final StudentRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> createStudent(StudentRegistrationInput input) async {
    try {
      final payload = StudentRegistrationPayload.fromInput(input);
      await _remoteDataSource.createStudent(payload);
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Não foi possível cadastrar o aluno.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Não foi possível cadastrar o aluno. Tente novamente.',
        ),
      );
    }
  }
}
