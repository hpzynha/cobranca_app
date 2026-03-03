import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';

class MarkStudentAsPaidUseCase {
  MarkStudentAsPaidUseCase(this._studentRepository);

  final StudentRepository _studentRepository;

  Future<Result<void>> call({required String studentId}) {
    return _studentRepository.markStudentAsPaid(studentId: studentId);
  }
}
