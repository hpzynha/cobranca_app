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

  Future<List<StudentModel>> fetchStudents() async {
    final ownerId = _supabaseClient.auth.currentUser?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const AuthException('Usuário não autenticado.');
    }

    final response = await _supabaseClient
        .from('students')
        .select(
          'id, owner_id, name, whatsapp, monthly_fee_cents, due_day, next_due_date, last_payment_date, photo_url, created_at',
        )
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);

    final rows = (response as List).cast<Map<String, dynamic>>();
    return rows.map(StudentModel.fromSupabaseMap).toList();
  }

  Future<void> markStudentAsPaid({
    required String studentId,
    required DateTime lastPaymentDate,
    required DateTime nextDueDate,
  }) async {
    final ownerId = _supabaseClient.auth.currentUser?.id;
    if (ownerId == null || ownerId.isEmpty) {
      throw const AuthException('Usuário não autenticado.');
    }

    await _supabaseClient
        .from('students')
        .update({
          'last_payment_date': lastPaymentDate.toIso8601String(),
          'next_due_date': nextDueDate.toIso8601String(),
        })
        .eq('id', studentId)
        .eq('owner_id', ownerId);
  }
}
