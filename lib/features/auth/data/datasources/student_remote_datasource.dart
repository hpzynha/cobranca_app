import 'package:app_cobranca/features/auth/data/models/student_model.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRemoteDataSource {
  StudentRemoteDataSource(this._supabaseClient, {this.useMock = false});

  final SupabaseClient _supabaseClient;
  final bool useMock;

  Future<void> createStudent(StudentRegistrationPayload payload) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      return;
    }

    await _supabaseClient.from('students').insert(payload.toSupabaseMap());
  }

  Future<List<StudentModel>> fetchStudents() async {
    if (useMock) {
      return const [];
    }

    final response = await _supabaseClient
        .from('students')
        .select('id, name, monthly_fee_cents, due_day, photo_url');

    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(StudentModel.fromSupabaseMap).toList();
  }
}
