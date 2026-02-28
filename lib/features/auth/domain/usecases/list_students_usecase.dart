import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';

class ListStudentsUseCase {
  ListStudentsUseCase(this._studentRepository);

  final StudentRepository _studentRepository;

  Future<Result<List<Student>>> call() {
    return _studentRepository.listStudents();
  }
}
