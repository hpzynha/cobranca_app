import 'package:app_cobranca/features/auth/data/datasources/student_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/repositories/student_repository_impl.dart';
import 'package:app_cobranca/features/auth/domain/repositories/student_repository.dart';
import 'package:app_cobranca/features/auth/domain/usecases/register_student_usecase.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentRemoteDataSourceProvider = Provider<StudentRemoteDataSource>((ref) {
  return StudentRemoteDataSource(ref.watch(supabaseClientProvider));
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.watch(studentRemoteDataSourceProvider));
});

final registerStudentUseCaseProvider = Provider<RegisterStudentUseCase>((ref) {
  return RegisterStudentUseCase(ref.watch(studentRepositoryProvider));
});
