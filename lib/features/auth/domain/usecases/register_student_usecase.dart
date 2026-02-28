import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/student_registration_input.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';

class RegisterStudentUseCase {
  RegisterStudentUseCase(this._studentRepository);

  final StudentRepository _studentRepository;

  Future<Result<void>> call(StudentRegistrationInput input) {
    return _studentRepository.createStudent(input);
  }
}
