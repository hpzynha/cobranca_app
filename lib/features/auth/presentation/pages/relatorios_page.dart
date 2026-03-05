import 'package:app_cobranca/core/theme/app_colors.dart';
import 'package:app_cobranca/features/auth/domain/entities/monthly_report.dart';
import 'package:app_cobranca/features/auth/presentation/providers/student_providers.dart';
import 'package:app_cobranca/features/auth/presentation/widgets/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RelatoriosPage extends ConsumerWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(monthlyReportProvider);

    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Relatórios')),
      body: SafeArea(
        child: reportAsync.when(
          data: (report) => _ReportsContent(report: report),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
        ),
      ),
      bottomNavigationBar: const BottomBar(currentIndex: 3),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  const _ReportsContent({required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final expected = report.expectedCents / 100;
    final received = report.receivedCents / 100;
    final pending = report.pendingCents / 100;
    final delinquency = expected <= 0 ? 0.0 : (report.pendingCents / report.expectedCents) * 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        const Text(
          'Visão financeira do seu mês',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Este mês', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _ReportCard(
              icon: Icons.attach_money,
              iconColor: AppColors.textStrong,
              value: _formatCurrency(expected),
              label: 'Total Previsto',
            ),
            _ReportCard(
              icon: Icons.trending_up,
              iconColor: AppColors.success,
              value: _formatCurrency(received),
              label: 'Total Recebido',
            ),
            _ReportCard(
              icon: Icons.trending_down,
              iconColor: AppColors.danger,
              value: _formatCurrency(pending),
              label: 'Total em Atraso',
            ),
            _ReportCard(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.warning,
              value: '${delinquency.toStringAsFixed(0)}%',
              label: 'Inadimplência',
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return currency.format(value);
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
