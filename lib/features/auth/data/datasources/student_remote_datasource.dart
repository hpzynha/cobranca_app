import 'package:app_cobranca/features/auth/data/models/student_registration_payload.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRemoteDataSource {
  StudentRemoteDataSource(this._supabaseClient, {this.useMock = true});

  final SupabaseClient _supabaseClient;
  final bool useMock;

  Future<void> createStudent(StudentRegistrationPayload payload) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      return;
    }

    // TODO(dev): Quando a tabela "students" estiver criada no Supabase,
    // basta trocar useMock para false.
    await _supabaseClient.from('students').insert(payload.toSupabaseMap());
  }
}
