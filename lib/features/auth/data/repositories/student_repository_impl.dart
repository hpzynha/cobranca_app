import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/data/datasources/student_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._remoteDataSource, this._supabaseClient);

  final StudentRemoteDataSource _remoteDataSource;
  final SupabaseClient _supabaseClient;

  String _requireCurrentUserId() {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw const UnauthenticatedStudentException();
    }
    return user.id;
  }

  @override
  Future<Result<void>> createStudent(StudentRegistrationInput input) async {
    try {
      final ownerId = _requireCurrentUserId();
      final payload = StudentRegistrationPayload.fromInput(
        input: input,
        ownerId: ownerId,
      );
      await _remoteDataSource.createStudent(payload);
      return Result.success(null);
    } on UnauthenticatedStudentException catch (e) {
      return Result.error(Failure(message: e.message));
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

  @override
  Future<Result<List<Student>>> listStudents() async {
    try {
      final ownerId = _requireCurrentUserId();
      final students = await _remoteDataSource.listStudents(ownerId: ownerId);
      return Result.success(students.map((student) => student.toEntity()).toList());
    } on UnauthenticatedStudentException catch (e) {
      return Result.error(Failure(message: e.message));
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Não foi possível carregar os alunos.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Não foi possível carregar os alunos. Tente novamente.',
        ),
      );
    }
  }
}

class UnauthenticatedStudentException implements Exception {
  const UnauthenticatedStudentException();

  String get message => 'Usuário não autenticado. Faça login novamente.';
}
