import 'package:app_cobranca/features/auth/data/models/student_model.dart';
import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:app_cobranca/features/auth/domain/entities/monthly_report.dart';
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
    try {
      final response = await _supabaseClient.rpc('list_students_with_status');
      final rows = (response as List).cast<Map<String, dynamic>>();
      return rows.map(StudentModel.fromSupabaseMap).toList();
    } on PostgrestException {
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
  }

  Future<void> markStudentAsPaid(String studentId) async {
    await _supabaseClient.rpc(
      'mark_student_as_paid',
      params: {'p_student_id': studentId},
    );
  }

  Future<MonthlyReport> getMonthlyReport() async {
    final now = DateTime.now();

    final response = await _supabaseClient.rpc(
      'get_monthly_report',
      params: {
        'p_month': DateTime(now.year, now.month, 1).toIso8601String(),
      },
    );

    if (response is List && response.isNotEmpty) {
      return MonthlyReport.fromMap(_normalizeMap(response.first));
    }

    if (response is Map<String, dynamic>) {
      return MonthlyReport.fromMap(_normalizeMap(response));
    }

    return MonthlyReport(expectedCents: 0, receivedCents: 0, pendingCents: 0);
  }

  Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value is! Map) {
      return const {
        'expected_cents': 0,
        'received_cents': 0,
        'pending_cents': 0,
      };
    }

    return {
      'expected_cents': _toInt(value['expected_cents']),
      'received_cents': _toInt(value['received_cents']),
      'pending_cents': _toInt(value['pending_cents']),
    };
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
