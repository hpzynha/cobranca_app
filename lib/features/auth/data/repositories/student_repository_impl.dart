import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/data/datasources/student_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';
import 'package:app_cobranca/features/auth/domain/services/calculate_next_due_date.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepositoryImpl implements StudentRepository {
  StudentRepositoryImpl(this._remoteDataSource);

  final StudentRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> createStudent(StudentRegistrationInput input) async {
    try {
      final ownerId = Supabase.instance.client.auth.currentUser?.id;
      if (ownerId == null || ownerId.isEmpty) {
        return Result.error(
          const Failure(
            message: 'Usuário não autenticado. Faça login novamente.',
          ),
        );
      }

      final resolvedNextDueDate =
          input.nextDueDate == null
              ? calculateNextDueDate(input.dueDay)
              : DateTime(
                input.nextDueDate!.year,
                input.nextDueDate!.month,
                input.nextDueDate!.day,
              );

      final payload = StudentRegistrationPayload.fromInput(
        input,
        ownerId: ownerId,
        resolvedNextDueDate: resolvedNextDueDate,
      );
      await _remoteDataSource.createStudent(payload);
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message:
              e.message.isNotEmpty
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
      final students = await _remoteDataSource.fetchStudents();
      return Result.success(students.map((model) => model.toEntity()).toList());
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
          message:
              e.message.isNotEmpty
                  ? e.message
                  : 'Não foi possível carregar os alunos.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Sem conexão ou erro inesperado. Tente novamente.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> markStudentAsPaid({required String studentId}) async {
    try {
      await _remoteDataSource.markStudentAsPaid(studentId: studentId);

      return Result.success(null);
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
          message:
              e.message.isNotEmpty
                  ? e.message
                  : 'Não foi possível marcar o pagamento.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Sem conexão ou erro inesperado. Tente novamente.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> inactivateStudent({required String studentId}) async {
    try {
      await _remoteDataSource.inactivateStudent(studentId);
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty ? e.message : 'Não foi possível inativar o aluno.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(const Failure(message: 'Sem conexão ou erro inesperado.'));
    }
  }

  @override
  Future<Result<void>> reactivateStudent({required String studentId}) async {
    try {
      await _remoteDataSource.reactivateStudent(studentId);
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty ? e.message : 'Não foi possível reativar o aluno.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(const Failure(message: 'Sem conexão ou erro inesperado.'));
    }
  }

  @override
  Future<Result<void>> deleteStudent({required String studentId}) async {
    try {
      await _remoteDataSource.deleteStudent(studentId);
      return Result.success(null);
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty ? e.message : 'Não foi possível deletar o aluno.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(const Failure(message: 'Sem conexão ou erro inesperado.'));
    }
  }

  @override
  Future<Result<({int expectedCents, int receivedCents, int pendingCents})>>
  getMonthlyReport(DateTime month) async {
    try {
      final data = await _remoteDataSource.getMonthlyReport(month);
      return Result.success((
        expectedCents: (data['expected_cents'] as num).toInt(),
        receivedCents: (data['received_cents'] as num).toInt(),
        pendingCents: (data['pending_cents'] as num).toInt(),
      ));
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
          message:
              e.message.isNotEmpty
                  ? e.message
                  : 'Não foi possível carregar o relatório.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(
          message: 'Sem conexão ou erro inesperado. Tente novamente.',
        ),
      );
    }
  }
}
