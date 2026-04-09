import 'package:app_cobranca/core/errors/result.dart';
import 'package:app_cobranca/features/auth/domain/entities/month_option.dart';
import 'package:app_cobranca/features/auth/domain/entities/report_summary.dart';

abstract class ReportsRepository {
  Future<Result<List<MonthOption>>> listAvailableMonths();
  Future<Result<ReportSummary>> getMonthlyReport(int year, int month);
}
