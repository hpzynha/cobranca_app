import 'package:app_cobranca/features/auth/domain/entities/student.dart';
import 'package:app_cobranca/features/auth/domain/usecases/list_students_usecase.dart';
import 'package:app_cobranca/features/auth/data/datasources/student_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/repositories/student_repository_impl.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';
import 'package:app_cobranca/features/auth/domain/usecases/mark_student_as_paid_usecase.dart';
import 'package:app_cobranca/features/auth/domain/usecases/register_student_usecase.dart';
import 'package:app_cobranca/features/auth/presentation/models/student_payment_item_mapper.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/lib/features/auth/presentation/widgets/students_dashboard_card.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentRemoteDataSourceProvider = Provider<StudentRemoteDataSource>((
  ref,
) {
  return StudentRemoteDataSource(ref.watch(supabaseClientProvider));
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.watch(studentRemoteDataSourceProvider));
});

final registerStudentUseCaseProvider = Provider<RegisterStudentUseCase>((ref) {
  return RegisterStudentUseCase(ref.watch(studentRepositoryProvider));
});

final listStudentsUseCaseProvider = Provider<ListStudentsUseCase>((ref) {
  return ListStudentsUseCase(ref.watch(studentRepositoryProvider));
});

final markStudentAsPaidUseCaseProvider = Provider<MarkStudentAsPaidUseCase>((
  ref,
) {
  return MarkStudentAsPaidUseCase(ref.watch(studentRepositoryProvider));
});

final studentsProvider = FutureProvider<List<Student>>((ref) async {
  final result = await ref.read(listStudentsUseCaseProvider).call();
  if (!result.isSuccess) {
    throw Exception(result.failure?.message ?? 'Erro ao carregar alunos.');
  }
  return result.data ?? const [];
});

final studentPaymentItemsProvider = FutureProvider<List<StudentPaymentItem>>((
  ref,
) async {
  final students = await ref.watch(studentsProvider.future);
  return students.toPaymentItems();
});

final monthlyBalanceProvider = FutureProvider<double>((ref) async {
  final students = await ref.watch(studentsProvider.future);
  return students.fold<double>(0, (sum, s) => sum + s.monthlyFeeCents / 100.0);
});
