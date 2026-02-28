import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';

abstract class StudentRepository {
  Future<Result<void>> createStudent(StudentRegistrationInput input);
}
