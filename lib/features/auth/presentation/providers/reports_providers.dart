import 'dart:developer' as dev;

import 'package:app_cobranca/features/auth/data/datasources/reports_remote_datasource.dart';
import 'package:app_cobranca/features/auth/data/repositories/reports_repository_impl.dart';
import 'package:app_cobranca/features/auth/domain/entities/month_option.dart';
import 'package:app_cobranca/features/auth/domain/entities/report_summary.dart';
import 'package:app_cobranca/features/auth/domain/repositories/reports_repository.dart';
import 'package:app_cobranca/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final reportsRemoteDataSourceProvider = Provider<ReportsRemoteDataSource>((ref) {
  return ReportsRemoteDataSource(ref.watch(supabaseClientProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepositoryImpl(ref.watch(reportsRemoteDataSourceProvider));
});

// ── State ─────────────────────────────────────────────────────────────────────

class ReportsState {
  const ReportsState({
    required this.availableMonths,
    required this.selectedMonth,
    required this.report,
  });

  final List<MonthOption> availableMonths;
  final MonthOption selectedMonth;
  final AsyncValue<ReportSummary> report;

  ReportsState copyWith({
    List<MonthOption>? availableMonths,
    MonthOption? selectedMonth,
    AsyncValue<ReportSummary>? report,
  }) {
    return ReportsState(
      availableMonths: availableMonths ?? this.availableMonths,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      report: report ?? this.report,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ReportsNotifier extends AsyncNotifier<ReportsState> {
  @override
  Future<ReportsState> build() async {
    final now = DateTime.now();
    final currentMonth = MonthOption(
      year: now.year,
      month: now.month,
      label: _portugueseLabel(now.year, now.month),
    );

    final monthsResult =
        await ref.read(reportsRepositoryProvider).listAvailableMonths();

    List<MonthOption> months;
    if (monthsResult.isSuccess) {
      months = monthsResult.data ?? [];
      // Guarantee current month is always present
      if (!months.any((m) => m == currentMonth)) {
        months = [currentMonth, ...months];
      }
    } else {
      months = [currentMonth];
    }

    final reportResult = await ref
        .read(reportsRepositoryProvider)
        .getMonthlyReport(currentMonth.year, currentMonth.month);

    final AsyncValue<ReportSummary> report;
    if (reportResult.isSuccess) {
      report = AsyncData(reportResult.data!);
    } else {
      dev.log(
        'ReportsNotifier.build: ${reportResult.failure?.message}',
        name: 'ReportsNotifier',
      );
      report = AsyncError(
        reportResult.failure?.message ?? 'Erro ao carregar relatório.',
        StackTrace.current,
      );
    }

    return ReportsState(
      availableMonths: months,
      selectedMonth: currentMonth,
      report: report,
    );
  }

  Future<void> selectMonth(MonthOption month) async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(
      current.copyWith(
        selectedMonth: month,
        report: const AsyncLoading(),
      ),
    );

    final result = await ref
        .read(reportsRepositoryProvider)
        .getMonthlyReport(month.year, month.month);

    final AsyncValue<ReportSummary> newReport;
    if (result.isSuccess) {
      newReport = AsyncData(result.data!);
    } else {
      dev.log(
        'ReportsNotifier.selectMonth: ${result.failure?.message}',
        name: 'ReportsNotifier',
      );
      newReport = AsyncError(
        result.failure?.message ?? 'Erro ao carregar relatório.',
        StackTrace.current,
      );
    }

    // state.valueOrNull may have changed while awaiting, use latest
    final latest = state.valueOrNull ?? current;
    state = AsyncData(latest.copyWith(selectedMonth: month, report: newReport));
  }

  static String _portugueseLabel(int year, int month) {
    const names = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${names[month - 1]} $year';
  }
}

final reportsNotifierProvider =
    AsyncNotifierProvider<ReportsNotifier, ReportsState>(
  ReportsNotifier.new,
);
