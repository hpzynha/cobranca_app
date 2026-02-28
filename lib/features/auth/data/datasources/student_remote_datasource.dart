import 'package:app_cobranca/features/auth/data/models/student_model.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRemoteDataSource {
  StudentRemoteDataSource(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  Future<void> createStudent(StudentRegistrationPayload payload) async {
    await _supabaseClient.from('students').insert(payload.toSupabaseMap());
  }

  Future<List<StudentModel>> listStudents({required String ownerId}) async {
    final response = await _supabaseClient
        .from('students')
        .select('id, owner_id, name, monthly_fee_cents, due_day, photo_url, created_at')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    return response
        .map<StudentModel>(
          (item) => StudentModel.fromSupabase(item as Map<String, dynamic>),
        )
        .toList();
  }
}
