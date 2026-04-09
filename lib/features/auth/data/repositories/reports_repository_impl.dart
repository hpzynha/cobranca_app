import 'package:app_cobranca/core/errors/failure.dart';
import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/data/datasources/reports_remote_datasource.dart';
import 'package:app_cobranca/features/auth/domain/entities/month_option.dart';
import 'package:app_cobranca/features/auth/domain/entities/report_summary.dart';
import 'package:app_cobranca/features/auth/domain/repositories/reports_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._dataSource);

  final ReportsRemoteDataSource _dataSource;

  @override
  Future<Result<List<MonthOption>>> listAvailableMonths() async {
    try {
      final rows = await _dataSource.listAvailableMonths();
      final months = rows
          .map(
            (row) => MonthOption(
              year: (row['year'] as num).toInt(),
              month: (row['month'] as num).toInt(),
              label: row['label'] as String,
            ),
          )
          .toList();
      return Result.success(months);
    } on AuthException {
      return Result.error(
        const Failure(
          message: 'Sessão expirada. Faça login novamente.',
          code: 'auth_error',
        ),
      );
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Não foi possível carregar os meses disponíveis.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(message: 'Sem conexão ou erro inesperado. Tente novamente.'),
      );
    }
  }

  @override
  Future<Result<ReportSummary>> getMonthlyReport(int year, int month) async {
    try {
      final data = await _dataSource.getMonthlyReport(year, month);
      return Result.success(
        ReportSummary(
          expectedCents: (data['expected_cents'] as num).toInt(),
          receivedCents: (data['received_cents'] as num).toInt(),
          dueSoonCents: (data['due_soon_cents'] as num).toInt(),
          overdueCents: (data['overdue_cents'] as num).toInt(),
          lateReceivedCents: (data['late_received_cents'] as num).toInt(),
        ),
      );
    } on AuthException {
      return Result.error(
        const Failure(
          message: 'Sessão expirada. Faça login novamente.',
          code: 'auth_error',
        ),
      );
    } on PostgrestException catch (e) {
      return Result.error(
        Failure(
          message: e.message.isNotEmpty
              ? e.message
              : 'Não foi possível carregar o relatório.',
          code: e.code,
        ),
      );
    } catch (_) {
      return Result.error(
        const Failure(message: 'Sem conexão ou erro inesperado. Tente novamente.'),
      );
    }
  }
}
