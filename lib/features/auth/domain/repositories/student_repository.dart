import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';

abstract class StudentRepository {
  Future<Result<void>> createStudent(StudentRegistrationInput input);
  Future<Result<List<Student>>> listStudents();
  Future<Result<void>> markStudentAsPaid({required String studentId});
  Future<Result<void>> inactivateStudent({required String studentId});
  Future<Result<void>> reactivateStudent({required String studentId});
  Future<Result<void>> deleteStudent({required String studentId});
  Future<Result<void>> updateDueDate({
    required String studentId,
    required int dueDay,
    required DateTime nextDueDate,
  });
  Future<Result<({int expectedCents, int receivedCents, int dueSoonCents, int pendingCents})>>
  getMonthlyReport(DateTime month);
}
