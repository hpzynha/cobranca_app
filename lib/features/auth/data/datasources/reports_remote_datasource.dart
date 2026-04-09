import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<List<Map<String, dynamic>>> listAvailableMonths() async {
    final response = await _client.rpc('list_available_months');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getMonthlyReport(int year, int month) async {
    final response = await _client.rpc(
      'get_monthly_report',
      params: {'p_year': year, 'p_month': month},
    );
    return (response as List).first as Map<String, dynamic>;
  }
}
