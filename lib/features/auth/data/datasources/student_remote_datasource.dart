import 'package:app_cobranca/features/auth/data/models/student_model.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRemoteDataSource {
  StudentRemoteDataSource(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  Future<void> createStudent(StudentRegistrationPayload payload) async {
    final ownerId = Supabase.instance.client.auth.currentUser?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const AuthException('Usuário não autenticado.');
    }

    await _supabaseClient.from('students').insert({
      ...payload.toSupabaseMap(),
      'owner_id': ownerId,
    });
  }

  Future<List<StudentModel>> fetchStudents({
    int limit = 50,
    int offset = 0,
  }) async {
    final ownerId = _supabaseClient.auth.currentUser?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const AuthException('Usuário não autenticado.');
    }
    try {
      final response = await _supabaseClient.rpc(
        'list_students_with_status',
        params: {'p_limit': limit, 'p_offset': offset},
      );
      final rows = (response as List).cast<Map<String, dynamic>>();
      return rows.map(StudentModel.fromSupabaseMap).toList();
    } on PostgrestException {
      final response = await _supabaseClient
          .from('students')
          .select(
            'id, owner_id, name, whatsapp, monthly_fee_cents, due_day, next_due_date, last_payment_date, photo_url, created_at',
          )
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final rows = (response as List).cast<Map<String, dynamic>>();
      return rows.map(StudentModel.fromSupabaseMap).toList();
    }
  }

  Future<void> markStudentAsPaid({required String studentId}) async {
    await _supabaseClient.rpc(
      'mark_student_as_paid',
      params: {'p_student_id': studentId},
    );
  }

  Future<void> inactivateStudent(String studentId) async {
    final ownerId = _supabaseClient.auth.currentUser?.id;
    await _supabaseClient
        .from('students')
        .update({'is_active': false})
        .eq('id', studentId)
        .eq('owner_id', ownerId ?? '');
  }

  Future<void> reactivateStudent(String studentId) async {
    final ownerId = _supabaseClient.auth.currentUser?.id;
    await _supabaseClient
        .from('students')
        .update({'is_active': true})
        .eq('id', studentId)
        .eq('owner_id', ownerId ?? '');
  }

  Future<void> deleteStudent(String studentId) async {
    final ownerId = _supabaseClient.auth.currentUser?.id;
    await _supabaseClient
        .from('students')
        .delete()
        .eq('id', studentId)
        .eq('owner_id', ownerId ?? '');
  }

  Future<Map<String, dynamic>> getMonthlyReport(DateTime month) async {
    final monthStr =
        '${month.year}-${month.month.toString().padLeft(2, '0')}-01';
    final response = await _supabaseClient.rpc(
      'get_monthly_report',
      params: {'p_month': monthStr},
    );
    return (response as List).first as Map<String, dynamic>;
  }
}
